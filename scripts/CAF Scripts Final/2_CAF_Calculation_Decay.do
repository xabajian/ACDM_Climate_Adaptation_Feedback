/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Read in global emissions and temperature time series.
Read in updated impact-region level files containing mean and 5-95qtile damages for both fuels.
Each file read in gives means as well as 90% CIs across rcp/ssp/iam level scenarios
Combine to create CAF accounting for globally decaying factors.
*/



//set file paths
//global root "{FILEPATH INTO ACDM_Data from ZENODO}"
global root "/Volumes/ext_drive/ACDM_Data"
cd $root 
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"
global objects "$root/objects"
global figures "$root/figures"
global NDCs  "$root/NDCs"


/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Step 1: Create TS of annual global emissions and cumulative emissions based on the RCPs. 
RCP forecasts are only decadal so we must interpolate emissions


		RCP series: https://tntcat.iiasa.ac.at/RcpDb/dsd?Action=htmlpage&page=download.
		
		The RCP database aims at documenting the emissions, concentrations, and land-cover change projections of the so-called "Representative Concentration Pathways" (RCPs).
			kept by the IIASA (International Institute for Applied Systems Analysis: IIASA)
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/


/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
Step 1.1: Generate time series of global CO2 emissions, RCP 4.5
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/

//read in raw rcp covered years
import excel "$raw/RCPs/rcp45_global.xls", sheet("transpose emissions") firstrow clear

//fill time series to interpolate
tsset year
tsfill


//interpolate values using linear splines
ipolate CO2emissionsGTCeq year, generate(fitted_emissions)


//merge gmst paths
merge 1:1 year using "$raw/RCPs/GMST_model_average_rcp45_SEs.dta", gen(merge_gmst)

keep if merge_gmst==3
drop merge_gmst

//generate cumulative emissions measure
sort year
gen cum_emissions_RCP = fitted_emissions[1]
replace cum_emissions_RCP = cum_emissions_RCP[_n-1] + fitted_emissions[_n] if _n>1

//label
label var cum_emissions_RCP "estimated cumulative carbon emissions in GTC-equivalents"

//save series out
save "$processed/rcp45_baseline_emissions.dta", replace

clear


/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
Step 1.2: Repeat for RCP 8.5
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/

//import raw rcp85 emissions data for the set of covered years
import excel "$raw/RCPs/rcp85_global.xls", sheet("transpose emissions") firstrow clear
drop D


//fill time series to interpolate
tsset year
tsfill

//interpolate values using linear splines
ipolate CO2emissionsGTCeq year, generate(fitted_emissions)


//merge gmst paths
merge 1:1 year using "$raw/RCPs/GMST_model_average_rcp85_SEs.dta", gen(merge_gmst)
keep if merge_gmst==3
drop merge_gmst

//generate cumulative emissions measure
sort year
gen cum_emissions_RCP = fitted_emissions[1]
replace cum_emissions_RCP = cum_emissions_RCP[_n-1] + fitted_emissions[_n] if _n>1
//label
label var cum_emissions_RCP "estimated cumulative carbon emissions in GTC-equivalents"


//save series out
save "$processed/rcp85_baseline_emissions.dta", replace

clear




/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Step 2: Append the two series and merge in the tseries of aggregate adaptation

Generate mean and quantile scenarios

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/




/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
2.1: Append the two temperature series
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/


use "$processed/rcp85_baseline_emissions.dta", clear
append using "$processed/rcp45_baseline_emissions.dta"

//new uncertainty uptades series
merge 1:m year rcp using "$processed/aggregate_adaptation_9_12_decay.dta", gen(merge_adaptation_emissions)


/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                            42
        from master                        42  (merge_adaptation_emissions==1)
        from using                          0  (merge_adaptation_emissions==2)

    Matched                             1,280  (merge_adaptation_emissions==3)
    -----------------------------------------


. 
*/

keep if year>2019 & year<2100
tab merge_adaptation_emissions
drop merge


/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/

//generate new cumulative series for each rcp/ssp scenario that accounts for adaptation_multiplier_data/Draft/adaptation_feedback
gen rcp_adapt_cml_mean = cml_mean_emiss +  cum_emissions_RCP

 

//sanity check
tab year if rcp=="rcp85", sum(rcp_adapt_cml_mean)
 


/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Step 3: Create "f" described in section 2 of the paper. This is a mapping between cumulative emissions and change in GMST estimated in future

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/


/*
Make alternative temperature and emissions series starting at zero for baseline year 2020, accounting for the initial year (year 2020) adaptation and its effect on temperature that year
*/

sort ssp rcp ssp_level year 

//re-center dT relative to year 2020
bysort ssp rcp  ssp_level: gen temp_0 = temp[1]
bysort ssp rcp  ssp_level: gen dT_Cumulative = temp - temp_0

//re center baseline RCP emissions and emissions with adaptation
//rcp baselines in 2020
bysort ssp rcp ssp_level: gen e_0  = cum_emissions_RCP[1]
bysort ssp rcp ssp_level: gen dE_cml_RCP = cum_emissions_RCP - e_0


