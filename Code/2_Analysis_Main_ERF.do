*Set WD
cd "C:\Users\toby_lowton\Documents\ERF_Project"

* Provider RJR dropped from control set due to missing Total data (excludes WY ICB acute providers)
***Data Importing Code 
clear
#delim ;
odbc load, exec(`"
Select Provider_Org_Code AS Provider_Code,
RTT_Part_Description AS Stage,
Treatment_Function_Code AS T_Code,
Effective_Snapshot_Date AS Date,
Gt_00_To_01_Weeks AS "0_1",
Gt_01_To_02_Weeks AS "1_2",
Gt_02_To_03_Weeks AS "2_3",
Gt_03_To_04_Weeks AS "3_4",
Gt_04_To_05_Weeks AS "4_5",
Gt_05_To_06_Weeks AS "5_6",
Gt_06_To_07_Weeks AS "6_7",
Gt_07_To_08_Weeks AS "7_8",
Gt_08_To_09_Weeks AS "8_9",
Gt_09_To_10_Weeks AS "9_10",
Gt_10_To_11_Weeks AS "10_11",
Gt_11_To_12_Weeks AS "11_12",
Gt_12_To_13_Weeks AS "12_13",
Gt_13_To_14_Weeks AS "13_14",
Gt_14_To_15_Weeks AS "14_15",
Gt_15_To_16_Weeks AS "15_16",
Gt_16_To_17_Weeks AS "16_17",
Gt_17_To_18_Weeks AS "17_18",
Gt_18_To_19_Weeks AS "18_19",
Gt_19_To_20_Weeks AS "19_20",
Gt_20_To_21_Weeks AS "20_21",
Gt_21_To_22_Weeks AS "21_22",
Gt_22_To_23_Weeks AS "22_23",
Gt_23_To_24_Weeks AS "23_24",
Gt_24_To_25_Weeks AS "24_25",
Gt_25_To_26_Weeks AS "25_26",
Gt_26_To_27_Weeks AS "26_27",
Gt_27_To_28_Weeks AS "27_28",
Gt_28_To_29_Weeks AS "28_29",
Gt_29_To_30_Weeks AS "29_30",
Gt_30_To_31_Weeks AS "30_31",
Gt_31_To_32_Weeks AS "31_32",
Gt_32_To_33_Weeks AS "32_33",
Gt_33_To_34_Weeks AS "33_34",
Gt_34_To_35_Weeks AS "34_35",
Gt_35_To_36_Weeks AS "35_36",
Gt_36_To_37_Weeks AS "36_37",
Gt_37_To_38_Weeks AS "37_38",
Gt_38_To_39_Weeks AS "38_39",
Gt_39_To_40_Weeks AS "39_40",
Gt_40_To_41_Weeks AS "40_41",
Gt_41_To_42_Weeks AS "41_42",
Gt_42_To_43_Weeks AS "42_43",
Gt_43_To_44_Weeks AS "43_44",
Gt_44_To_45_Weeks AS "44_45",
Gt_45_To_46_Weeks AS "45_46",
Gt_46_To_47_Weeks AS "46_47",
Gt_47_To_48_Weeks AS "47_48",
Gt_48_To_49_Weeks AS "48_49",
Gt_49_To_50_Weeks AS "49_50",
Gt_50_To_51_Weeks AS "50_51",
Gt_51_To_52_Weeks AS "51_52",
Gt_52_Weeks AS "52",
Gt_52_To_53_Weeks AS "52_53",
Gt_53_To_54_Weeks AS "53_54",
Gt_54_To_55_Weeks AS "54_55",
Gt_55_To_56_Weeks AS "55_56",
Gt_56_To_57_Weeks AS "56_57",
Gt_57_To_58_Weeks AS "57_58",
Gt_58_To_59_Weeks AS "58_59",
Gt_59_To_60_Weeks AS "59_60",
Gt_60_To_61_Weeks AS "60_61",
Gt_61_To_62_Weeks AS "61_62",
Gt_62_To_63_Weeks AS "62_63",
Gt_63_To_64_Weeks AS "63_64",
Gt_64_To_65_Weeks AS "64_65",
Gt_65_To_66_Weeks AS "65_66",
Gt_66_To_67_Weeks AS "66_67",
Gt_67_To_68_Weeks AS "67_68",
Gt_68_To_69_Weeks AS "68_69",
Gt_69_To_70_Weeks AS "69_70",
Gt_70_To_71_Weeks AS "70_71",
Gt_71_To_72_Weeks AS "71_72",
Gt_72_To_73_Weeks AS "72_73",
Gt_73_To_74_Weeks AS "73_74",
Gt_74_To_75_Weeks AS "74_75",
Gt_75_To_76_Weeks AS "75_76",
Gt_76_To_77_Weeks AS "76_77",
Gt_77_To_78_Weeks AS "77_78",
Gt_78_To_79_Weeks AS "78_79",
Gt_79_To_80_Weeks AS "79_80",
Gt_80_To_81_Weeks AS "80_81",
Gt_81_To_82_Weeks AS "81_82",
Gt_82_To_83_Weeks AS "82_83",
Gt_83_To_84_Weeks AS "83_84",
Gt_84_To_85_Weeks AS "84_85",
Gt_85_To_86_Weeks AS "85_86",
Gt_86_To_87_Weeks AS "86_87",
Gt_87_To_88_Weeks AS "87_88",
Gt_88_To_89_Weeks AS "88_89",
Gt_89_To_90_Weeks AS "89_90",
Gt_90_To_91_Weeks AS "90_91",
Gt_91_To_92_Weeks AS "91_92",
Gt_92_To_93_Weeks AS "92_93",
Gt_93_To_94_Weeks AS "93_94",
Gt_94_To_95_Weeks AS "94_95",
Gt_95_To_96_Weeks AS "95_96",
Gt_96_To_97_Weeks AS "96_97",
Gt_97_To_98_Weeks AS "97_98",
Gt_98_To_99_Weeks AS "98_99",
Gt_99_To_100_Weeks AS "99_100",
Gt_100_To_101_Weeks AS "100_101",
Gt_101_To_102_Weeks AS "101_102",
Gt_102_To_103_Weeks AS "102_103",
Gt_103_To_104_Weeks AS "103_104",
Gt_104_Weeks AS "104",
Total
FROM UDAL_Warehouse.UKHF_RTT.Full_Dataset1_1
WHERE Effective_Snapshot_Date >= '2021-04-01' AND Effective_Snapshot_Date < '2023-10-01' 
AND Provider_Org_Code IN ('R0B','R0D','R1F','R1H','R1K','RA2','RA7','RA9','RAJ','RAL','RAN','RAP','RAS','RAX','RBD','RBK','RBL','RBN','RBQ','RBS','RBT','RBV','RC9','RCB','RCD','RCU','RCX','RD1','RD8','RDE','RDU','REF','REM','REN','REP','RET','RF4','RFF','RFR','RFS','RGM','RGN','RGP','RGR','RGT','RHM','RHQ','RHU','RHW','RJ2','RJ6','RJ7','RJC','RJE','RJL','RJN','RJZ','RK5','RK9','RKB','RKE','RL1','RL4','RLQ','RLT','RM1','RMC','RMP','RN3','RN5','RN7','RNA','RNN','RNQ','RNS','RNZ','RP4','RP5','RP6','RPA','RPC','RPY','RQ3','RQM','RQW','RQX','RR7','RRF','RRJ','RRK','RRV','RTD','RTE','RTF','RTG','RTH','RTK','RTP','RTR','RTX','RVJ','RVR','RVV','RVW','RVY','RWA','RWD','RWE','RWF','RWG','RWH','RWJ','RWP','RWW','RX1','RXC','RXK','RXL','RXN','RXP','RXQ','RXR','RXW','RYJ')
"')
dsn(UDAL_Warehouse);
#delimit cr;
compress

* Create flags for different time periods and drop unnecesarry columns. Create monthly variable.
egen Under_24_Weeks = rowtotal(var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16 var17 var18 var19 var20 var21 var22 var23 var24 var25 var26 var27 var28)

egen Over_52_Weeks = rowtotal(var58 var59 var60 var61 var62 var63 var64 var65 var66 var67 var68 var69 var70 var71 var72 var73 var74 var75 var76 var77 var78 var79 var80 var81 var82 var83 var84 var85 var86 var87 var88 var89 var90 var91 var92 var93 var94 var95 var96 var97 var98 var99 var100 var101 var102 var103 var104 var105 var106 var107 var108 var109 var110)

egen Over_65_Weeks = rowtotal(var71 var72 var73 var74 var75 var76 var77 var78 var79 var80 var81 var82 var83 var84 var85 var86 var87 var88 var89 var90 var91 var92 var93 var94 var95 var96 var97 var98 var99 var100 var101 var102 var103 var104 var105 var106 var107 var108 var109 var110)

*Understand why total isn't provided for incomplete pathways
egen Total_Manual = rowtotal(var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16 var17 var18 var19 var20 var21 var22 var23 var24 var25 var26 var27 var28 var29 var30 var31 var32 var33 var34 var35 var36 var37 var38 var39 var40 var41 var42 var43 var44 var45 var46 var47 var48 var49 var50 var51 var52 var53 var54 var55 var56 var58 var59 var60 var61 var62 var63 var64 var65 var66 var67 var68 var69 var70 var71 var72 var73 var74 var75 var76 var77 var78 var79 var80 var81 var82 var83 var84 var85 var86 var87 var88 var89 var90 var91 var92 var93 var94 var95 var96 var97 var98 var99 var100 var101 var102 var103 var104 var105 var106 var107 var108 var109 var110)

drop var5 var6 var7 var8 var9 var10 var11 var12 var13 var14 var15 var16 var17 var18 var19 var20 var21 var22 var23 var24 var25 var26 var27 var28 var29 var30 var31 var32 var33 var34 var35 var36 var37 var38 var39 var40 var41 var42 var43 var44 var45 var46 var47 var48 var49 var50 var51 var52 var53 var54 var55 var56 var58 var59 var60 var61 var62 var63 var64 var65 var66 var67 var68 var69 var70 var71 var72 var73 var74 var75 var76 var77 var78 var79 var80 var81 var82 var83 var84 var85 var86 var87 var88 var89 var90 var91 var92 var93 var94 var95 var96 var97 var98 var99 var100 var101 var102 var103 var104 var105 var106 var107 var108 var109 var110 var57

gen Yearmonth = mofd(Date)
format Yearmonth %tm
drop Date
drop if Stage == "New RTT Periods - All Patients"

*Set up SDID analysis and balance panel
collapse (sum) Under_24_Weeks Over_52_Weeks Over_65_Weeks Total Total_Manual, by(Provider_Code Stage Yearmonth)
set seed 12345
egen group = group(Provider_Code)
gen random_number = runiform() if group != .
sort random_number
gen half = _N/2
gen WY = (_n <= half)
gen ERF_Flag = cond(WY == 1, date("04/01/2023", "MDY"), date("02/02/2222", "MDY"))
format ERF_Flag %tdnn/dd/CCYY
drop random_number half group
format ERF_Flag %tdnn/dd/CCYY
format ERF_Flag %tdDMCY
gen ERF_Flag1 = mofd(ERF_Flag) 
format ERF_Flag1 %tm
drop ERF_Flag
rename ERF_Flag1 ERF_Flag
rename Yearmonth Calendar_Month
encode Provider_Code, gen(Group_ID)
gen Group_Var = cond(WY == 1, ERF_Flag, 0)
gen Event_Time = cond(WY == 1, Calendar_Month - Group_Var, 0)
gen Treated = cond(WY == 1 & Event_Time >= 0, 1, 0)

*generate additional dependent variables (Proportional variables only possible for completed pathways)
gen Under_24_Weeks_Prop = Under_24_Weeks/Total
gen Under_24_Weeks_Prop_Manual = Under_24_Weeks/Total_Manual
gen Over_52_Weeks_Prop = Over_52_Weeks/Total
gen Over_52_Weeks_Prop_Manual = Over_52_Weeks/Total_Manual
gen Over_65_Weeks_Prop = Over_65_Weeks/Total
gen Over_65_Weeks_Prop_Manual = Over_65_Weeks/Total_Manual

* SDID Analysis
local excelPath "Outputs/Main_ERF/SDID_Results_Non_Admitted_Pathways.xlsx"
putexcel set "`excelPath'", modify
putexcel A1 = "DepVar" B1 = "ATT" C1 = "SE" D1 = "Lower CI" E1 = "Upper CI" F1 = "SS"
local row = 2
preserve
keep if Stage == "Completed Pathways For Non-Admitted Patients"
gen Flag1 = 1
bysort Provider_Code: egen Flag2 = sum(Flag1)
qui sum Flag2
keep if Flag2 == r(max)
local depvars Under_24_Weeks_Prop Over_52_Weeks_Prop Over_65_Weeks_Prop
foreach depvar in `depvars' {
    capture sdid `depvar' Group_ID Calendar_Month Treated, vce(bootstrap) seed(123456) reps(1000) graph
        if _rc == 0 {
            local att = e(ATT)
            local se = e(se)
            putexcel A`row' = "`depvar'" B`row' = `att' C`row' = `se' ///
             D`row' = formula("=B`row' - (1.96 * C`row')") E`row' = formula("=B`row' + (1.96 * C`row')") F`row' = formula("=IF(AND(D`row' > 0, E`row' > 0), 1, IF(AND(D`row' < 0, E`row' < 0), 1, 0))")
            local row = `row' + 1
            graph export "Outputs/Main_ERF/SDID_Results_Non_Admitted_Pathways_`depvar'.png", replace
        }
        else {
            display "sdid failed for DepVar=`depvar'. Skipping..."
        }
    }
	
	
