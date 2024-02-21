setwd("C:/Users/toby_lowton/Documents/ERF_Project")
library(tidyr)
library(dplyr)
library(CausalImpact)
library(zoo)
library(lubridate)
library(DBI)
library(readr)
library(openxlsx)
library(htmlTable)

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

# Assuming 'data' is loaded with all required weeks and patient counts.
data$WeekNum <- as.numeric(gsub(">[^0-9]*([0-9]+)-[0-9]+", "\\1", data$Weeks))
data_grouped <- data %>%
  group_by(Setting, Specialty, Date)

# Summarize data to calculate patient counts for each time frame
data_summarized <- data_grouped %>%
  summarise(
    Total = sum(PatientCount, na.rm = TRUE),
    Over_18_weeks = sum(ifelse(WeekNum >= 18, PatientCount, 0), na.rm = TRUE),
    Over_40_weeks = sum(ifelse(WeekNum >= 40, PatientCount, 0), na.rm = TRUE),
    Over_51_weeks = sum(ifelse(WeekNum >= 51, PatientCount, 0), na.rm = TRUE),
    Over_64_weeks = sum(ifelse(WeekNum >= 64, PatientCount, 0), na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(
    Seen_within_18_weeks = Total - Over_18_weeks,
    Seen_19_to_40_weeks = Over_18_weeks - Over_40_weeks,
    Seen_41_to_51_weeks = Over_40_weeks - Over_51_weeks,
    Seen_52_to_64_weeks = Over_51_weeks - Over_64_weeks,
    Seen_after_64_weeks = Over_64_weeks
  )

data <- pivot_longer(data_summarized, 
                     cols = starts_with("Seen"), 
                     names_to = "Group", 
                     values_to = "PatientCount")

# Import bed occupancy data, set date to first of month and then join
Bed_Occ <- read_csv("Data_Sources/Bed_Occupancy_Data_WY.csv", col_types = cols())
Bed_Occ$Date <- dmy(paste("01-", Bed_Occ$Date, sep=""))
data <- left_join(data, Bed_Occ, by = c("Date"))

groups_filters <- unique(data$Group)
settings <- c("AP", "NAP")  # Settings to loop through
specialties <- c("Medical", "Surgical")


# Define directories for plots and HTML results
plot_dir <- "outputs/WY/CausalArima/Plots"
html_result_dir <- "outputs/WY/CausalArima/HTML_Results"
if (!dir.exists(plot_dir)) dir.create(plot_dir, recursive = TRUE)
if (!dir.exists(html_result_dir)) dir.create(html_result_dir, recursive = TRUE)

# Loop through each setting, specialty, and group
for (setting in settings) {
  for (specialty in specialties) {
    for (group in groups_filters) {
      subset_data <- filter(data, Setting == setting, Specialty == specialty, Group == group)
      
      if (nrow(subset_data) == 0) next
      
      start_year <- format(min(subset_data$Date), "%Y")
      start_month <- format(min(subset_data$Date), "%m")
      y <- ts(subset_data$PatientCount, start = c(as.numeric(start_year), as.numeric(start_month)), frequency = 12)
      xreg <- as.matrix(subset_data$BedOcc)
      int.date <- as.Date("2023-03-01")
      
      ce <- CausalArima(y = y, dates = subset_data$Date, int.date = int.date, xreg = xreg, nboot = 1000)
      
      # Save plots as before
      forecast_plot <- plot(ce, type = "forecast")
      forecast_plot_path <- file.path(plot_dir, paste0(setting, "_", specialty, "_", group, "_forecast.png"))
      ggsave(forecast_plot_path, plot = forecast_plot, width = 8, height = 6)
      
      # Generate and save residual plots
      residual_plots <- plot(ce, type = "residuals")
      residual_plot_path <- file.path(plot_dir, paste0(setting, "_", specialty, "_", group, "_residuals.png"))
      ggsave(residual_plot_path, grid.arrange(residual_plots$ACF, residual_plots$PACF, residual_plots$QQ_plot, ncol = 3), width = 12, height = 4)
      
      # Save the HTML output of summary_model$impact_boot
      summary_model <- summary(ce)
      html_file_path <- file.path(html_result_dir, paste0(setting, "_", specialty, "_", group, "_impact_boot.html"))
      html_content <- htmlTable(summary_model)
      writeLines(as.character(html_content), html_file_path)
    }
  }
}


##Working Example

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
summary(ce)
horizon <- as.Date(c("2021-04-01", "2023-09-01"))
print(ce, type = "boot", horizon = horizon)
summary_model<-impact(ce, format="html")
print(summary_model)
forecasted<-plot(ce, type="forecast")
forecasted+theme_wsj()
impact_p<-plot(ce, type="impact")
grid.arrange(impact_p$plot, impact_p$cumulative_plot)
summary(ce)
summary_model<-impact(ce, format="html")
summary_model$arima
summary_model$impact_norm
summary_model$impact_boot
residuals<-plot(ce, type="residuals")
grid.arrange(residuals$ACF, residuals$PACF, residuals$QQ_plot)