//with adapt
bysort ssp rcp ssp_level: gen ea_0  = cum_emissions_RCP[1]
bysort ssp rcp ssp_level: gen dE_adpt_mean = rcp_adapt_cml_mean - ea_0


/*

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Linear fits of change in GMST on change in cumulative carbon emissions, by SSP/RCP scenarios in order to
to generate effects of adaptation on temperature.

Will use these coefficients as out \mathcal{T} margins function

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

*/


/*
%%%%%%%%%%%%%%%%%%%%%%
Aggregate Beta
%%%%%%%%%%%%%%%%%%%%%%
*/


gen beta1 = 0
gen beta1_var = 0


reg dT_Cumulative dE_cml_RCP if ssp=="SSP3" & ssp_level=="low", r noconstant
//run regression of dT on dCarbon fixing an SSP and SSP level so I don't double count multiple GCM-temperature-RCP series runs



replace beta1 = e(b)[1,1] 
replace beta1_var = e(V)[1,1] 




sum beta1
sum beta1_var




/*
#!$#!%@##!%
Linear Fit using margins
#!$#!%@##!%
*/

//generate cumulative emissions changes each scenario
gen Delta_Emissions_Mean = dE_adpt_mean - dE_cml_RCP 


//alternative temperature TS
gen gcm_temp_adapt = dT_Cumulative + beta1* (Delta_Emissions_Mean) 


 /*
 solve for delta T at horizon tau - adaptation feedback
 */
 
 gen Adaptation_Feedback = gcm_temp_adapt-dT_Cumulative

/*
#!$#!%@##!%
Spot checks
#!$#!%@##!%
*/
tab year, sum(Adaptation_Feedback)
tab year, sum(gcm_temp_adapt)
tab year, sum(dT_Cumulative)


/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Summary stats

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/


sum Adaptation_Feedback if year==2099 & rcp=="rcp85" & ssp=="SSP2"
//  -.1349554 
 
sum Adaptation_Feedback if year==2099 & rcp=="rcp45" & ssp=="SSP2"
//  -.0782  

sort year
twoway (line Adaptation_Feedback year if rcp=="rcp85" & ssp=="SSP2" & ssp_level=="high") , ///
legend(order(1 "CAF when Emissions Decay")) ///
ytitle("Degrees C") ///
//note("This figure compares the CAF under an SSP2 high - RCP4.5 scenario when emissions" ///
//"factors decay at historical global rates.")
graph export "/Volumes/ext_drive/uncertainty_8_12_22/figures/caf_decay.png", as(png) name("Graph") replace



/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Save for ref reviews

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/

keep if rcp=="rcp85" & ssp=="SSP2"
collapse Adaptation_Feedback, by(year)
rename Adaptation_Feedback decay_CAF
label var decay_CAF "CAF when factors decay at global rate"
 
 sum decay_CAF if year==2099 
 
 
 
save "$processed/AF_withdecay_TS.dta", replace
/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Read in global emissions and temperature time series.
Read in updated impact-region level files containing mean and 5-95qtile damages for both fuels.
Each file read in gives means as well as 90% CIs across rcp/ssp/iam level scenarios
Combine to create CAF
*/




//set file paths
cd "/Volumes/ext_drive/uncertainty_8_12_22"
global root "/Volumes/ext_drive/uncertainty_8_12_22"
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"



/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Step 1: Create TS of annual global emissions and cumulative emissions based on the RCPs. 
RCP forecasts are only decadal so we must interpolate emissions


		RCP series: https://tntcat.iiasa.ac.at/RcpDb/dsd?Action=htmlpage&page=download.
		
		The RCP database aims at documenting the emissions, concentrations, and land-cover change projections of the so-called "Representative Concentration Pathways" (RCPs).
			kept by the IIASA (International Institute for Applied Systems Analysis: IIASA)
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/


/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
Step 1.1: Generate time series of global CO2 emissions, RCP 4.5
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/

//read in raw rcp covered years
import excel "$raw/RCPs/rcp45_global.xls", sheet("transpose emissions") firstrow clear

//fill time series to interpolate
tsset year
tsfill


//interpolate values using linear splines
ipolate CO2emissionsGTCeq year, generate(fitted_emissions)


//merge gmst paths
merge 1:1 year using "$raw/RCPs/GMST_model_average_rcp45_SEs.dta", gen(merge_gmst)

keep if merge_gmst==3
drop merge_gmst

//generate cumulative emissions measure
sort year
gen cum_emissions_RCP = fitted_emissions[1]
replace cum_emissions_RCP = cum_emissions_RCP[_n-1] + fitted_emissions[_n] if _n>1

//label
label var cum_emissions_RCP "estimated cumulative carbon emissions in GTC-equivalents"

//save series out
save "$processed/rcp45_baseline_emissions.dta", replace

clear


/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
Step 1.2: Repeat for RCP 8.5
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/

//import raw rcp85 emissions data for the set of covered years
import excel "$raw/RCPs/rcp85_global.xls", sheet("transpose emissions") firstrow clear
drop D


//fill time series to interpolate
tsset year
tsfill

//interpolate values using linear splines
ipolate CO2emissionsGTCeq year, generate(fitted_emissions)


