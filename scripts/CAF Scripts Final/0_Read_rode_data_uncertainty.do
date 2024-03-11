/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Read in (country) level files files containing mean and 5-95qtile damages for both fuels.

Each file will give one of the mean, 5 or 95th quantile across rcp/ssp/iam level scenarios
*/




//set file paths
cd "/Volumes/ext_drive/uncertainty_8_12_22"
global root "/Volumes/ext_drive/uncertainty_8_12_22"
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"
global objects "$root/objects"



/*
!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$

Step 1: Read in each fuel/SSP/RCP/IAM level times series at the impact region level. These series
contain uncertainty bands from q5 to q95. -- ie the 90% CI for demand change at the IR level
each year each IR fixing a pathway.

This loops over all these files, aggregates them up to the ISO3 level, and merges in emissions factors.!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$
*/


****LOOP OBJECTS********
************************
****RCP list
global rcp_list = "rcp45 rcp85"
****Fuels
global fuel_list = "electricity other_energy"
****SSP - set of levels
global ssp_list = "SSP1 SSP2 SSP3 SSP4 SSP5"
****SSP - can SSP be high or low
global highlow_list = "low high"
****quantile - can SSP be high or low
global quantile_list = "q5 mean q95"




//set error count
scalar error_count = 0


foreach fuel_type of global fuel_list{
	foreach rcp_type of global rcp_list{
			foreach ssp_type of global ssp_list{
				foreach highlow_type of global highlow_list{
						foreach quantile_type of global quantile_list{

//start capture
	capture{

				
			/*
			%%%%%%%%%%%%%%%%%%%%%%
			Step 2.1: Read given file
			%%%%%%%%%%%%%%%%%%%%%%
			*/

			//set import dummy to identify the scenario I want
			local import_dummy = "`rcp_type'" + "/" ///
						+ "`ssp_type'" +  "/"  ///
						+  "`highlow_type'" + "/unit_" ///
						+ "`fuel_type'" + "_impacts_gj_geography_country_level_years_all_" ///
						+ "`rcp_type'" + "_" + "`ssp_type'" + "_" + ///
						"`highlow_type'" + "_quantiles_" + "`quantile_type'" 
		
			display "`import_dummy'"

			import delimited "$raw/uncertainty_9_12/`import_dummy'.csv", clear
			reshape long year_ , i(iso_code) j(damages) 

			//reshape into long panel
			rename year year_i
			rename damages year
			rename year_i damages
			rename iso_code ISO3
			label var damages "change in energy demand relative to no adaptation, GigaJoules (10e9)"

			//generate merge variables
			gen rcp = "`rcp_type'"
			gen ssp_level = "`highlow_type'"
			gen ssp = "`ssp_type'"
			gen fuel = "`fuel_type'"
			gen quantile = "`quantile_type'"
		
			/*
			%%%%%%%%%%%%%%%%%%%%%%
			Step 2.2: Merge emissions factors
			%%%%%%%%%%%%%%%%%%%%%%
			*/
			
			merge m:1 ISO3 using "$processed/country_year_emissions_factor_2010s_imputed.dta", gen(merge_factors)
			keep if merge_factors==3
			drop merge*
			
			
			/*
			%%%%%%%%%%%%%%%%%%%%%%
			Step 2.3: Merge populations
			%%%%%%%%%%%%%%%%%%%%%%
			*/
			
			local pop_dummy_import = "`ssp_type'" + "_ISO3_population_ts"
			merge m:1 ISO3 year using "$processed/`pop_dummy_import'.dta", gen(merge_populations)
			keep if merge_populations==3
			drop merge_populations
			gen damage_pc = damages
			replace damages = interpolated_population*damages
			
			
			
			
			
			/*
			%%%%%%%%%%%%%%%%%%%%%%
			Step 2.4: convert to emissions and save out
			%%%%%%%%%%%%%%%%%%%%%%
			*/
			
				
			//convert damages in Exo-Joules (10e9 Joules) to kilowatt hours and then change to Gigatons of CO2 
			gen emissions = damages*mean_2010s_electric*277.778/1000000000000 
					
			//correct if its other fuels
			replace emissions = damages*mean_2010s_otherfuels*277.778/1000000000000 if "`fuel_type'"== "other_energy"
			
			//swapped versions
			gen emissions_elec_only = damages*mean_2010s_electric*277.778/1000000000000 
			gen emissions_of_only =  damages*mean_2010s_otherfuels*277.778/1000000000000
			
			//generate whether damages are mean q5 or q95_damages
// 			local name_dummy_damages = "`quantile_type'"  + "_damages"
// 			rename damages `name_dummy_damages'
// 			local name_dummy_emissions = "`quantile_type'"  + "_emissions"
// 			rename emissions `name_dummy_emissions'


			local saveout_dummy =  "`fuel_type'" +"_" + "`ssp_type'" + "_" + "`rcp_type'"  + "_" + "`highlow_type'"  + "_" + "`quantile_type'"


			save "$processed/`saveout_dummy'.dta", replace

			}
			//end capture
			
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$

			//display _rc 
			
				//Count errors in loop
						if _rc!=0 {
						
						scalar error_count = error_count+1
						display error_count
						
						}

						
						
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$
				****end loops over combinations
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$
				}
				//quantile list
			}
			//fuel_list
		}
		//rcp_list
	}
	//ssp_list
}
//highlow list


