# Set Working Directory
setwd("C:/Users/toby_lowton/Documents/ERF_Project")

# Load necessary R packages for the analysis
library(tidyr)
library(bsts)
library(BoomSpikeSlab)
library(xts)
library(plm)
library(dplyr)
library(CausalImpact)
library(zoo)
library(CausalArima)
library(tidybayes)
library(lubridate)
library(htmltools)
library(DBI)
library(ggthemes)
library(tseries)
library(openxlsx)
library(readr)
library(readxl)
library(pheatmap)

#No provider mergers within this time period - acute trusts only
con <- dbConnect(odbc::odbc(), "UDAL_Warehouse")
data <- dbGetQuery(con, "
SELECT Organisation_Code AS Provider_Code,
    Treatment_Function_Code AS T_Code,
    Number_Of_Weeks_Since_Referral AS Weeks,
    Number_Of_Completed_Admitted_Pathways AS AP, 
    Effective_Snapshot_Date AS Date
FROM UDAL_Warehouse.UKHF_RTT.Completed_Admitted_Pathways_Provider1_1
WHERE Effective_Snapshot_Date >= '2021-09-30' AND Effective_Snapshot_Date < '2023-10-01' 
    AND Organisation_Code IN ('RCF','RAE','RWY','RR8','RXF')
    AND Number_Of_Weeks_Since_Referral IN ('>0-1','>23-24','>52-53','>65-66')
    AND Treatment_Function_Code IN('100','101','102','103','104','105','106','107','108','109','110','111','113','115','120','130','140','141','143','144','145','149','150','160','161','170','172','173','174',
    '180','190','191','192','200','300','301','302','303','304','305','306','307','308','309','310','311','312','313','314','315','316','317','318','319','320','322','323','324','325','326','327','328','329','330','331','333','335','340','341','342','343','344','345','346','347','348','350','352','360','361','370','371','400','401','410','420','422','424','430','431','450','451','460','461','500','501','502','503','504','505','510','520','600','610','620','834')
")
rm(con)

# Categorize data into 'Surgical' or 'Medical' based on Treatment Function Code
data <- data %>%
  mutate(Specialty = ifelse(as.numeric(T_Code) <= 174, "Surgical", "Medical"),
         Date = floor_date(as.Date(Date), "month"))


#Import bed occupancy data, set date to first of month and then join
Bed_Occ <- read_csv("Data_Sources/Bed_Occupancy_Data_WY.csv", col_types = cols())
Bed_Occ$Date <- dmy(paste("01-", Bed_Occ$Date, sep=""))
data <- left_join(data, Bed_Occ, by = c("Date"))

# Initialize an empty list to collect results
results_list <- list()

# Loop through each specialty and weeks_filter
specialties <- c("Medical", "Surgical")
for (specialty in specialties) {
  for (weeks in weeks_filters) {
    specialty_filtered <- filter(data, Specialty == specialty, Weeks == weeks)
    if (nrow(specialty_filtered) == 0) next  # Skip if no data
    
    specialty_aggregated <- specialty_filtered %>%
      group_by(Date) %>%
      summarise(Total_AP = sum(AP), Sum_BedOcc = sum(BedOcc), .groups = 'drop')
    
    data_zoo <- zoo(cbind(specialty_aggregated$Total_AP, specialty_aggregated$Sum_BedOcc),
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
    
    avg_total_ap_pre <- mean(specialty_aggregated$Total_AP[specialty_aggregated$Date < as.Date("2023-04-01")])
    avg_total_ap_post <- mean(specialty_aggregated$Total_AP[specialty_aggregated$Date >= as.Date("2023-04-01")])
    
    # Append results for the current iteration to the list
    results_list[[paste(specialty, weeks)]] <- data.frame(
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

# Combine all results into a single data frame
results_df <- do.call(rbind, results_list)

# Save the combined results to an Excel file
write.xlsx(results_df, "Outputs/WY/Admitted_Absolute.xlsx", rowNames = FALSE)

####Duplicate for non-admitted
rm(list=ls())
con <- dbConnect(odbc::odbc(), "UDAL_Warehouse")
data1 <- dbGetQuery(con, "
SELECT Organisation_Code AS Provider_Code,
    Treatment_Function_Code AS T_Code,
    Number_Of_Weeks_Since_Referral AS Weeks,
    Number_Of_Completed_NonAdmitted_Pathways AS NAP, 
    Effective_Snapshot_Date AS Date
FROM UDAL_Warehouse.UKHF_RTT.Completed_NonAdmitted_Pathways_Provider1_1
WHERE Effective_Snapshot_Date >= '2021-09-30' AND Effective_Snapshot_Date < '2023-10-01' 
    AND Organisation_Code IN ('RCF','RAE','RWY','RR8','RXF')
    AND Number_Of_Weeks_Since_Referral IN ('>0-1','>23-24','>52-53','>65-66')
    AND Treatment_Function_Code IN('100','101','102','103','104','105','106','107','108','109','110','111','113','115','120','130','140','141','143','144','145','149','150','160','161','170','172','173','174',
    '180','190','191','192','200','300','301','302','303','304','305','306','307','308','309','310','311','312','313','314','315','316','317','318','319','320','322','323','324','325','326','327','328','329','330','331','333','335','340','341','342','343','344','345','346','347','348','350','352','360','361','370','371','400','401','410','420','422','424','430','431','450','451','460','461','500','501','502','503','504','505','510','520','600','610','620','834')
")
rm(con)

# Categorize data into 'Surgical' or 'Medical' based on Treatment Function Code
data1 <- data1 %>%
  mutate(Specialty = ifelse(as.numeric(T_Code) <= 174, "Surgical", "Medical"),
         Date = floor_date(as.Date(Date), "month"))

#Import bed occupancy data, set date to first of month and then join
Bed_Occ <- read_csv("Data_Sources/Bed_Occupancy_Data_WY.csv", col_types = cols())
Bed_Occ$Date <- dmy(paste("01-", Bed_Occ$Date, sep=""))
data1 <- left_join(data1, Bed_Occ, by = c("Date"))

# Initialize an empty list to collect results
results_list <- list()

# Loop through each specialty and weeks_filter
specialties <- c("Medical", "Surgical")
for (specialty in specialties) {
  for (weeks in weeks_filters) {
    specialty_filtered <- filter(data1, Specialty == specialty, Weeks == weeks)
    if (nrow(specialty_filtered) == 0) next  # Skip if no data
    
    specialty_aggregated <- specialty_filtered %>%
      group_by(Date) %>%
      summarise(Total_AP = sum(NAP), Sum_BedOcc = sum(BedOcc), .groups = 'drop')
    
    data_zoo <- zoo(cbind(specialty_aggregated$Total_AP, specialty_aggregated$Sum_BedOcc),
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
    
    avg_total_ap_pre <- mean(specialty_aggregated$Total_AP[specialty_aggregated$Date < as.Date("2023-04-01")])
    avg_total_ap_post <- mean(specialty_aggregated$Total_AP[specialty_aggregated$Date >= as.Date("2023-04-01")])
    
    # Append results for the current iteration to the list
    results_list[[paste(specialty, weeks)]] <- data.frame(
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

# Combine all results into a single data frame
results_df <- do.call(rbind, results_list)

# Save the combined results to an Excel file
write.xlsx(results_df, "Outputs/WY/NonAdmitted_Absolute.xlsx", rowNames = FALSE)
