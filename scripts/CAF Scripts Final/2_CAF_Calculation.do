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
global root "STARTING_CAF_DIRECTORY"
cd $root 
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
merge 1:m year rcp using "$processed/aggregate_adaptation_9_12.dta", gen(merge_adaptation_emissions)


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
gen rcp_adapt_cml_q5 = cml_q5_emiss +  cum_emissions_RCP
gen rcp_adapt_cml_q95 = cml_q95_emiss +  cum_emissions_RCP
gen rcp_adapt_cml_el_only = cml_mean_emiss_el_fact +  cum_emissions_RCP
gen rcp_adapt_cml_of_only = cml_mean_emiss_of_fact +  cum_emissions_RCP

 

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
bysort ssp rcp ssp_level: gen dE_adpt_q5 = rcp_adapt_cml_q5 - ea_0
bysort ssp rcp ssp_level: gen dE_adpt_q95 = rcp_adapt_cml_q95 - ea_0
bysort ssp rcp ssp_level: gen dE_adpt_el_fact = rcp_adapt_cml_el_only - ea_0
bysort ssp rcp ssp_level: gen dE_adpt_of_fact = rcp_adapt_cml_of_only - ea_0


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
gen Delta_Emissions_q5 = dE_adpt_q5 - dE_cml_RCP 
gen Delta_Emissions_q95 = dE_adpt_q95 -dE_cml_RCP 
gen Delta_Emissions_elecfactors = dE_adpt_el_fact - dE_cml_RCP 
gen Delta_Emissions_otherfactors = dE_adpt_of_fact - dE_cml_RCP 



//alternative temperature TS
gen gcm_temp_adapt = dT_Cumulative + beta1* (Delta_Emissions_Mean) 
gen gcm_temp_adapt_q5 = dT_Cumulative + beta1* (Delta_Emissions_q5) 
gen gcm_temp_adapt_q95 = dT_Cumulative + beta1* (Delta_Emissions_q95) 
gen gcm_temp_adapt_elf = dT_Cumulative + beta1* (Delta_Emissions_elecfactors) 
gen gcm_temp_adapt_off = dT_Cumulative + beta1* (Delta_Emissions_otherfactors) 
 

 /*
 solve for delta T at horizon tau - adaptation feedback
 */
 
 gen Adaptation_Feedback = gcm_temp_adapt-dT_Cumulative
 gen Adaptation_Feedback_q95 = gcm_temp_adapt_q95-dT_Cumulative
 gen Adaptation_Feedback_q5 = gcm_temp_adapt_q5-dT_Cumulative
 
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
//  -.1206075  
 
sum Adaptation_Feedback if year==2099 & rcp=="rcp45" & ssp=="SSP2"
//   -.0713979  
 
save "$processed/CAF_by_scenario_full.dta", replace 


/*
%%%%%%%%%%%%%%%%%%%%%%
Save CAF by scenario
%%%%%%%%%%%%%%%%%%%%%%
*/
preserve
 
keep Adaptation_Feedback Adaptation_Feedback_q95 Adaptation_Feedback_q5 Delta_Emissions_Mean Delta_Emissions_q5 Delta_Emissions_q95 ssp rcp ssp_level year

/*
%%%%%%%%%%%%%%%%%%%%%%
kick out
%%%%%%%%%%%%%%%%%%%%%%
*/
save "$processed/CAF_by_scenario.dta", replace 

restore




/*
%%%%%%%%%%%%%%%%%%%%%%
kick out for 
%%%%%%%%%%%%%%%%%%%%%%
*/


preserve

keep if rcp=="rcp85" & ssp=="SSP2" & ssp_level=="high"
 
keep Adaptation_Feedback year 


save "$processed/bl_caf.dta", replace 

restore





/*
%%%%%%%%%%%%%%%%%%%%%%
Save CAF aggregate
%%%%%%%%%%%%%%%%%%%%%%
*/
   
 preserve
   
collapse (mean) Adaptation_Feedback Adaptation_Feedback_q5 Adaptation_Feedback_q95 , by(year)



/*
%%%%%%%%%%%%%%%%%%%%%%
kick out
%%%%%%%%%%%%%%%%%%%%%%
*/

save "$processed/CAF_pooled.dta", replace


restore

