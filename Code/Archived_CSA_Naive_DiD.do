*** ROBUSTNESS CHECKS - CSA and NAIVE DID ANALYSIS (REDUNDANT FOR THIS APPROACH)

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
