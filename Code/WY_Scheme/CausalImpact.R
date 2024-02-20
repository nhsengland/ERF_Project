# Set Working Directory and run packages
setwd("C:/Users/toby_lowton/Documents/ERF_Project")
library(tidyr)
library(dplyr)
library(CausalImpact)
library(zoo)
library(lubridate)
library(DBI)
library(openxlsx)

# Connect to the database
con <- dbConnect(odbc::odbc(), "UDAL_Warehouse")
data <- dbGetQuery(con, "
WITH CombinedPathways AS (
  SELECT 
    Organisation_Code AS Provider_Code,
    Treatment_Function_Code AS T_Code,
    Number_Of_Weeks_Since_Referral AS Weeks,
    Number_Of_Completed_Admitted_Pathways AS PatientCount, 
    Effective_Snapshot_Date AS Date,
    'AP' AS Setting
  FROM UDAL_Warehouse.UKHF_RTT.Completed_Admitted_Pathways_Provider1_1
  WHERE Effective_Snapshot_Date >= '2021-09-30' AND Effective_Snapshot_Date < '2023-10-01'
  
  UNION ALL
  
  SELECT 
    Organisation_Code AS Provider_Code,
    Treatment_Function_Code AS T_Code,
    Number_Of_Weeks_Since_Referral AS Weeks,
    Number_Of_Completed_NonAdmitted_Pathways AS PatientCount, 
    Effective_Snapshot_Date AS Date,
    'NAP' AS Setting
  FROM UDAL_Warehouse.UKHF_RTT.Completed_NonAdmitted_Pathways_Provider1_1
  WHERE Effective_Snapshot_Date >= '2021-09-30' AND Effective_Snapshot_Date < '2023-10-01'
)
SELECT * FROM CombinedPathways
WHERE Provider_Code IN ('RCF','RAE','RWY','RR8','RXF')
AND Weeks IN ('>0-1','>10-11','>20-21','>30-31','40-41','>50-51','>60-61','>70-71')
AND T_Code IN ('100','101','102','103','104','105','106','107','108','109','110','111','113','115','120','130','140','141','143','144','145','149','150','160','161','170','172','173','174',
    '180','190','191','192','200','300','301','302','303','304','305','306','307','308','309','310','311','312','313','314','315','316','317','318','319','320','322','323','324','325','326','327','328','329','330','331','333','335','340','341','342','343','344','345','346','347','348','350','352','360','361','370','371','400','401','410','420','422','424','430','431','450','451','460','461','500','501','502','503','504','505','510','520','600','610','620','834')
")
rm(con)  # Close the database connection

# Categorize data into 'Surgical' or 'Medical' based on Treatment Function Code
data <- data %>%
  mutate(Specialty = ifelse(as.numeric(T_Code) <= 174, "Surgical", "Medical"),
         Date = floor_date(as.Date(Date), "month"))

# Import bed occupancy data, set date to first of month and then join
Bed_Occ <- read_csv("Data_Sources/Bed_Occupancy_Data_WY.csv", col_types = cols())
Bed_Occ$Date <- dmy(paste("01-", Bed_Occ$Date, sep=""))
data <- left_join(data, Bed_Occ, by = c("Date"))

weeks_filters <- c('>0-1', '>10-11', '>20-21', '>30-31', '40-41', '>50-51', '>60-61', '>70-71')
settings <- c("AP", "NAP")  # Settings to loop through
specialties <- c("Medical", "Surgical")

# Loop through each specialty and weeks_filter
results_list <- list()
for (setting in settings) {
  for (specialty in specialties) {
    for (weeks in weeks_filters) {
      specialty_filtered <- filter(data, Setting == setting, Specialty == specialty, Weeks == weeks)
      if (nrow(specialty_filtered) == 0) next  # Skip if no data
      
      specialty_aggregated <- specialty_filtered %>%
        group_by(Date) %>%
        summarise(Total_PatientCount = sum(PatientCount), Sum_BedOcc = sum(BedOcc), .groups = 'drop')
      
      data_zoo <- zoo(cbind(specialty_aggregated$Total_PatientCount, specialty_aggregated$Sum_BedOcc),
                      order.by = as.Date(specialty_aggregated$Date))
      
      pre.period <- c("2021-09-01", "2023-03-31")  # Example dates, adjust as needed
      post.period <- c("2023-04-01", "2023-09-01")  # Adjust the end date as needed or use NA if open-ended
      
      # Ensure dates are formatted as Date objects
      pre.period <- as.Date(pre.period)
      post.period <- as.Date(post.period)
      
      # Run the CausalImpact analysis
      impact <- CausalImpact(data_zoo, pre.period, post.period, model.args = list(niter = 1000, nseasons = 12))    
      # Extract relevant metrics from the impact analysis
      if (!is.null(impact) && !is.null(impact$summary)) {
        rel_effect_avg <- impact$summary$RelEffect[1] * 100
        ci_lower_avg <- impact$summary$RelEffect.lower[1] * 100
        ci_upper_avg <- impact$summary$RelEffect.upper[1] * 100
        ss_flag <- ifelse(ci_lower_avg * ci_upper_avg > 0, 1, 0)
      } else {
        rel_effect_avg <- NA
        ci_lower_avg <- NA
        ci_upper_avg <- NA
        ss_flag <- NA
      }
      
      avg_total_ap_pre <- mean(specialty_aggregated$Total_PatientCount[specialty_aggregated$Date < as.Date("2023-04-01")])
      avg_total_ap_post <- mean(specialty_aggregated$Total_PatientCount[specialty_aggregated$Date >= as.Date("2023-04-01")])
      
      # Append results for the current iteration to the list
      results_list[[paste(setting, specialty, weeks)]] <- data.frame(
        Setting = setting,
        Specialty = specialty,
        Weeks = weeks,
        RelEffectAvgPercent = rel_effect_avg,
        CI_Lower = ci_lower_avg,
        CI_Upper = ci_upper_avg,
        SS = ss_flag,
        Avg_Total_AP_Pre = avg_total_ap_pre,
        Avg_Total_AP_Post = avg_total_ap_post
      )
    }
  }
}

# Combine all results into a single data frame and save
results_df <- do.call(rbind, results_list)
write.xlsx(results_df, "Outputs/WY/Absolute.xlsx", rowNames = FALSE)