/*

display error_count --

should be 24 now given two ssp by rcp by high/low combinations don't exist so I lose (high/low * 5 25 50 75 95 mean ) for each
*/
display error_count 
//24






/*
!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$

Step 3: Append all serries into a one dataset for a collapse over the fuels and quantiles 

!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$
*/


/*
%%%%%%%%%%%%%%%%%%%%%%
Step 3.1: append
%%%%%%%%%%%%%%%%%%%%%%	
*/

clear


****LOOP OBJECTS********
************************
****RCP list
global rcp_list = "rcp45 rcp85"
****Fuels
global fuel_list = "electricity other_energy"
****SSP - set of levels
global ssp_list = "SSP1 SSP2 SSP3 SSP4 SSP5"
****SSP - can SSP be high or low
global highlow_list = "low high"
****quantile - can SSP be high or low
global quantile_list = "q5 mean q95"




//set error count
scalar error_count = 0


foreach fuel_type of global fuel_list{
	foreach rcp_type of global rcp_list{
			foreach ssp_type of global ssp_list{
				foreach highlow_type of global highlow_list{
						foreach quantile_type of global quantile_list{

	capture{	
		
		
		local name_dummy=  "`fuel_type'" +"_" + "`ssp_type'" + "_" + "`rcp_type'"  + "_" + "`highlow_type'" + "_" + "`quantile_type'"
		append using "$processed/`name_dummy'.dta"
		
	}
	
	
		if _rc!=0 {
			//Add to error counter if errors in loop
			scalar error_count = error_count+1
			display error_count
						}
						
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$
				****end loops over combinations
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$
					}
					//quantile list

			}
			//fuel_list
		}
		//rcp_list
	}
	//ssp_list
}
//highlow list

//should be 24
display error_count
//great


save "$processed/damages_panel.dta", replace




/*
%%%%%%%%%%%%%%%%%%%%%%
Step 3.2: create country-year-scenario-panel
%%%%%%%%%%%%%%%%%%%%%%	
*/

use "$processed/damages_panel.dta", clear

reshape wide damage_pc damages emissions emissions_elec_only emissions_of_only  , i(year ISO3 interpolated_population Country fuel rcp ssp  ssp_level mean_2010s_electric mean_2010s_otherfuels) j(quantile, string)

//clean and rename
drop emissions_of_onlyq95 emissions_of_onlyq5 emissions_elec_onlyq95 emissions_elec_onlyq5
rename emissionsq95 q95_emissions
rename emissionsq5 q5_emissions
rename emissionsmean mean_emissions
rename damagesq95 q95_damages
rename damagesq5 q5_damages
rename damagesmean mean_damages
rename emissions_of_only mean_of_only
rename emissions_elec_only mean_elec_only



//collapse over fuels for each scenario
collapse (sum) q5_damages q5_emissions q95_damages q95_emissions mean_damages mean_elec_only mean_emissions mean_of_only (mean) interpolated_population mean_2010s_electric mean_2010s_otherfuels , by(year ISO3 Country rcp ssp  ssp_level)



//relabel
label var mean_emissions "Emissions from Mean Change in energy use, Billions (gigatons) metric TCO2"
label var q5_emissions "Emissions from q5 Change in energy use, Billions (gigatons) metric TCO2"
label var q95_emissions "Emissions from q95 Change in energy use, Billions (gigatons) metric TCO2"
label var q5_damages "q5 change in energy demand relative to no adaptation, GigaJoules (10e9)"
label var mean_damages "mean change in energy demand relative to no adaptation, GigaJoules (10e9)"
label var q95_damages "q95 change in energy demand relative to no adaptation, GigaJoules (10e9)"

	
//save proper panel 
save "$processed/country_year_scenario_panel_9_12.dta", replace





/*
%%%%%%%%%%%%%%%%%%%%%%
Step 3.3: kick out country-level time series averaged for each rcp-ssp
%%%%%%%%%%%%%%%%%%%%%%	
*/

use "$processed/damages_panel.dta", clear


//resahpe
reshape wide damage_pc damages emissions emissions_elec_only emissions_of_only  , i(year ISO3 interpolated_population Country fuel rcp ssp  ssp_level mean_2010s_electric mean_2010s_otherfuels) j(quantile, string)

//clean and rename
drop emissions_of_onlyq95 emissions_of_onlyq5 emissions_elec_onlyq95 emissions_elec_onlyq5
rename emissionsq95 q95_emissions
rename emissionsq5 q5_emissions
rename emissionsmean mean_emissions
rename damagesq95 q95_damages
rename damagesq5 q5_damages
rename damagesmean mean_damages
rename emissions_of_only mean_of_only
rename emissions_elec_only mean_elec_only




//collapse over fuels for each scenario
collapse mean_emissions mean_2010s_electric mean_2010s_otherfuels, by(year ISO3 Country rcp ssp)