//merge gmst paths
merge 1:1 year using "$raw/RCPs/GMST_model_average_rcp85_SEs.dta", gen(merge_gmst)
keep if merge_gmst==3
drop merge_gmst

//generate cumulative emissions measure
sort year
gen cum_emissions_RCP = fitted_emissions[1]
replace cum_emissions_RCP = cum_emissions_RCP[_n-1] + fitted_emissions[_n] if _n>1
//label
label var cum_emissions_RCP "estimated cumulative carbon emissions in GTC-equivalents"


//save series out
save "$processed/rcp85_baseline_emissions.dta", replace

clear




/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Step 2: Append the two series and merge in the tseries of aggregate adaptation

Generate mean and quantile scenarios

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/




/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
2.1: Append the two temperature series
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/


use "$processed/rcp85_baseline_emissions.dta", clear
append using "$processed/rcp45_baseline_emissions.dta"

//new uncertainty uptades series
merge 1:m year rcp using "$processed/aggregate_adaptation_9_12_decay.dta", gen(merge_adaptation_emissions)


/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                            42
        from master                        42  (merge_adaptation_emissions==1)
        from using                          0  (merge_adaptation_emissions==2)

    Matched                             1,280  (merge_adaptation_emissions==3)
    -----------------------------------------


. 
*/

keep if year>2019 & year<2100
tab merge_adaptation_emissions
drop merge


/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/

//generate new cumulative series for each rcp/ssp scenario that accounts for adaptation_multiplier_data/Draft/adaptation_feedback
gen rcp_adapt_cml_mean = cml_mean_emiss +  cum_emissions_RCP

 

//sanity check
tab year if rcp=="rcp85", sum(rcp_adapt_cml_mean)
 


/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Step 3: Create "f" described in section 2 of the paper. This is a mapping between cumulative emissions and change in GMST estimated in future

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/


/*
Make alternative temperature and emissions series starting at zero for baseline year 2020, accounting for the initial year (year 2020) adaptation and its effect on temperature that year
*/

sort ssp rcp ssp_level year 

//re-center dT relative to year 2020
bysort ssp rcp  ssp_level: gen temp_0 = temp[1]
bysort ssp rcp  ssp_level: gen dT_Cumulative = temp - temp_0

//re center baseline RCP emissions and emissions with adaptation
//rcp baselines in 2020
bysort ssp rcp ssp_level: gen e_0  = cum_emissions_RCP[1]
bysort ssp rcp ssp_level: gen dE_cml_RCP = cum_emissions_RCP - e_0


//with adapt
bysort ssp rcp ssp_level: gen ea_0  = cum_emissions_RCP[1]
bysort ssp rcp ssp_level: gen dE_adpt_mean = rcp_adapt_cml_mean - ea_0


/*

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Linear fits of change in GMST on change in cumulative carbon emissions, by SSP/RCP scenarios in order to
to generate effects of adaptation on temperature.

Will use these coefficients as out \mathcal{T} margins function

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

*/


/*
%%%%%%%%%%%%%%%%%%%%%%
Aggregate Beta
%%%%%%%%%%%%%%%%%%%%%%
*/


gen beta1 = 0
gen beta1_var = 0


reg dT_Cumulative dE_cml_RCP if ssp=="SSP3" & ssp_level=="low", r noconstant
//run regression of dT on dCarbon fixing an SSP and SSP level so I don't double count multiple GCM-temperature-RCP series runs



replace beta1 = e(b)[1,1] 
replace beta1_var = e(V)[1,1] 




sum beta1
sum beta1_var




/*
#!$#!%@##!%
Linear Fit using margins
#!$#!%@##!%
*/

//generate cumulative emissions changes each scenario
gen Delta_Emissions_Mean = dE_adpt_mean - dE_cml_RCP 


//alternative temperature TS
gen gcm_temp_adapt = dT_Cumulative + beta1* (Delta_Emissions_Mean) 


 /*
 solve for delta T at horizon tau - adaptation feedback
 */
 
 gen Adaptation_Feedback = gcm_temp_adapt-dT_Cumulative

/*
#!$#!%@##!%
Spot checks
#!$#!%@##!%
*/
tab year, sum(Adaptation_Feedback)
tab year, sum(gcm_temp_adapt)
tab year, sum(dT_Cumulative)


/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Summary stats

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/


sum Adaptation_Feedback if year==2099 & rcp=="rcp85" & ssp=="SSP2"
//  -.1349554 
 
sum Adaptation_Feedback if year==2099 & rcp=="rcp45" & ssp=="SSP2"
//  -.0782  

sort year
twoway (line Adaptation_Feedback year if rcp=="rcp85" & ssp=="SSP2" & ssp_level=="high")



/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Save for ref reviews

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/

keep if rcp=="rcp85" & ssp=="SSP2"
collapse Adaptation_Feedback, by(year)
rename Adaptation_Feedback decay_CAF
label var decay_CAF "CAF when factors decay at global rate"
 
 sum decay_CAF if year==2099 
 
 
 
save "$processed/AF_withdecay_TS.dta", replace