putexcel save
restore

* Initialize Excel file path and headers
local excelPath "Outputs/Main_ERF/SDID_Results_Admitted_Pathways.xlsx"
putexcel set "`excelPath'", modify
putexcel A1 = "DepVar" B1 = "ATT" C1 = "SE" D1 = "Lower CI" E1 = "Upper CI" F1 = "SS"
local row = 2
preserve
keep if Stage == "Completed Pathways For Admitted Patients"
gen Flag1 = 1
bysort Provider_Code: egen Flag2 = sum(Flag1)
qui sum Flag2
keep if Flag2 == r(max)
local depvars Under_24_Weeks_Prop Over_52_Weeks_Prop Over_65_Weeks_Prop
foreach depvar in `depvars' {
    capture sdid `depvar' Group_ID Calendar_Month Treated, vce(bootstrap) seed(123456) reps(10) graph
        if _rc == 0 {
            local att = e(ATT)
            local se = e(se)
            putexcel A`row' = "`depvar'" B`row' = `att' C`row' = `se' ///
             D`row' = formula("=B`row' - (1.96 * C`row')") E`row' = formula("=B`row' + (1.96 * C`row')") F`row' = formula("=IF(AND(D`row' > 0, E`row' > 0), 1, IF(AND(D`row' < 0, E`row' < 0), 1, 0))")
            local row = `row' + 1
            graph export "Outputs/Main_ERF/SDID_Results_Admitted_Pathways_`depvar'.png", replace
        }
        else {
            display "sdid failed for DepVar=`depvar'. Skipping..."
        }
    }
