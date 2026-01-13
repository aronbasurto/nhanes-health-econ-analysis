************************************************************
* Project: NHANES – Cost Sharing, Chronic Disease, and Care Use
* Author: Aron Basurto
************************************************************

clear all
set more off
version 17

************************************************************
* 1. Load Demographics Data
************************************************************
clear
import delimited "NHANES_DemoBMX.csv", clear
save "DEMO_J.dta", replace 
use "DEMO_J.dta", clear

keep seqn ridageyr riagendr ridreth1 indfmpir wtint2yr sdmvpsu sdmvstra
rename ridageyr age
rename riagendr female
gen female_binary = (female == 2)

************************************************************
* 2. Merge Insurance Coverage Data
************************************************************
merge 1:1 seqn using "HIQ_J.dta", keep(match) nogen
gen insured = (hiq011 == 1)

************************************************************
* 3. Merge Health Conditions Data
************************************************************
merge 1:1 seqn using "DIQ_J.dta", keep(match) nogen
gen diabetes = (diq010 == 1)

************************************************************
* 4. Merge Health Care Utilization Data
************************************************************
merge 1:1 seqn using "HUQ_J.dta", keep(match) nogen
gen doctor_visit = (huq010 == 1)

************************************************************
* 5. Sample Restrictions
************************************************************
keep if age >= 18
drop if missing(wtint2yr)

************************************************************
* 6. Survey Design
************************************************************
svyset sdmvpsu [pweight=wtint2yr], strata(sdmvstra)

************************************************************
* 7. Descriptive Statistics
************************************************************
svy: mean doctor_visit insured diabetes age

************************************************************
* 8. Regression Analysis
************************************************************
svy: reg doctor_visit insured age female_binary diabetes i.ridreth1

************************************************************
* 9. Subsample: Diabetic Population
************************************************************
svy, subpop(diabetes): reg doctor_visit insured age female_binary
