# Set Working Directory and run packages
setwd("C:/Users/toby_lowton/Documents/ERF_Project")
library(tidyr)
library(dplyr)
library(zoo)
library(lubridate)
library(DBI)
library(readr)
library(openxlsx)
library(CausalArima)
library(forecast)
library(ggplot2)
library(gridExtra)
library(ggthemes)

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
AND Weeks IN ('>0-1', '>1-2', '>2-3', '>3-4', '>4-5', '>5-6', '>6-7', '>7-8', '>8-9', '>9-10',
                '>10-11', '>11-12', '>12-13', '>13-14', '>14-15', '>15-16', '>16-17', '>17-18', '>18-19', '>19-20',
                '>20-21', '>21-22', '>22-23', '>23-24', '>24-25', '>25-26', '>26-27', '>27-28', '>28-29', '>29-30',
                '>30-31', '>31-32', '>32-33', '>33-34', '>34-35', '>35-36', '>36-37', '>37-38', '>38-39', '>39-40',
                '>40-41', '>41-42', '>42-43', '>43-44', '>44-45', '>45-46', '>46-47', '>47-48', '>48-49', '>49-50',
                '>50-51', '>51-52', '>52-53', '>53-54', '>54-55', '>55-56', '>56-57', '>57-58', '>58-59', '>59-60',
                '>60-61', '>61-62', '>62-63', '>63-64', '>64-65', '>65-66', '>66-67', '>67-68', '>68-69', '>69-70',
                '>70-71', '>71-72', '>72-73', '>73-74', '>74-75', '>75-76', '>76-77', '>77-78', '>78-79', '>79-80',
                '>80-81', '>81-82', '>82-83', '>83-84', '>84-85', '>85-86', '>86-87', '>87-88', '>88-89', '>89-90',
                '>90-91', '>91-92', '>92-93', '>93-94', '>94-95', '>95-96', '>96-97', '>97-98', '>98-99', '>99-100',
                '>100-101', '>101-102', '>102-103', '>103-104', '>104')
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

##Collapse data (I will later need to amend this to create a loop for each setting)
collapsed_data <- data %>%
  group_by(Date) %>%
  summarise(
    TotalPatientCount = sum(PatientCount, na.rm = TRUE),
    AvgBedOcc = mean(BedOcc, na.rm = TRUE)
  ) %>%
  ungroup()

# Convert your outcome variable and covariate to a time series object
# Assuming monthly data, starting from your data's start date
start_year <- format(min(collapsed_data$Date), "%Y")
start_month <- format(min(collapsed_data$Date), "%m")
y <- ts(collapsed_data$TotalPatientCount, start = c(as.numeric(start_year), as.numeric(start_month)), frequency = 12)
xreg <- as.matrix(collapsed_data$AvgBedOcc)

# Define the intervention date and find its position in your time series
int.date <- as.Date("2023-04-01")

# Fit the CausalArima model
ce <- CausalArima(y = y, 
                  dates = collapsed_data$Date, 
                  int.date = int.date,
                  xreg = xreg, 
                  nboot = 1000)

forecasted<-plot(ce, type="forecast")
forecasted
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
forecasted+theme_wsj()










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


