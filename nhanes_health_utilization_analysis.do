************************************************************
* Project: NHANES – Cost Sharing, Chronic Disease, and Care Use
* Author: Aron Basurto
*
* Purpose:
*   This script demonstrates applied health economics data
*   work using NHANES data. It includes data cleaning,
*   merging across survey files, construction of health
*   and utilization measures, and regression analysis
*   using survey weights.
*
* Research Question (Illustrative):
*   How does insurance coverage relate to health care
*   utilization among adults with chronic conditions?
*
* Data Source:
*   National Health and Nutrition Examination Survey (NHANES)
*   Public-use files (CDC)
************************************************************

clear all
set more off
version 17

************************************************************
* 1. Load Demographics Data
************************************************************
use "DEMO_J.dta", clear   // 2017–2018 Demographics

keep seqn ridageyr riagendr ridreth1 indfmpir wtint2yr sdmvpsu sdmvstra
rename ridageyr age
rename riagendr female
gen female_binary = (female == 2)

************************************************************
* 2. Merge Insurance Coverage Data
************************************************************
merge 1:1 seqn using "HIQ_J.dta", keep(match) nogen

* Insurance indicator
gen insured = (hiq011 == 1)

************************************************************
* 3. Merge Health Conditions Data (Diabetes Example)
************************************************************
merge 1:1 seqn using "DIQ_J.dta", keep(match) nogen

* Diabetes indicator
gen diabetes = (diq010 == 1)

************************************************************
* 4. Merge Health Care Utilization Data
************************************************************
merge 1:1 seqn using "HUQ_J.dta", keep(match) nogen

* Doctor visit in past year
gen doctor_visit = (huq010 == 1)

************************************************************
* 5. Sample Restrictions
************************************************************
* Adults only
keep if age >= 18

* Keep respondents with valid weights
drop if missing(wtint2yr)

************************************************************
* 6. Set Survey Design
************************************************************
svyset sdmvpsu [pweight=wtint2yr], strata(sdmvstra)

************************************************************
* 7. Descriptive Statistics
************************************************************
svy: mean doctor_visit insured diabetes age

************************************************************
* 8. Regression Analysis
************************************************************
* Effect of insurance on utilization
svy: reg doctor_visit insured age female_binary diabetes i.ridreth1

************************************************************
* 9. Subsample Analysis: Diabetic Population
************************************************************
svy, subpop(diabetes): reg doctor_visit insured age female_binary

************************************************************
* 10. Interpretation Notes
************************************************************
* The coefficient on 'insured' reflects the association
* between insurance coverage and probability of having
* seen a doctor in the past year.
*
* Survey weights ensure national representativeness.
************************************************************

