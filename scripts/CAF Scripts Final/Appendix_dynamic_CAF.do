/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Alexander Abajian

5/31/2022

Create the cumulative change in emissions from adaptation assuming feedbacks to temperature each period
*/




//set file paths
// cd "/Volumes/ext_drive/Results/
// global root "/Volumes/ext_drive"
// global csv "$root/Results/csv"
// global processed "$root/Results/processed"
// global objects "$root/objects"
// //global forkyle "$root/for_kcm"
//

//set file paths
cd "/Volumes/ext_drive/uncertainty_8_12_22"
global root "/Volumes/ext_drive/uncertainty_8_12_22"
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"
global objects "$root/objects"


/*

Step 1: import data for the ssp3/rcp85 scenario and create the panel dataset of baseline emissions

*/
//import aggregate series

use "$processed/CAF_by_scenario_full.dta", clear



keep mean_emissions cml_mean_emiss year rcp ssp_level ssp beta1 fitted_emissions cum_emissions_RCP dT_Cumulative dE_adpt_mean gcm_temp_adapt Adaptation_Feedback temp
// keep if rcp=="rcp85" & ssp=="SSP3" & ssp_level=="high"
keep if rcp=="rcp85" & ssp=="SSP2" 
drop if year==210
collapse mean_emissions cml_mean_emiss  beta1 fitted_emissions cum_emissions_RCP dT_Cumulative dE_adpt_mean gcm_temp_adapt Adaptation_Feedback temp, by(year rcp ssp)




/*

Step 2: merge in the aggregation of country-level IRF coefficients for each fuel

merge from --Appendix_dynamic_CAF_makeIRFS 

*/

//newly estimated IRFs from  "Appendix_dynamic_CAF_makeIRFS.do"
merge 1:1 year using  "$objects/aggregate_IRF_coefficients_rcp8ssp2.dta", gen(merge_coefficients)



sum beta_1_mat_other1-beta_2_mat_elec1
keep if merge_coefficients==3
drop  merge_coefficients




/*

Step 3: generate effects of adaptation each period

*/

//new temperatureseries 
gen updated_temp = temp[1]


//running change in dT relative to 2020 level
gen period_demissions = 0
gen cumulative_demissions = 0


//running cumulative emissions relative to 2020 as deviations from 
gen period_dT = 0
gen cumulative_dT = 0 



//pull coeffcicents
/*


------------------------------------------------------------------------------
             |               Robust
dT_Cumulat~e | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  dE_cum_RCP |   .0022562   .0000217   103.93   0.000     .0022136    .0022987
------------------------------------------------------------------------------

. 


*/
scalar TCRE =  0.0022562

//update -- need to do in marginals
forvalues i = 2021/2099 {
	
	//hold prior period temperature in scalar
	
	//solve for the fitted value of cumulative emissions (change) using the quadratic coefficients
	scalar period_effect = (updated_temp[`i' - 2020] - temp[`i' - 2020]) * ( beta_1_mat_other1[`i'-2019] + beta_1_mat_elec1[`i'-2019]  + (updated_temp[`i' - 2020])*2 *( beta_2_mat_other1[`i'-2019] + beta_2_mat_elec1[`i'-2019]) ) *(12.011 / 44.009 )

	replace period_demissions = period_effect if year==`i'

	
	//fill out cuimulative emissions change from adp
	scalar lag_cumulative_emissions = cumulative_demissions[`i' - 2020] 
	replace cumulative_demissions =  period_effect + lag_cumulative_emissions if year==`i'


	//running cumulative emissions relative to 2020 as deviations from 
	replace period_dT =  period_effect *(TCRE) if year==`i'
	
	scalar lag_cumulative_dT = cumulative_dT[`i' - 2020] 
	replace cumulative_dT = lag_cumulative_dT + period_dT if year==`i'
	
	//fill out cumulative temp change from adp
	//update temperature ts
	replace updated_temp = temp + Adaptation_Feedback +  cumulative_dT if year==`i'
	
	
}

//rename

rename temp rcp85_baseline_GMST
rename updated_temp rcp85_w_dynamic_CAF
gen rcp85_w_CAF = rcp85_baseline_GMST + Adaptation_Feedback



//generate "de-normalized" temperature updates
keep  rcp85_baseline_GMST  rcp85_w_dynamic_CAF rcp85_w_CAF  year Adaptation_Feedback cumulative_dT 


gen temp_0 = rcp85_baseline_GMST[1]
gen rcp85_baseline_GMST_from2020 = rcp85_baseline_GMST - temp_0
gen rcp85_w_CAF_from2020 = rcp85_w_CAF - temp_0
gen rcp85_w_dynamic_CAF_from2020= rcp85_w_dynamic_CAF - temp_0

gen normalized_baseline = rcp85_baseline_GMST/rcp85_baseline_GMST
gen normalized_CAF = rcp85_w_CAF/rcp85_baseline_GMST
gen normalized_dynamic_CAF =  rcp85_w_dynamic_CAF/rcp85_baseline_GMST

label var normalized_baseline "Normalized Baseline RCP8.5 Temp Pathway (mean across models)" 
label var normalized_CAF "Normalized Temperature Pathway Plus CAF Effects"
label var normalized_dynamic_CAF "Under Adaptation with Dynamic CAF"


label var rcp85_baseline_GMST "GMST Anomaly Baseline under model average RCP8.5"
label var rcp85_w_CAF "GMST pathway after accounting for CAF"
label var  rcp85_w_dynamic_CAF "GMST pathway with dynamic CAF"


label var rcp85_baseline_GMST_from2020 "GMST change from 2020 under Baseline RCP8.5"
label var rcp85_w_CAF_from2020 "GMST change from 2020 with CAF
label var  rcp85_w_dynamic_CAF_from2020 "GMST change from 2020 with dynamic CAF"






sum rcp85_baseline_GMST rcp85_w_CAF rcp85_w_dynamic_CAF if year==2099

/*


. sum rcp85_baseline_GMST rcp85_w_CAF rcp85_w_dynamic_CAF if year==2099

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
rcp85_base~T |          1    4.269998           .   4.269998   4.269998
 rcp85_w_CAF |          1    4.149391           .   4.149391   4.149391
rcp85_w_dy~F |          1    4.151678           .   4.151678   4.151678

. 
end of do-file



*/


sum rcp85_baseline_GMST_from2020 rcp85_w_CAF_from2020 rcp85_w_dynamic_CAF_from2020 if year==2099



twoway (line rcp85_baseline_GMST year if year<2100, lcolor(black) legend(label(1 "Baseline RCP8.5" "GMST Trajectory")) lwidth(medium) lpattern(dash ))  (line rcp85_w_CAF year if year<2100, legend(label(2 "CAF")) lwidth(medium) color(blue))  (line rcp85_w_dynamic_CAF year if year<2100, legend(label(3 "Dynamic CAF")) lwidth(medium) color(red)), ytitle("{&Delta}GMST from 2001-2010 Average") xtitle("Year") title("Cumulative Temperature Change from Adaptation," "Including Feedbacks")



twoway  (line normalized_CAF year if year<2100,  lwidth(medium) color(blue)) (line normalized_dynamic_CAF year if year<2100,  lwidth(medium) color(green)), ytitle("Percent Deviations from RCP 8.5 Ensemble Baseline") xtitle("Year") title("Deviation from Baseline")


save "$processed/dynamic_CAF_rcp85ssp2.dta", replace 