//generate running cumlative emissions levels
sort ssp rcp ISO3 year

//for baseline

bysort ssp rcp ISO3: gen cml_mean_emiss = mean_emissions[1]
bysort ssp rcp ISO3: replace cml_mean_emiss=mean_emissions[_n]+ cml_mean_emiss[_n-1] if _n>1



///loop
****RCPs
global rcp_list = "rcp45 rcp85"
****SSP
global ssp_list = "SSP1 SSP2 SSP3 SSP4 SSP5"


//set error count
scalar error_count = 0

foreach rcp_type of global rcp_list{
	foreach ssp_type of global ssp_list{
				
		capture{
		//preserve restore
		preserve 
		keep if rcp == "`rcp_type'" & ssp=="`ssp_type'"
		
		local name_dummy1 = "adpatation_emissions_ts_"+"`rcp_type'"+"_" +"`ssp_type'"+".dta"
		save "$objects/Country_Adaptive_Emissions_TS_2/`name_dummy1'", replace

					
				//end capture					
		}
			
		if _rc!=0 {
			//Add to error counter if errors in loop
			scalar error_count = error_count+1
			display error_count
						}
		restore 
		
	}
	
}



clear

/*
%%%%%%%%%%%%%%%%%%%%%%
Step 3.4: collapse over all countries each year
%%%%%%%%%%%%%%%%%%%%%%	
*/


use "$processed/country_year_scenario_panel_9_12.dta", clear

//sum over all ISO codes

collapse (sum)  q5_emissions q95_emissions   mean_emissions mean_elec_only mean_of_only , by(year rcp ssp  ssp_level)


//relabel
label var mean_emissions "Emissions from Mean Change in energy use, Billions (gigatons) metric TCO2"
label var q5_emissions "Emissions from q5 Change in energy use, Billions (gigatons) metric TCO2"
label var q95_emissions "Emissions from q95 Change in energy use, Billions (gigatons) metric TCO2"
label var mean_elec_only "Emissions from Adaptation, electric factors all energy, Billions (gigatons) metric TCO2"
label var mean_of_only "Emissions from Adaptation, other fuels factors all energy, Billions (gigatons) metric TCO2"

//generate cumulative effects

//generate running cumulative emissions for the correct factors as well as altered factors

sort ssp rcp ssp_level year

//for baseline
by ssp rcp ssp_level: gen cml_mean_emiss = mean_emissions[1]
by ssp rcp ssp_level: replace cml_mean_emiss=mean_emissions[_n]+ cml_mean_emiss[_n-1] if _n>1
by ssp rcp ssp_level: gen cml_q5_emiss = q5_emissions[1]
by ssp rcp ssp_level: replace cml_q5_emiss=q5_emissions[_n]+ cml_q5_emiss[_n-1] if _n>1
by ssp rcp ssp_level: gen cml_q95_emiss = q95_emissions[1]
by ssp rcp ssp_level: replace cml_q95_emiss=q95_emissions[_n]+ cml_q95_emiss[_n-1] if _n>1

	

//for all electric factors
by ssp rcp ssp_level: gen cml_mean_emiss_el_fact = mean_elec_only[1]
by ssp rcp ssp_level: replace cml_mean_emiss_el_fact=mean_elec_only[_n]+ cml_mean_emiss_el_fact[_n-1] if _n>1



//for other fuels factors
by ssp rcp ssp_level: gen cml_mean_emiss_of_fact = mean_of_only[1]
by ssp rcp ssp_level: replace cml_mean_emiss_of_fact=mean_of_only[_n]+ cml_mean_emiss_of_fact[_n-1] if _n>1



/*
%%%%%%%%%%%%%%%%%%%%%%
Step 3.5: convert cumulative changes in CO2 to tons carbon equivalent (ie,. into GTC)
%%%%%%%%%%%%%%%%%%%%%%	
*/


//finally, change to carbon from CO2
replace cml_mean_emiss = cml_mean_emiss * (12.011 / 44.009 ) 
replace cml_mean_emiss_el_fact = cml_mean_emiss_el_fact * (12.011 / 44.009 ) 
replace cml_mean_emiss_of_fact = cml_mean_emiss_of_fact * (12.011 / 44.009 ) 
replace cml_q5_emiss = cml_q5_emiss * (12.011 / 44.009 ) 
replace cml_q95_emiss = cml_q95_emiss * (12.011 / 44.009 ) 

//relabel
label var cml_mean_emiss "Cumulative Mean Emissions from Adapt at horizon year, GTC"
label var cml_q5_emiss "Cumulative 5tile Emissions from Adapt at horizon year, GTC"
label var cml_q95_emiss "Cumulative 95tile Emissions from Adapt at horizon year, GTC"
label var cml_mean_emiss_el_fact "Cumulative Mean Emissions from Adapt, electric factors only, at horizon year, GTC"
label var cml_mean_emiss_of_fact  "Cumulative Mean Emissions from Adapt, other factors only, at horizon year, GTC"



save "$processed/aggregate_adaptation_9_12.dta", replace