putexcel save
restore

* Initialize Excel file path and headers
local excelPath "Outputs/Main_ERF/SDID_Results_Incomplete_Pathways.xlsx"
putexcel set "`excelPath'", modify
putexcel A1 = "DepVar" B1 = "ATT" C1 = "SE" D1 = "Lower CI" E1 = "Upper CI" F1 = "SS"
local row = 2
preserve
keep if Stage == "Incomplete Pathways"
gen Flag1 = 1
bysort Provider_Code: egen Flag2 = sum(Flag1)
qui sum Flag2
keep if Flag2 == r(max)
local depvars Under_24_Weeks_Prop_Manual Over_52_Weeks_Prop_Manual Over_65_Weeks_Prop_Manual
foreach depvar in `depvars' {
    capture sdid `depvar' Group_ID Calendar_Month Treated, vce(bootstrap) seed(123456) reps(10) graph
        if _rc == 0 {
            local att = e(ATT)
            local se = e(se)
            putexcel A`row' = "`depvar'" B`row' = `att' C`row' = `se' ///
             D`row' = formula("=B`row' - (1.96 * C`row')") E`row' = formula("=B`row' + (1.96 * C`row')") F`row' = formula("=IF(AND(D`row' > 0, E`row' > 0), 1, IF(AND(D`row' < 0, E`row' < 0), 1, 0))")
            local row = `row' + 1
            graph export "Outputs/Main_ERF/SDID_Results_Incomplete_Pathways_`depvar'.png", replace
        }
        else {
            display "sdid failed for DepVar=`depvar'. Skipping..."
        }
    }
