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


#Import Data (Analysis includes only small medium large acute trusts for comparison, and excludes WY ICB trusts - this needs checking)
con <- dbConnect(odbc::odbc(), "UDAL_Warehouse")
data <- dbGetQuery(con, "
SELECT Organisation_Code AS Provider_Code,
    Treatment_Function_Code AS T_Code,
    Number_Of_Weeks_Since_Referral AS Weeks,
    Number_Of_Completed_NonAdmitted_Pathways AS IP, 
    Effective_Snapshot_Date AS Date
FROM UDAL_Warehouse.UKHF_RTT.Completed_NonAdmitted_Pathways_Provider1_1
WHERE Effective_Snapshot_Date >= '2021-09-30' AND Effective_Snapshot_Date < '2023-10-01' 
    AND Organisation_Code IN ('RAJ', 'RDE', 'RGN', 'RWH', 'RJ2', 'RL4', 'RWD', 'RWP', 'RXK', 'R0B', 'RTF', 'RXR', 'RDU', 'RHU', 'RHW', 'RN5', 'RWF', 'RXC', 'REF', 'RTE', 'RVJ', 'RC9', 'RCX', 'RGR', 'RQW', 'RWG', 'RAS', 'RAX', 'RJ6', 'RBK', 'RFS', 'RK5', 'RLT', 'RNA', 'RNQ', 'RNS', 'RXW', 'RCD', 'RFF', 'RFR', 'RJL', 'RNN', 'RR7', 'RVW', 'RBT', 'RJN', 'RJR', 'RMC', 'RMP', 'RRF', 'RVY', 'RWJ', 'RA2', 'RN7', 'RPA', 'RTK', 'RTP', 'RBD', 'RD1', 'RN3', 'RNZ')
    AND Number_Of_Weeks_Since_Referral IN ('>0-1','>23-24','>54-55','>61-62')
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
  filter(Weeks == '>0-1') %>%
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

## Look at proportional impact (as no overall change in absolute numbers of cases)
