#Combined Analysis

# Library Management and WD
pacman::p_load(tidyr, dplyr, CausalImpact, zoo, lubridate, DBI, readr, openxlsx, htmlTable, ggplot2, gridExtra, CausalArima)
setwd("C:/Users/toby_lowton/Documents/ERF_Project")

## Importing of all data, including covariates
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

##Number of incomplete pathways
Incomplete <- dbGetQuery(con, "
Select Number_Of_Incomplete_Pathways AS IP,
    Organisation_Code AS Provider_Code,
    Number_Of_Weeks_Since_Referral AS Weeks,
    Treatment_Function_Code AS T_Code,
    Effective_Snapshot_Date AS Date
From UDAL_Warehouse.UKHF_RTT.Incomplete_Pathways_Provider1_1
WHERE Effective_Snapshot_Date >= '2021-09-30' AND Effective_Snapshot_Date < '2023-10-01'
AND Number_Of_Weeks_Since_Referral IN ('>0-1', '>1-2', '>2-3', '>3-4', '>4-5', '>5-6', '>6-7', '>7-8', '>8-9', '>9-10',
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
AND Organisation_Code IN ('RCF','RAE','RWY','RR8','RXF')
AND Treatment_Function_Code IN ('100','101','102','103','104','105','106','107','108','109','110','111','113','115','120','130','140','141','143','144','145','149','150','160','161','170','172','173','174',
    '180','190','191','192','200','300','301','302','303','304','305','306','307','308','309','310','311','312','313','314','315','316','317','318','319','320','322','323','324','325','326','327','328','329','330','331','333','335','340','341','342','343','344','345','346','347','348','350','352','360','361','370','371','400','401','410','420','422','424','430','431','450','451','460','461','500','501','502','503','504','505','510','520','600','610','620','834')
")

#New RTT Clockstarts
NewRTT <- dbGetQuery(con, "
Select Number_Of_New_RTT_Clock_Starts_In_Month AS NEWRTT,
    Organisation_Code AS Provider_Code,
    Treatment_Function_Code AS T_Code,
    Effective_Snapshot_Date AS Date
From UDAL_Warehouse.UKHF_RTT.New_Data_Items_Provider1_1
WHERE Effective_Snapshot_Date >= '2021-09-30' AND Effective_Snapshot_Date < '2023-10-01'
AND Organisation_Code IN ('RCF','RAE','RWY','RR8','RXF')
AND Treatment_Function_Code IN ('100','101','102','103','104','105','106','107','108','109','110','111','113','115','120','130','140','141','143','144','145','149','150','160','161','170','172','173','174',
    '180','190','191','192','200','300','301','302','303','304','305','306','307','308','309','310','311','312','313','314','315','316','317','318','319','320','322','323','324','325','326','327','328','329','330','331','333','335','340','341','342','343','344','345','346','347','348','350','352','360','361','370','371','400','401','410','420','422','424','430','431','450','451','460','461','500','501','502','503','504','505','510','520','600','610','620','834')
")

##Sickness rate WIP
#data3 <- dbGetQuery(con, "
#Select Top 100 *
#From UDAL_Warehouse.Reporting.ESR_ESR_Sickness_Current
#")

rm(con)  # Close the database connection

## Bed Occupancy data
Bed_Occ <- read_csv("Data_Sources/Bed_Occupancy_Data_WY.csv", col_types = cols()) %>%
  mutate(
    Date = dmy(paste("01-", Date, sep="")),
    Date = ceiling_date(Date, "month") - days(1))


####Processing

# Process main dataset
data <- data %>%
  mutate(
    Specialty = ifelse(as.numeric(T_Code) <= 174, "Surgical", "Medical"),
    Date = ceiling_date(Date, "month") - days(1),
    WeekNum = as.numeric(gsub(">[^0-9]*([0-9]+)-[0-9]+", "\\1", Weeks))
  ) %>%
  group_by(Setting, Specialty, Date) %>%
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
  ) %>%
  pivot_longer(
    cols = starts_with("Seen"),
    names_to = "Group",
    values_to = "PatientCount"
  )

#process incomplete data 
Incomplete <- Incomplete %>%
  mutate(IP = IP,
    Specialty = ifelse(as.numeric(T_Code) <= 174, "Surgical", "Medical"),
    Date = ceiling_date(Date, "month") - days(1),
    WeekNum = as.numeric(gsub(">[^0-9]*([0-9]+)-[0-9]+", "\\1", Weeks))
  ) %>%
  group_by(Specialty, Date) %>%
  summarise(
    Total = sum(IP, na.rm = TRUE),
    Over_18_weeks = sum(ifelse(WeekNum >= 18, IP, 0), na.rm = TRUE),
    Over_40_weeks = sum(ifelse(WeekNum >= 40, IP, 0), na.rm = TRUE),
    Over_51_weeks = sum(ifelse(WeekNum >= 51, IP, 0), na.rm = TRUE),
    Over_64_weeks = sum(ifelse(WeekNum >= 64, IP, 0), na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(
    Seen_within_18_weeks = Total - Over_18_weeks,
    Seen_19_to_40_weeks = Over_18_weeks - Over_40_weeks,
    Seen_41_to_51_weeks = Over_40_weeks - Over_51_weeks,
    Seen_52_to_64_weeks = Over_51_weeks - Over_64_weeks,
    Seen_after_64_weeks = Over_64_weeks
  ) %>%
  pivot_longer(
    cols = starts_with("Seen"),
    names_to = "Group",
    values_to = "IP"
  ) %>%
  select(-Total, -Over_18_weeks, -Over_40_weeks, -Over_51_weeks, -Over_64_weeks)


##Process RTT data
NewRTT <- NewRTT %>%
  mutate(Specialty = ifelse(as.numeric(T_Code) <= 174, "Surgical", "Medical"))  %>%
  select(-T_Code, -Provider_Code) %>%
  group_by(Date, Specialty) %>%
  summarise(NEWRTT = mean(NEWRTT), .groups = 'drop') 

##joining covariates to the dataset
data <- data %>%
  left_join(Bed_Occ, by = "Date") %>% 
  left_join(Incomplete, by = c("Date", "Specialty", "Group")) %>%
  left_join(NewRTT, by = c("Date", "Specialty")) 

#set up groups to loop through
groups_filters <- unique(data$Group)
settings <- c("AP", "NAP")  # Settings to loop through
specialties <- c("Medical", "Surgical")

##Set filepaths for saving
causal_arima_RC_dir <- "outputs/WY/CausalArima/Robustness_Check"
causal_arima_plot_dir <- "outputs/WY/CausalArima/Plots"
causal_arima_residual_dir <- "outputs/WY/CausalArima/Residuals"
causal_arima_html_dir <- "outputs/WY/CausalArima/HTML_Results"
causal_impact_plot_dir <- "outputs/WY/CausalImpact/Plots"
results_list <- list()


# Loop through each setting, specialty, and group, and specify time series for all models 
for (setting in settings) {
  for (specialty in specialties) {
    for (group in groups_filters) {
      subset_data <- data %>%
        filter(Setting == setting, Specialty == specialty, Group == group) 
      if (nrow(subset_data) == 0) next
      
      subset_data <- subset_data %>%
        mutate(Date = as.Date(Date)) %>%
        group_by(Date) %>%
        summarise(
          Total_PatientCount = sum(PatientCount, na.rm = TRUE),
          Total_NewRTT = sum(NEWRTT, na.rm = TRUE),
          AvgBedOcc = mean(BedOcc, na.rm = TRUE),
          Mean_IP = mean(IP, na.rm = TRUE),
          .groups = 'drop'  # Ensure the group is dropped after summarise
        )

      y <- ts(subset_data$Total_PatientCount, start = start(subset_data$Date), frequency = 12)
      xreg <- as.matrix(subset_data[, c("AvgBedOcc", "Total_NewRTT", "Mean_IP")])
      
      # Convert to zoo object for CausalImpact or other time series analysis
      subset_data$Date <- as.Date(subset_data$Date)
      data_zoo <- zoo(cbind(subset_data$Total_PatientCount, subset_data$AvgBedOcc, subset_data$Total_NewRTT, subset_data$Mean_IP), order.by = subset_data$Date)
      
      #Set intervention date
      int.date <- as.Date("2023-03-31")  # Last day of March c-arima
      pre.period <- as.Date(c("2021-09-30", "2023-03-31")) #causalimpact
      post.period <- as.Date(c("2023-04-30", "2023-09-30")) #causalimpact

      # run models
      ce <- CausalArima(y = y, dates = subset_data$Date, int.date = int.date, xreg = xreg, nboot = 1000)
      impact <- CausalImpact(data_zoo, pre.period, post.period, model.args = list(niter = 1000, nseasons = 12))

      # run plots and graphical outputs, and html table
      forecast_plot <- plot(ce, type = "forecast")
      residual_plots <- plot(ce, type = "residuals")
      summary_model <- summary(ce)
      html_content <- htmlTable(summary_model)
      RC <- summary(ce$model)
      html_content1 <- htmlTable(RC)
      
      #save plots and graphical outputs
      forecast_plot_path <- file.path(causal_arima_plot_dir, paste0(setting, "_", specialty, "_", group, "_forecast.png"))
      residual_plot_path <- file.path(causal_arima_residual_dir, paste0(setting, "_", specialty, "_", group, "_residuals.png"))
      ggsave(forecast_plot_path, plot = forecast_plot, width = 8, height = 6)
      ggsave(residual_plot_path, grid.arrange(residual_plots$ACF, residual_plots$PACF, residual_plots$QQ_plot, ncol = 3), width = 12, height = 4)
      html_file_path <- file.path(causal_arima_html_dir, paste0(setting, "_", specialty, "_", group, "_impact_boot.html"))
      writeLines(as.character(html_content), html_file_path)
      RC_plot_path <- file.path(causal_arima_RC_dir, paste0(setting, "_", specialty, "_", group, "_RC.html"))
      writeLines(as.character(html_content1), RC_plot_path)
      plot_title <- sprintf("%s_%s_%s.png", setting, specialty, gsub(" ", "_", group))
      plot_path <- file.path(causal_impact_plot_dir, plot_title)
      png(filename = plot_path, width = 800, height = 600)
      print(plot(impact))
      dev.off()
        
      # Extract analytical outputs for causalimpact model
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
      avg_total_ap_pre <- mean(subset_data$Total_PatientCount[subset_data$Date < as.Date("2023-04-30")])
      avg_total_ap_post <- mean(subset_data$Total_PatientCount[subset_data$Date >= as.Date("2023-04-30")])
      
      # Append results for casual impact model 
      results_list[[paste(setting, specialty, gsub("Patients_", "", group), sep = "_")]] <- data.frame(
        Setting = setting,
        Specialty = specialty,
        Group = group,  # Updated to use 'Group' instead of 'Week_Range'
        RelEffectAvgPercent = rel_effect_avg,
        CI_Lower = ci_lower_avg,
        CI_Upper = ci_upper_avg,
        SS_Flag = ss_flag,        
        Avg_Total_AP_Pre = avg_total_ap_pre,
        Avg_Total_AP_Post = avg_total_ap_post
      )
    }
  }
}

# Save causal impact model results
final_results_df <- bind_rows(results_list)
write.xlsx(final_results_df, "Outputs/WY/CausalImpact/Results.xlsx", rowNames = FALSE)



###Summary Statistics

# Incomplete by group over time
filtered_df <- Incomplete[Incomplete$Group == 'Seen_after_64_weeks' & Incomplete$Specialty == 'Medical', ]

# Plot
ggplot(filtered_df, aes(x = Date, y = IP)) +  # Assuming you want to plot PatientCount over Date
  geom_line() +  # Change to geom_point() if you prefer dots
  labs(title = "Patient Count Seen After 64 Weeks - Medical",
       x = "Date",
       y = "Patient Count") +
  theme_minimal()