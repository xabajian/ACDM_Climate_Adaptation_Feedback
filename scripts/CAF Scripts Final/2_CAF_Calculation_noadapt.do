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
Combine to create CAF with no adaptation
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
1 - open RCP 45 temp series


!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/


use "$processed/rcp45_baseline_emissions.dta", clear

//
merge 1:1 year  using "$processed/no_adapt_aggregate.dta", gen(merge_adaptation_emissions)


/*
//SSP3 and RCP45 no adapt series
. merge 1:1 year  using "$processed/no_adapt_aggregate.dta", gen(merge_adaptation_emissions)

    Result                      Number of obs
    -----------------------------------------
    Not matched                            19
        from master                         0  (merge_adaptation_emissions==1)
        from using                         19  (merge_adaptation_emissions==2)

    Matched                               101  (merge_adaptation_emissions==3)
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
generate cumulative_adapt_emissions = 0
replace cumulative_adapt_emissions = damages_emissions_centered + cumulative_adapt_emissions[_n-1] if _n>1
gen rcp_adapt_cml_mean = cumulative_adapt_emissions +  cum_emissions_RCP


//sanity check
tab year , sum(rcp_adapt_cml_mean)
 


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

sort year 

//re-center dT relative to year 2020
gen temp_0 = temp[1]
gen dT_Cumulative = temp - temp_0

//re center baseline RCP emissions and emissions with adaptation
//rcp baselines in 2020
gen e_0  = cum_emissions_RCP[1]
gen dE_cml_RCP = cum_emissions_RCP - e_0


//with adapt
gen ea_0  = cum_emissions_RCP[1]
gen dE_adpt_mean = rcp_adapt_cml_mean - ea_0

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


reg dT_Cumulative dE_cml_RCP, r noconstant
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
//-.01201081    

/*
rename for comparison
*/

keep year Adaptation_Feedback
rename Adaptation_Feedback Adaptation_Feedback_noadapt

merge 1:m year using "$processed/CAF_by_scenario.dta", gen(merge_baseline_CAF)

/*
graph
*/
sort ssp rcp ssp_level year 
twoway ///
 (line Adaptation_Feedback year if rcp=="rcp45" & ssp=="SSP2" & ssp_level=="low") ///
 (line Adaptation_Feedback_noadapt year if rcp=="rcp45" & ssp=="SSP2" & ssp_level=="low" ) , ///
legend(order(1 "Baseline CAF (w/" "Extensive Margin)" 2 "CAF w/o"  "Extensive Margin")) ///
ytitle("Degrees C") xtitle("Year")
graph export "$figures/AF_no_adapt.png", as(png) name("Graph") replace