putexcel save
restore

* Initialize Excel file path and headers
local excelPath "Outputs/Main_ERF/SDID_Results_Incomplete_Pathways_DTA.xlsx"
putexcel set "`excelPath'", modify
putexcel A1 = "DepVar" B1 = "ATT" C1 = "SE" D1 = "Lower CI" E1 = "Upper CI" F1 = "SS"
local row = 2
preserve
keep if Stage == "Incomplete Pathways with DTA"
gen Flag1 = 1
bysort Provider_Code: egen Flag2 = sum(Flag1)
qui sum Flag2
keep if Flag2 == r(max)
local depvars Under_24_Weeks_Prop_Manual Over_52_Weeks_Prop_Manual Over_65_Weeks_Prop_Manual
foreach depvar in `depvars' {
    capture sdid `depvar' Group_ID Calendar_Month Treated, vce(bootstrap) seed(123456) reps(10) graph
        if _rc == 0 {
            local att = e(ATT)
            local se = e(se)
            putexcel A`row' = "`depvar'" B`row' = `att' C`row' = `se' ///
             D`row' = formula("=B`row' - (1.96 * C`row')") E`row' = formula("=B`row' + (1.96 * C`row')") F`row' = formula("=IF(AND(D`row' > 0, E`row' > 0), 1, IF(AND(D`row' < 0, E`row' < 0), 1, 0))")
            local row = `row' + 1
            graph export "Outputs/Main_ERF/SDID_Results_Incomplete_Pathways_DTA_`depvar'.png", replace
        }
        else {
            display "sdid failed for DepVar=`depvar'. Skipping..."
        }
    }
putexcel save
restore


