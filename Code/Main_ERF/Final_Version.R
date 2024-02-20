# Assuming `data` has been loaded from your database query
library(dplyr)
library(zoo)
library(CausalImpact)
library(openxlsx)

con <- dbConnect(odbc::odbc(), "UDAL_Warehouse")
data <- dbGetQuery(con, "
SELECT Organisation_Code AS Provider_Code,
    Treatment_Function_Code AS T_Code,
    Number_Of_Weeks_Since_Referral AS Weeks,
    Number_Of_Completed_Admitted_Pathways AS IP, 
    Effective_Snapshot_Date AS Date
FROM UDAL_Warehouse.UKHF_RTT.Completed_Admitted_Pathways_Provider1_1
WHERE Effective_Snapshot_Date >= '2021-09-30' AND Effective_Snapshot_Date < '2023-10-01' 
    AND Organisation_Code IN ('RAJ', 'RDE', 'RGN', 'RWH', 'RJ2', 'RL4', 'RWD', 'RWP', 'RXK', 'R0B', 'RTF', 'RXR', 'RDU', 'RHU', 'RHW', 'RN5', 'RWF', 'RXC', 'REF', 'RTE', 'RVJ', 'RC9', 'RCX', 'RGR', 'RQW', 'RWG', 'RAS', 'RAX', 'RJ6', 'RBK', 'RFS', 'RK5', 'RLT', 'RNA', 'RNQ', 'RNS', 'RXW', 'RCD', 'RFF', 'RFR', 'RJL', 'RNN', 'RR7', 'RVW', 'RBT', 'RJN', 'RJR', 'RMC', 'RMP', 'RRF', 'RVY', 'RWJ', 'RA2', 'RN7', 'RPA', 'RTK', 'RTP', 'RBD', 'RD1', 'RN3', 'RNZ')
    AND Number_Of_Weeks_Since_Referral IN ('>0-1',>23-24','>54-55','>61-62')
    AND Treatment_Function_Code IN('100','101','102','103','104','105','106','107','108','109','110','111','113','115','120','130','140','141','143','144','145','149','150','160','161','170','172','173','174',
    '180','190','191','192','200','300','301','302','303','304','305','306','307','308','309','310','311','312','313','314','315','316','317','318','319','320','322','323','324','325','326','327','328','329','330','331','333','335','340','341','342','343','344','345','346','347','348','350','352','360','361','370','371','400','401','410','420','422','424','430','431','450','451','460','461','500','501','502','503','504','505','510','520','600','610','620','834')
")


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
        pre.period <- as.Date(c("2021-09-01", "2023-03-31"))
        post.period <- as.Date(c("2023-04-01", "2023-09-01"))
        
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








