# Set Working Directory
setwd("C:/Users/toby_lowton/Documents/ERF_Project")

# Load necessary R packages for the analysis
library(tidyr)
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
library(fastDummies)

#Import Data
con <- dbConnect(odbc::odbc(), "UDAL_Warehouse")
data <- dbGetQuery(con, "
SELECT Organisation_Code AS Provider_Code,
    Number_Of_Weeks_Since_Referral AS Weeks,
    Number_Of_Incomplete_Pathways AS IP, 
    Number_Of_Incomplete_Pathways_with_DTA AS IPDTA, 
    Effective_Snapshot_Date AS Date
FROM UDAL_Warehouse.UKHF_RTT.Incomplete_Pathways_Provider1_1
WHERE Effective_Snapshot_Date >= '2021-04-01' AND Effective_Snapshot_Date < '2023-10-01' 
    AND Organisation_Code IN ('R0B','R0D','R1F','R1H','R1K','RA2','RA7','RA9','RAJ','RAL','RAN','RAP','RAS','RAX','RBD','RBK','RBL','RBN','RBQ','RBS','RBT','RBV','RC9','RCB','RCD','RCU','RCX','RD1','RD8','RDE','RDU','REF','REM','REN','REP','RET','RF4','RFF','RFR','RFS','RGM','RGN','RGP','RGR','RGT','RHM','RHQ','RHU','RHW','RJ2','RJ6','RJ7','RJC','RJE','RJL','RJN','RJZ','RK5','RK9','RKB','RKE','RL1','RL4','RLQ','RLT','RM1','RMC','RMP','RN3','RN5','RN7','RNA','RNN','RNQ','RNS','RNZ','RP4','RP5','RP6','RPA','RPC','RPY','RQ3','RQM','RQW','RQX','RR7','RRF','RRJ','RRK','RRV','RTD','RTE','RTF','RTG','RTH','RTK','RTP','RTR','RTX','RVJ','RVR','RVV','RVW','RVY','RWA','RWD','RWE','RWF','RWG','RWH','RWJ','RWP','RWW','RX1','RXC','RXK','RXL','RXN','RXP','RXQ','RXR','RXW','RYJ')
    AND Number_Of_Weeks_Since_Referral IN ('>23-24','>54-55','>61-62')
")

# Disconnect connection and set up dataset
dbDisconnect(con)
rm(con)

filtered_data <- data %>%
  filter(Weeks == ">61-62")

# Calculate Total IP per Date
provider_ip_per_date <- filtered_data %>%
  group_by(Date, Provider_Code) %>%
  summarise(Provider_IP = sum(IP, na.rm = TRUE), .groups = 'drop')

total_ip_per_date <- provider_ip_per_date %>%
  group_by(Date) %>%
  summarise(Total_IP = sum(Provider_IP, na.rm = TRUE))

provider_contributions <- provider_ip_per_date %>%
  left_join(total_ip_per_date, by = "Date") %>%
  mutate(Proportion = Provider_IP / Total_IP)

provider_proportions <- provider_contributions %>%
  select(Date, Provider_Code, Proportion) %>%
  pivot_wider(names_from = Provider_Code, values_from = Proportion, values_fill = list(Proportion = 0)) %>%
  left_join(total_ip_per_date, by = "Date")

# Identify the provider with the largest contribution
provider_sums <- colSums(provider_proportions[, -which(names(provider_proportions) %in% c("Date", "Total_IP"))], na.rm = TRUE)
provider_to_exclude <- names(which.max(provider_sums))
cat("Excluding provider:", provider_to_exclude, "\n")

# Prepare xreg excluding the selected provider
xreg_columns_to_keep <- setdiff(names(provider_proportions), c("Date", "Total_IP", provider_to_exclude))
xreg <- as.matrix(provider_proportions[, xreg_columns_to_keep])

# Assuming the rest of your setup is correct and ip_ts is already defined
start_date <- as.Date("2021-04-30") 
end_date <- as.Date("2023-09-30") 
dates <- seq.Date(from = start_date, to = end_date, by = "month")
dates <- ceiling_date(dates, "month") - days(1)
ip_ts <- ts(provider_proportions$Total_IP, start=c(2021, 4), frequency=12)
int_date <- as.Date("2023-04-30")
ce <- CausalArima(y = ip_ts, dates = dates, int.date = int_date, xreg = xreg, nboot = 1000)
















###WORKING CODE DON#t AMEND


# Disconect connection and set up dataset
dbDisconnect(con)
rm(con)
data <- dummy_cols(data, select_columns = "Provider_Code", remove_selected_columns = TRUE)
filtered_data <- data %>%
  filter(Weeks == ">61-62") %>%
  group_by(Date) %>%
  summarise(IP = sum(IPDTA, na.rm = TRUE), .groups = "drop") %>% # Correct placement of .groups argument
  arrange(Date) 


# C-Arima Analysis
start_date <- as.Date("2021-04-30") 
end_date <- as.Date("2023-09-30") 
dates <- seq.Date(from = start_date, to = end_date, by = "month")
dates <- ceiling_date(dates, "month") - days(1)
ip_ts <- ts(provider_proportions$Total_IP, start=c(2021, 4), frequency=12)
int_date <- as.Date("2023-04-30")
xreg <- as.matrix(provider_proportions[, !(names(provider_proportions) %in% c("Date", "Total_IP"))])
ce <- CausalArima(y = ip_ts, dates = dates, int.date = int_date, xreg = xreg, nboot = 1000)

ce <- CausalArima(y = ip_ts, dates = dates, int.date = int_date, xreg ="ROB", nboot = 1000)
forecasted<-plot(ce, type="forecast")
forecasted
impact_p<-plot(ce, type="impact")
grid.arrange(impact_p$plot, impact_p$cumulative_plot)
summary(ce)
summary_model<-impact(ce, format="html")
summary_model$arima
summary_model$impact_norm
summary_model$impact_boot
residuals<-plot(ce, type="residuals")
grid.arrange(residuals$ACF, residuals$PACF, residuals$QQ_plot)
forecasted_2<-plot(ce, type="forecast", fill_colour="orange",
                   colours=c("red", "blue"))
forecasted_2
forecasted_2+theme_wsj()


#Testing of the filtered dataset
result <- adf.test(filtered_data$IP)
print(result)

auto_arima_model <- auto.arima(filtered_data$IP)
print(summary(auto_arima_model))