*CSA Analysis
preserve
keep if Stage == "Completed Pathways For Non-Admitted Patients"
gen Flag1 = 1
bysort Provider_Code: egen Flag2 = sum(Flag1)
qui sum Flag2
keep if Flag2 == r(max)
local depvars Under_24_Weeks_Prop Over_52_Weeks_Prop Over_65_Weeks_Prop
foreach depvar in `depvars' {
    * Start logging results for the current dependent variable
    log using "Outputs/Main/CSA_Non-Admitted_Pathways_`depvar'.log", replace
	csdid `depvar', time(Calendar_Month) gvar(Group_Var) ivar(Group_ID)
	estat pretrend, window(-24 -1)
	set seed 123456
    csdid `depvar', time(Calendar_Month) gvar(Group_Var) ivar(Group_ID) wboot saverif(altnh) ad csdid_stats replace
    csdid_estat event
    csdid_plot, style(rcap)
    tempfile analysisResults
    save `analysisResults', replace
    use altnh, clear
	set seed 123456
    csdid_stats event, wboot estore(event)
    graph export "Outputs/Main/CSA_Non-Admitted_Pathways_`depvar'.png", replace
    use `analysisResults', clear
    log close
}
restore
erase altnh.dta

preserve
keep if Stage == "Completed Pathways For Admitted Patients"
gen Flag1 = 1
bysort Provider_Code: egen Flag2 = sum(Flag1)
qui sum Flag2
keep if Flag2 == r(max)
local depvars Under_24_Weeks_Prop Over_52_Weeks_Prop Over_65_Weeks_Prop
foreach depvar in `depvars' {
    * Start logging results for the current dependent variable
    log using "Outputs/Main/CSA_Admitted_Pathways_`depvar'.log", replace
	csdid `depvar', time(Calendar_Month) gvar(Group_Var) ivar(Group_ID)
	estat pretrend, window(-24 -1)
	set seed 123456
    csdid `depvar', time(Calendar_Month) gvar(Group_Var) ivar(Group_ID) wboot saverif(altnh) ad csdid_stats replace
    csdid_estat event
    csdid_plot, style(rcap)
    tempfile analysisResults
    save `analysisResults', replace
    use altnh, clear
	set seed 123456
    csdid_stats event, wboot estore(event)
    graph export "Outputs/Main/CSA_Admitted_Pathways_`depvar'.png", replace
    use `analysisResults', clear
    log close
}
restore
erase altnh.dta

preserve
keep if Stage == "Incomplete Pathways"
gen Flag1 = 1
bysort Provider_Code: egen Flag2 = sum(Flag1)
qui sum Flag2
keep if Flag2 == r(max)
local depvars Under_24_Weeks_Prop_Manual Over_52_Weeks_Prop_Manual Over_65_Weeks_Prop_Manual
foreach depvar in `depvars' {
    * Start logging results for the current dependent variable
    log using "Outputs/Main/CSA_Incomplete_Pathways_`depvar'.log", replace
	csdid `depvar', time(Calendar_Month) gvar(Group_Var) ivar(Group_ID)
	estat pretrend, window(-24 -1)
	set seed 123456
    csdid `depvar', time(Calendar_Month) gvar(Group_Var) ivar(Group_ID) wboot saverif(altnh) ad csdid_stats replace
    csdid_estat event
    csdid_plot, style(rcap)
    tempfile analysisResults
    save `analysisResults', replace
    use altnh, clear
	set seed 123456
    csdid_stats event, wboot estore(event)
    graph export "Outputs/Main/CSA_Incomplete_Pathways_`depvar'.png", replace
    use `analysisResults', clear
    log close
}
restore
erase altnh.dta

preserve
keep if Stage == "Incomplete Pathways with DTA"
gen Flag1 = 1
bysort Provider_Code: egen Flag2 = sum(Flag1)
qui sum Flag2
keep if Flag2 == r(max)
local depvars Under_24_Weeks_Prop_Manual Over_52_Weeks_Prop_Manual Over_65_Weeks_Prop_Manual
foreach depvar in `depvars' {
    * Start logging results for the current dependent variable
    log using "Outputs/Main/CSA_Incomplete_Pathways_DTA_`depvar'.log", replace
	csdid `depvar', time(Calendar_Month) gvar(Group_Var) ivar(Group_ID)
	estat pretrend, window(-24 -1)
	set seed 123456
    csdid `depvar', time(Calendar_Month) gvar(Group_Var) ivar(Group_ID) wboot saverif(altnh) ad csdid_stats replace
    csdid_estat event
    csdid_plot, style(rcap)
    tempfile analysisResults
    save `analysisResults', replace
    use altnh, clear
	set seed 123456
    csdid_stats event, wboot estore(event)
    graph export "Outputs/Main/CSA_Incomplete_Pathways_DTA_`depvar'.png", replace
    use `analysisResults', clear
    log close
}
restore
erase altnh.dta


*Naive DiD Analysis
preserve
keep if Stage == "Completed Pathways For Non-Admitted Patients"
gen Flag1 = 1
bysort Provider_Code: egen Flag2 = sum(Flag1)
qui sum Flag2
keep if Flag2 == r(max)
local depvars Under_24_Weeks_Prop Over_52_Weeks_Prop Over_65_Weeks_Prop
foreach depvar in `depvars' {
putexcel set Outputs\Main\Naive_DiD_Non-Admitted_Pathways_`depvar'.xlsx, sheet(model) modify
putexcel C1 = "Mean Treatment - pre"
putexcel D1 = "SD Treatment - pre"
putexcel E1 = "Mean Treatment - post"
putexcel F1 = "SD Treatment - post"
putexcel G1 = "Mean Control - pre"
putexcel H1 = "SD Control - pre"
putexcel I1 = "Mean Control - post"
putexcel J1 = "SD Control - post"
putexcel B2 = "RAE"
putexcel B3 = "RCF"
putexcel B4 = "RR8"
putexcel B5 = "RWY"
putexcel B6 = "RXF"

* Treatment providers pre and post implementation
summarize `depvar' if Provider_Code == "RAE" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C2 = `output'
local output = round(`r(sd)', 0.001)
putexcel D2 = `output'
summarize `depvar' if Provider_Code == "RAE" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E2 = `output'
local output = round(`r(sd)', 0.001)
putexcel F2 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G2 = `output'
local output = round(`r(sd)', 0.001)
putexcel H2 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I2 = `output'
local output = round(`r(sd)', 0.001)
putexcel J2 = `output'
putexcel K2 = formula("=(E2-C2)-(I2-G2)")

summarize `depvar' if Provider_Code == "RCF" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C3 = `output'
local output = round(`r(sd)', 0.001)
putexcel D3 = `output'
summarize `depvar' if Provider_Code == "RCF" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E3 = `output'
local output = round(`r(sd)', 0.001)
putexcel F3 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G3 = `output'
local output = round(`r(sd)', 0.001)
putexcel H3 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I3 = `output'
local output = round(`r(sd)', 0.001)
putexcel J3 = `output'
putexcel K3 = formula("=(E3-C3)-(I3-G3)")

summarize `depvar' if Provider_Code == "RR8" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C4 = `output'
local output = round(`r(sd)', 0.001)
putexcel D4 = `output'
summarize `depvar' if Provider_Code == "RR8" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E4 = `output'
local output = round(`r(sd)', 0.001)
putexcel F4 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G4 = `output'
local output = round(`r(sd)', 0.001)
putexcel H4 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I4 = `output'
local output = round(`r(sd)', 0.001)
putexcel J4 = `output'
putexcel K4 = formula("=(E4-C4)-(I4-G4)")

summarize `depvar' if Provider_Code == "RWY" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C5 = `output'
local output = round(`r(sd)', 0.001)
putexcel D5 = `output'
summarize `depvar' if Provider_Code == "RWY" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E5 = `output'
local output = round(`r(sd)', 0.001)
putexcel F5 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G5 = `output'
local output = round(`r(sd)', 0.001)
putexcel H5 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I5 = `output'
local output = round(`r(sd)', 0.001)
putexcel J5 = `output'
putexcel K5 = formula("=(E5-C5)-(I5-G5)")

summarize `depvar' if Provider_Code == "RXF" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C6 = `output'
local output = round(`r(sd)', 0.001)
putexcel D6 = `output'
summarize `depvar' if Provider_Code == "RXF" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E6 = `output'
local output = round(`r(sd)', 0.001)
putexcel F6 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G6 = `output'
local output = round(`r(sd)', 0.001)
putexcel H6 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I6 = `output'
local output = round(`r(sd)', 0.001)
putexcel J6 = `output'
putexcel K6 = formula("=(E6-C6)-(I6-G6)")
}
restore



preserve
keep if Stage == "Completed Pathways For Admitted Patients"
gen Flag1 = 1
bysort Provider_Code: egen Flag2 = sum(Flag1)
qui sum Flag2
keep if Flag2 == r(max)
local depvars Under_24_Weeks_Prop Over_52_Weeks_Prop Over_65_Weeks_Prop
foreach depvar in `depvars' {
putexcel set Outputs\Main\Naive_DiD_Admitted_Pathways_`depvar'.xlsx, sheet(model) modify
putexcel C1 = "Mean Treatment - pre"
putexcel D1 = "SD Treatment - pre"
putexcel E1 = "Mean Treatment - post"
putexcel F1 = "SD Treatment - post"
putexcel G1 = "Mean Control - pre"
putexcel H1 = "SD Control - pre"
putexcel I1 = "Mean Control - post"
putexcel J1 = "SD Control - post"
putexcel B2 = "RAE"
putexcel B3 = "RCF"
putexcel B4 = "RR8"
putexcel B5 = "RWY"
putexcel B6 = "RXF"

* Treatment providers pre and post implementation
summarize `depvar' if Provider_Code == "RAE" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C2 = `output'
local output = round(`r(sd)', 0.001)
putexcel D2 = `output'
summarize `depvar' if Provider_Code == "RAE" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E2 = `output'
local output = round(`r(sd)', 0.001)
putexcel F2 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G2 = `output'
local output = round(`r(sd)', 0.001)
putexcel H2 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I2 = `output'
local output = round(`r(sd)', 0.001)
putexcel J2 = `output'
putexcel K2 = formula("=(E2-C2)-(I2-G2)")

summarize `depvar' if Provider_Code == "RCF" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C3 = `output'
local output = round(`r(sd)', 0.001)
putexcel D3 = `output'
summarize `depvar' if Provider_Code == "RCF" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E3 = `output'
local output = round(`r(sd)', 0.001)
putexcel F3 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G3 = `output'
local output = round(`r(sd)', 0.001)
putexcel H3 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I3 = `output'
local output = round(`r(sd)', 0.001)
putexcel J3 = `output'
putexcel K3 = formula("=(E3-C3)-(I3-G3)")

summarize `depvar' if Provider_Code == "RR8" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C4 = `output'
local output = round(`r(sd)', 0.001)
putexcel D4 = `output'
summarize `depvar' if Provider_Code == "RR8" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E4 = `output'
local output = round(`r(sd)', 0.001)
putexcel F4 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G4 = `output'
local output = round(`r(sd)', 0.001)
putexcel H4 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I4 = `output'
local output = round(`r(sd)', 0.001)
putexcel J4 = `output'
putexcel K4 = formula("=(E4-C4)-(I4-G4)")

summarize `depvar' if Provider_Code == "RWY" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C5 = `output'
local output = round(`r(sd)', 0.001)
putexcel D5 = `output'
summarize `depvar' if Provider_Code == "RWY" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E5 = `output'
local output = round(`r(sd)', 0.001)
putexcel F5 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G5 = `output'
local output = round(`r(sd)', 0.001)
putexcel H5 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I5 = `output'
local output = round(`r(sd)', 0.001)
putexcel J5 = `output'
putexcel K5 = formula("=(E5-C5)-(I5-G5)")

summarize `depvar' if Provider_Code == "RXF" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C6 = `output'
local output = round(`r(sd)', 0.001)
putexcel D6 = `output'
summarize `depvar' if Provider_Code == "RXF" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E6 = `output'
local output = round(`r(sd)', 0.001)
putexcel F6 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G6 = `output'
local output = round(`r(sd)', 0.001)
putexcel H6 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I6 = `output'
local output = round(`r(sd)', 0.001)
putexcel J6 = `output'
putexcel K6 = formula("=(E6-C6)-(I6-G6)")
}
restore


* Treatment providers pre and post implementation
preserve
keep if Stage == "Incomplete Pathways"
gen Flag1 = 1
bysort Provider_Code: egen Flag2 = sum(Flag1)
qui sum Flag2
keep if Flag2 == r(max)
local depvars Under_24_Weeks_Prop_Manual Over_52_Weeks_Prop_Manual Over_65_Weeks_Prop_Manual
foreach depvar in `depvars' {
putexcel set Outputs\Main\Naive_DiD_Incomplete_Pathways_`depvar'.xlsx, sheet(model) modify
putexcel C1 = "Mean Treatment - pre"
putexcel D1 = "SD Treatment - pre"
putexcel E1 = "Mean Treatment - post"
putexcel F1 = "SD Treatment - post"
putexcel G1 = "Mean Control - pre"
putexcel H1 = "SD Control - pre"
putexcel I1 = "Mean Control - post"
putexcel J1 = "SD Control - post"
putexcel B2 = "RAE"
putexcel B3 = "RCF"
putexcel B4 = "RR8"
putexcel B5 = "RWY"
putexcel B6 = "RXF"

* Treatment providers pre and post implementation
summarize `depvar' if Provider_Code == "RAE" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C2 = `output'
local output = round(`r(sd)', 0.001)
putexcel D2 = `output'
summarize `depvar' if Provider_Code == "RAE" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E2 = `output'
local output = round(`r(sd)', 0.001)
putexcel F2 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G2 = `output'
local output = round(`r(sd)', 0.001)
putexcel H2 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I2 = `output'
local output = round(`r(sd)', 0.001)
putexcel J2 = `output'
putexcel K2 = formula("=(E2-C2)-(I2-G2)")

summarize `depvar' if Provider_Code == "RCF" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C3 = `output'
local output = round(`r(sd)', 0.001)
putexcel D3 = `output'
summarize `depvar' if Provider_Code == "RCF" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E3 = `output'
local output = round(`r(sd)', 0.001)
putexcel F3 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G3 = `output'
local output = round(`r(sd)', 0.001)
putexcel H3 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I3 = `output'
local output = round(`r(sd)', 0.001)
putexcel J3 = `output'
putexcel K3 = formula("=(E3-C3)-(I3-G3)")

summarize `depvar' if Provider_Code == "RR8" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C4 = `output'
local output = round(`r(sd)', 0.001)
putexcel D4 = `output'
summarize `depvar' if Provider_Code == "RR8" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E4 = `output'
local output = round(`r(sd)', 0.001)
putexcel F4 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G4 = `output'
local output = round(`r(sd)', 0.001)
putexcel H4 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I4 = `output'
local output = round(`r(sd)', 0.001)
putexcel J4 = `output'
putexcel K4 = formula("=(E4-C4)-(I4-G4)")

summarize `depvar' if Provider_Code == "RWY" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C5 = `output'
local output = round(`r(sd)', 0.001)
putexcel D5 = `output'
summarize `depvar' if Provider_Code == "RWY" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E5 = `output'
local output = round(`r(sd)', 0.001)
putexcel F5 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G5 = `output'
local output = round(`r(sd)', 0.001)
putexcel H5 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I5 = `output'
local output = round(`r(sd)', 0.001)
putexcel J5 = `output'
putexcel K5 = formula("=(E5-C5)-(I5-G5)")

summarize `depvar' if Provider_Code == "RXF" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C6 = `output'
local output = round(`r(sd)', 0.001)
putexcel D6 = `output'
summarize `depvar' if Provider_Code == "RXF" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E6 = `output'
local output = round(`r(sd)', 0.001)
putexcel F6 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G6 = `output'
local output = round(`r(sd)', 0.001)
putexcel H6 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I6 = `output'
local output = round(`r(sd)', 0.001)
putexcel J6 = `output'
putexcel K6 = formula("=(E6-C6)-(I6-G6)")
}
restore


* Treatment providers pre and post implementation
preserve
keep if Stage == "Incomplete Pathways with DTA"
gen Flag1 = 1
bysort Provider_Code: egen Flag2 = sum(Flag1)
qui sum Flag2
keep if Flag2 == r(max)
local depvars Under_24_Weeks_Prop_Manual Over_52_Weeks_Prop_Manual Over_65_Weeks_Prop_Manual
foreach depvar in `depvars' {
putexcel set Outputs\Main\Naive_DiD_Incomplete_Pathways_DTA_`depvar'.xlsx, sheet(model) modify
putexcel C1 = "Mean Treatment - pre"
putexcel D1 = "SD Treatment - pre"
putexcel E1 = "Mean Treatment - post"
putexcel F1 = "SD Treatment - post"
putexcel G1 = "Mean Control - pre"
putexcel H1 = "SD Control - pre"
putexcel I1 = "Mean Control - post"
putexcel J1 = "SD Control - post"
putexcel B2 = "RAE"
putexcel B3 = "RCF"
putexcel B4 = "RR8"
putexcel B5 = "RWY"
putexcel B6 = "RXF"
summarize `depvar' if Provider_Code == "RAE" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C2 = `output'
local output = round(`r(sd)', 0.001)
putexcel D2 = `output'
summarize `depvar' if Provider_Code == "RAE" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E2 = `output'
local output = round(`r(sd)', 0.001)
putexcel F2 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G2 = `output'
local output = round(`r(sd)', 0.001)
putexcel H2 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I2 = `output'
local output = round(`r(sd)', 0.001)
putexcel J2 = `output'
putexcel K2 = formula("=(E2-C2)-(I2-G2)")

summarize `depvar' if Provider_Code == "RCF" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C3 = `output'
local output = round(`r(sd)', 0.001)
putexcel D3 = `output'
summarize `depvar' if Provider_Code == "RCF" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E3 = `output'
local output = round(`r(sd)', 0.001)
putexcel F3 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G3 = `output'
local output = round(`r(sd)', 0.001)
putexcel H3 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I3 = `output'
local output = round(`r(sd)', 0.001)
putexcel J3 = `output'
putexcel K3 = formula("=(E3-C3)-(I3-G3)")

summarize `depvar' if Provider_Code == "RR8" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C4 = `output'
local output = round(`r(sd)', 0.001)
putexcel D4 = `output'
summarize `depvar' if Provider_Code == "RR8" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E4 = `output'
local output = round(`r(sd)', 0.001)
putexcel F4 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G4 = `output'
local output = round(`r(sd)', 0.001)
putexcel H4 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I4 = `output'
local output = round(`r(sd)', 0.001)
putexcel J4 = `output'
putexcel K4 = formula("=(E4-C4)-(I4-G4)")

summarize `depvar' if Provider_Code == "RWY" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C5 = `output'
local output = round(`r(sd)', 0.001)
putexcel D5 = `output'
summarize `depvar' if Provider_Code == "RWY" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E5 = `output'
local output = round(`r(sd)', 0.001)
putexcel F5 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G5 = `output'
local output = round(`r(sd)', 0.001)
putexcel H5 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I5 = `output'
local output = round(`r(sd)', 0.001)
putexcel J5 = `output'
putexcel K5 = formula("=(E5-C5)-(I5-G5)")

summarize `depvar' if Provider_Code == "RXF" & Event_Time <0
local output = round(`r(mean)', 0.001)
putexcel C6 = `output'
local output = round(`r(sd)', 0.001)
putexcel D6 = `output'
summarize `depvar' if Provider_Code == "RXF" & Event_Time >=0
local output = round(`r(mean)', 0.001)
putexcel E6 = `output'
local output = round(`r(sd)', 0.001)
putexcel F6 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  < 759
local output = round(`r(mean)', 0.001)
putexcel G6 = `output'
local output = round(`r(sd)', 0.001)
putexcel H6 = `output'
summarize `depvar' if WY == 0 & Calendar_Month  >= 759
local output = round(`r(mean)', 0.001)
putexcel I6 = `output'
local output = round(`r(sd)', 0.001)
putexcel J6 = `output'
putexcel K6 = formula("=(E6-C6)-(I6-G6)")
}
restore
