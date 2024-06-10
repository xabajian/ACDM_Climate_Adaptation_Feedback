/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Part 4 -- 

Use the CAF time series along with the CIL damage coefficients from the
The Data-driven Spatial Climate Impact Model (DSCIM) to calculate the welfare gains
(in EV form) due to avoided warming from the CAF
*/




//set file paths
global root "STARTING_CAF_DIRECTORY"
cd $root 
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"
global damages "/Volumes/ext_drive/CAF Scripts Final/4_CAF Damages"

/*
Seciton 0 -- read in relevant 
*/
cd  "$damages"


//make CAF temp series
use "$processed/CAF_by_scenario_full.dta", clear
//keep if  ssp=="SSP2" & rcp=="rcp85"
keep if  ssp=="SSP2" & rcp=="rcp45"
keep year Adaptation_Feedback dT_Cumulative temp temp_0 gcm_temp_adapt
collapse Adaptation_Feedback dT_Cumulative temp temp_0 gcm_temp_adapt , by(year)
save "CAF_series.dta", replace
clear


//read GDP growth series
import delimited "ssp2_growth.csv", clear
keep gdppc iam year
reshape wide gdppc , i(year) j(iam, string)
keep if year>2018 & year<2100 
gen growth_high  = gdppchigh[_n]/gdppchigh[1] - 1
gen growth_low  = gdppclow[_n]/gdppclow[1] - 1
keep growth_high  growth_low year
save "ssp_gdpgrowth.dta", replace





//damage coefficients from DSCIM
import delimited "integration_damage_function_coefficients.csv", clear
drop gmsl nppowergmsl2 v1
save "damage_coefficients.dta",  replace


/*
merge in relevant CAF series
*/
use "ssp_gdpgrowth.dta", clear

merge 1:1 year using "CAF_series"
drop _merge*
merge 1:1 year using "damage_coefficients"
drop _merge*


/*
Solve for damages with and without CAF
*/
gen temp2 = temp^2
gen temp_w_feedback2 = (temp +Adaptation_Feedback )^2

gen damage_baseline  = anomaly*temp + nppoweranomaly2*temp2
gen damage_CAF  = anomaly*(temp +Adaptation_Feedback)  + nppoweranomaly2*temp_w_feedback2
gen diff = damage_baseline-damage_CAF
sum diff
gen diff_bl = diff/1000000000
label var diff_bl "difference in damages, billions of USD"


/*
Generate an SDR relative to 2020 for each year
*/
gen time_index = _n - 1


//ramsey rule terms to form constant annual SDR
scalar IES = 0.5
scalar g_c = 0.02
scalar rho = 0.0001


//generate annualized growth term 
gen  cagr_high = (1+growth_high)^(1/time_index) - 1
gen  cagr_low = (1+growth_low)^(1/time_index) - 1


gen SDR_2 = (1+ g_c * (1/IES) +  rho) ^ - time_index
gen SDR_ssp2low = (1+ cagr_low * (1/IES) +  rho) ^ - time_index
gen SDR_ssp2high = (1+ cagr_high * (1/IES) +  rho) ^ - time_index
sum SDR*


//generate present values
gen pv_damages_2pct = diff_bl*SDR_2
gen pv_damages_low= diff_bl*SDR_ssp2low
gen pv_damages_high= diff_bl*SDR_ssp2high



label var pv_damages_2pct "difference in damages, billions of 2020USD at 2% growth"
label var pv_damages_low "difference in damages, billions of 2020USD at ssp2 low growth"
label var pv_damages_high "difference in damages, billions of 2020USD at ssp2 high growth"

//totals
total pv_damages_low
scalar pv_low = e(b)[1,1]


total pv_damages_high
scalar pv_high = e(b)[1,1]

total pv_damages_2pct
scalar pv_2pct = e(b)[1,1]




scalar welfare_geo_2pct = (1 /(1+ g_c * (1/IES) +  rho) ) * pv_damages_2pct[80]/( g_c * (1/IES) +  rho) 
scalar welfare_geo_low = (1 /(1+ cagr_high[80] * (1/IES) +  rho) ) * pv_damages_low[80]/( g_c * (1/IES) +  rho) 
scalar welfare_geo_high = (1 /(1+ cagr_low[80] * (1/IES) +  rho) ) * pv_damages_high[80]/( g_c * (1/IES) +  rho) 




display welfare_geo_2pct + pv_2pct
display welfare_geo_low + pv_low
display welfare_geo_high + pv_high



twoway (scatter SDR_ssp2high year, yaxis(1)) (scatter pv_damages_low year, yaxis(2))  (scatter pv_damages_high year, yaxis(2))  (scatter pv_damages_2pct year, yaxis(2))
//twoway (scatter Adaptation_Feedback year, yaxis(1)) (scatter SDR_2 year, yaxis(1)) (scatter diff_bl_pv year, yaxis(2))



/*
Benchmark vs. Golosov 
*/

scalar TCRE = 1.6
scalar gamma= 2.379 * 10^-5 
scalar beta  = 1 - rho 
scalar damage_gamma =gamma *1000 / TCRE
//.01486875
scalar AF = 0.12
scalar dT_2099= 4.269998 - 1
scalar eta=2


display (1 - exp(-AF * damage_gamma) ) *( beta * (1 + g_c)^(1-eta) ) ^(79) * exp(eta *damage_gamma *dT_2099) * (1 / (1 - beta * (1 + g_c)^(1-eta)) )
//.02069471


