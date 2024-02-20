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

#Staffing

#Import Data (Analysis includes only small medium large acute trusts for comparison, and excludes WY ICB trusts - this needs checking)
con <- dbConnect(odbc::odbc(), "UDAL_Warehouse")
data <- dbGetQuery(con, "
SELECT Organisation_Code AS Provider_Code,
    Treatment_Function_Code AS T_Code,
    Number_Of_Weeks_Since_Referral AS Weeks,
    Number_Of_Incomplete_Pathways AS IP, 
    Number_Of_Incomplete_Pathways_with_DTA AS IPDTA, 
    Effective_Snapshot_Date AS Date
FROM UDAL_Warehouse.UKHF_RTT.Incomplete_Pathways_Provider1_1
WHERE Effective_Snapshot_Date >= '2021-09-30' AND Effective_Snapshot_Date < '2023-10-01' 
    AND Organisation_Code IN ('RAJ', 'RDE', 'RGN', 'RWH', 'RJ2', 'RL4', 'RWD', 'RWP', 'RXK', 'R0B', 'RTF', 'RXR', 'RDU', 'RHU', 'RHW', 'RN5', 'RWF', 'RXC', 'REF', 'RTE', 'RVJ', 'RC9', 'RCX', 'RGR', 'RQW', 'RWG', 'RAS', 'RAX', 'RJ6', 'RBK', 'RFS', 'RK5', 'RLT', 'RNA', 'RNQ', 'RNS', 'RXW', 'RCD', 'RFF', 'RFR', 'RJL', 'RNN', 'RR7', 'RVW', 'RBT', 'RJN', 'RJR', 'RMC', 'RMP', 'RRF', 'RVY', 'RWJ', 'RA2', 'RN7', 'RPA', 'RTK', 'RTP', 'RBD', 'RD1', 'RN3', 'RNZ')
    AND Number_Of_Weeks_Since_Referral IN ('>23-24','>54-55','>61-62')
")

# Disconnect connection and set up dataset
dbDisconnect(con)
rm(con)

# Bed occupancy data and merge
Bed_Occ <- read_csv("Data_Sources/Bed_Occupancy_Data.csv", col_types = cols())
Bed_Occ <- Bed_Occ %>%
  mutate(across(-Provider_Code, as.character))
Bed_Occ_long <- pivot_longer(Bed_Occ, cols = -Provider_Code, names_to = "Date", values_to = "BedOccupancy")
Bed_Occ_long <- Bed_Occ_long %>%
  mutate(Date = as.Date(Date, format = "%d/%m/%Y"))
data <- data %>%
  mutate(Date = as.Date(Date, format = "%Y-%m-%d"))

# Correcting dates to the first of each month
data <- data %>%
  mutate(Date = floor_date(Date, "month"))
Bed_Occ_long <- Bed_Occ_long %>%
  mutate(Date = floor_date(Date, "month"))

data <- left_join(data, Bed_Occ_long, by = c("Provider_Code", "Date"))


#Run basic analysis
filtered_data <- data %>%
  mutate(BedOccupancy = as.numeric(as.character(BedOccupancy))) %>%
  filter(Weeks == '>23-24') %>%
  group_by(Date) %>%
  summarise(
    IP = sum(IP, na.rm = TRUE),             # Calculate the total IP for each date
    Avg_Occupancy = mean(BedOccupancy, na.rm = TRUE),    # Calculate the average occupancy rate for each date
    .groups = "drop"                              # Avoid carrying over grouping
  ) %>%
  arrange(Date)

data_matrix <- as.matrix(filtered_data[, c("IP", "Avg_Occupancy")])
data_zoo <- zoo(data_matrix, order.by = as.Date(filtered_data$Date))
pre.period <- as.Date(c("2021-09-01", "2023-03-31"))
post.period <- as.Date(c("2023-04-01", "2023-09-01"))
impact <- CausalImpact(data_zoo, pre.period, post.period, model.args = list(niter = 30000, nseasons = 12)) # nseasons = 12 for monthly data
summary(impact)
plot(impact)
summary(impact, "report")















##Robustness tests (This approach, and compare to C-Arima and ITS model results)

#imaginary implementation date
pre_period <- as.Date(c("2021-04-30", "2022-11-30"))
post_period <- as.Date(c("2022-12-01", "2023-09-30"))

# Run CausalImpact with the imaginary intervention dates
impact_imaginary <- CausalImpact(data_zoo, pre.period, post.period, model.args = list(niter = 30000, nseasons = 12)) # nseasons = 12 for monthly data

# Summarize and plot the results
summary(impact_imaginary)
plot(impact_imaginary)
summary(impact, "report")











##Looped analysis, need summary stats and testing on each approach. Need a flag for statistically significance. 
#could consider grouping at ICB level 
# Import Data (surgical stops at 174)
con <- dbConnect(odbc::odbc(), "UDAL_Warehouse")
data <- dbGetQuery(con, "
SELECT Organisation_Code AS Provider_Code,
    Treatment_Function_Code AS T_Code,
    Number_Of_Weeks_Since_Referral AS Weeks,
    Number_Of_Incomplete_Pathways AS IP, 
    Number_Of_Incomplete_Pathways_with_DTA AS IPDTA, 
    Effective_Snapshot_Date AS Date
FROM UDAL_Warehouse.UKHF_RTT.Incomplete_Pathways_Provider1_1
WHERE Effective_Snapshot_Date >= '2021-04-30' AND Effective_Snapshot_Date < '2023-10-01'
    AND Organisation_Code IN ('R0B','R0D','R1F','R1H','R1K','RA2','RA7','RA9','RAJ','RAL','RAN','RAP','RAS','RAX','RBD','RBK','RBL','RBN','RBQ','RBS','RBT','RBV','RC9','RCB','RCD','RCU','RCX','RD1','RD8','RDE','RDU','REF','REM','REN','REP','RET','RF4','RFF','RFR','RFS','RGM','RGN','RGP','RGR','RGT','RHM','RHQ','RHU','RHW','RJ2','RJ6','RJ7','RJC','RJE','RJL','RJN','RJZ','RK5','RK9','RKB','RKE','RL1','RL4','RLQ','RLT','RM1','RMC','RMP','RN3','RN5','RN7','RNA','RNN','RNQ','RNS','RNZ','RP4','RP5','RP6','RPA','RPC','RPY','RQ3','RQM','RQW','RQX','RR7','RRF','RRJ','RRK','RRV','RTD','RTE','RTF','RTG','RTH','RTK','RTP','RTR','RTX','RVJ','RVR','RVV','RVW','RVY','RWA','RWD','RWE','RWF','RWG','RWH','RWJ','RWP','RWW','RX1','RXC','RXK','RXL','RXN','RXP','RXQ','RXR','RXW','RYJ')
    AND Number_Of_Weeks_Since_Referral IN ('>23-24','>54-55','>61-62')
    AND Treatment_Function_Code IN('100','101','102','103','104','105','106','107','108','109','110','111','113','115','120','130','140','141','143','144','145','149','150','160','161','170','172','173','174',
    '180','190','191','192','200','300','301','302','303','304','305','306','307','308','309','310','311','312','313','314','315','316','317','318','319','320','322','323','324','325','326','327','328','329','330','331','333','335','340','341','342','343','344','345','346','347','348','350','352','360','361','370','371','400','401','410','420','422','424','430','431','450','451','460','461','500','501','502','503','504','505','510','520','600','610','620','834')
")

#Working Loop (need to amend to split by treatment and medical specialty)

# Assuming `data` has been loaded from your database query
library(dplyr)
library(zoo)
library(CausalImpact)
library(openxlsx)

# Categorize data into 'Surgical' or 'Medical' based on Treatment Function Code
data <- data %>%
  mutate(Specialty = ifelse(as.numeric(T_Code) <= 174, "Surgical", "Medical"))

# Initialize results DataFrame
results_df <- data.frame(Provider = character(),
                         Weeks = character(),
                         Specialty = character(),
                         RelEffectAvg = numeric(),
                         CI_Lower = numeric(),
                         CI_Upper = numeric(),
                         SS = numeric(), # Add SS column
                         stringsAsFactors = FALSE)

# Extract unique values
provider_codes <- unique(data$Provider_Code)
weeks_filters <- unique(data$Weeks)
specialties <- c("Surgical", "Medical")

# Loop through combinations of providers, weeks, and specialties
for (provider in provider_codes) {
  for (weeks in weeks_filters) {
    for (specialty in specialties) {
      # Filter and aggregate data for the current combination
      data_final <- data %>%
        filter(Provider_Code == provider, Weeks == weeks, Specialty == specialty) %>%
        group_by(Date, Specialty) %>%
        summarise(IP = sum(IP, na.rm = TRUE), .groups = "drop") %>%
        arrange(Date)
      
      # Check for sufficient data
      if (nrow(data_final) > 1 && var(data_final$IP, na.rm = TRUE) != 0) {
        data_zoo <- zoo(data_final$IP, order.by = as.Date(data_final$Date))
        pre.period <- as.Date(c("2021-04-30", "2023-03-31"))
        post.period <- as.Date(c("2023-04-01", "2023-09-30"))
        
        # Perform CausalImpact analysis
        impact <- CausalImpact(data_zoo, pre.period, post.period, model.args = list(niter = 1000, nseasons = 12))
        
        if (!is.null(impact) && !is.null(impact$summary)) {
          rel_effect_avg <- impact$summary$RelEffect[1] * 100
          ci_lower_avg <- impact$summary$RelEffect.lower[1] * 100
          ci_upper_avg <- impact$summary$RelEffect.upper[1] * 100
          # Calculate SS flag
          ss_flag <- ifelse(ci_lower_avg * ci_upper_avg > 0, 1, 0)
        } else {
          rel_effect_avg <- NA
          ci_lower_avg <- NA
          ci_upper_avg <- NA
          ss_flag <- NA # Handle case where CausalImpact fails
        }
        
        # Append to results DataFrame
        results_df <- rbind(results_df, data.frame(
          Provider = provider,
          Weeks = weeks,
          Specialty = specialty,
          RelEffectAvg = rel_effect_avg,
          CI_Lower = ci_lower_avg,
          CI_Upper = ci_upper_avg,
          SS = ss_flag
        ))
      } else {
        cat("Skipping due to insufficient data or constant series: Provider =", provider, ", Weeks =", weeks, ", Specialty =", specialty, "\n")
      }
    }
  }
}

# Save the results to an Excel file
write.xlsx(results_df, "outputs//Main_ERF//CausalImpact_TestResults.xlsx")
























