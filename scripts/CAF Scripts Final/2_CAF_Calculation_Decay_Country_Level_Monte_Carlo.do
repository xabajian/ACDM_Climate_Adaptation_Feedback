/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
MC over script 2 with decay terms
*/





//set file paths

global root "STARTING_CAF_DIRECTORY"
cd $root 
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"
global objects "$root/objects"



matrix AF_MC = [.]

quietly{
forvalues i = 1/1000 {
	
		/*
		%%%%%%%%%%%%%%%%%%%%%%
		Step 1: Re-draw emissions factors
		%%%%%%%%%%%%%%%%%%%%%%	
		*/

		use "$processed/country_level_trends.dta", clear 
		
		gen seed = runiform()
		
		sum trend_elec1
		scalar electric_floor =  r(min) 
		sum trend_of1
		scalar otherfuels_floor =  r(min) 
		
		replace trend_elec1 = electric_floor*seed
		replace trend_of1 = otherfuels_floor*seed
		
		drop seed
		
		save "$temp/country_level_trends.dta", replace 
		/*
		%%%%%%%%%%%%%%%%%%%%%%
		Step 2: Recreate country-year-scenario-panel
		%%%%%%%%%%%%%%%%%%%%%%	
		*/

		use "$processed/damages_panel.dta", clear
		reshape wide damage_pc damages emissions emissions_elec_only emissions_of_only  , i(year ISO3 interpolated_population Country fuel rcp ssp  ssp_level mean_2010s_electric mean_2010s_otherfuels) j(quantile, string)


		//Merge Country-Level Decay Coefficients
		merge m:1 ISO3 using "$temp/country_level_trends.dta",


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
		gen d_year = year - 2020
		gen electric_decay_factor = exp(trend_elec1 * d_year)
		gen otherfuel_decay_factor = exp(trend_of1 * d_year)
		replace mean_emissions = mean_emissions * electric_decay_factor if fuel=="electricity"
		replace mean_emissions = mean_emissions * otherfuel_decay_factor if fuel=="other_energy"
		collapse (sum) mean_emissions , by(year ISO3 Country rcp ssp  ssp_level)



		//relabel
		label var mean_emissions "Emissions from Mean Change in energy use, Billions (gigatons) metric TCO2"

		//save proper panel 
		save "$temp/country_year_scenario_panel_9_12_decay_country_level.dta", replace





		/*
		%%%%%%%%%%%%%%%%%%%%%%
		Step 3: collapse over all countries each year
		%%%%%%%%%%%%%%%%%%%%%%	
		*/
		use "$temp/country_year_scenario_panel_9_12_decay_country_level.dta", clear

		//sum over all ISO codes
		collapse (sum)   mean_emissions  , by(year rcp ssp  ssp_level)

		//relabel
		label var mean_emissions "Emissions from Mean Change in energy use, Billions (gigatons) metric TCO2"


		//generate running cumulative emissions for the correct factors as well as altered factors
		sort ssp rcp ssp_level year

		//for baseline
		by ssp rcp ssp_level: gen cml_mean_emiss = mean_emissions[1]
		by ssp rcp ssp_level: replace cml_mean_emiss=mean_emissions[_n]+ cml_mean_emiss[_n-1] if _n>1

		/*
		%%%%%%%%%%%%%%%%%%%%%%
		Step 3.5: convert cumulative changes in CO2 to tons carbon equivalent (ie,. into GTC)
		%%%%%%%%%%%%%%%%%%%%%%	
		*/


		//finally, change to carbon from CO2
		replace cml_mean_emiss = cml_mean_emiss * (12.011 / 44.009 ) 

		//relabel
		label var cml_mean_emiss "Cumulative Mean Emissions from Adapt at horizon year, GTC"
		
		//save
		save "$temp/aggregate_adaptation_9_12_decay_country_level.dta", replace





		/*
		!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

		Step 4: Append the two series and merge in the tseries of aggregate adaptation

		!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
		*/





		use "$processed/rcp85_baseline_emissions.dta", clear
		append using "$processed/rcp45_baseline_emissions.dta"



		//new series with decay seed
		merge 1:m year rcp using "$temp/aggregate_adaptation_9_12_decay_country_level.dta", gen(merge_adaptation_emissions)
		keep if year>2019 & year<2100
		drop merge



		//generate new cumulative series for each rcp/ssp scenario that accounts for adaptation_multiplier_data/Draft/adaptation_feedback
		gen rcp_adapt_cml_mean = cml_mean_emiss +  cum_emissions_RCP


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
		// -.0773232 
		scalar AF = r(mean)
 
		matrix AF_MC = AF_MC \AF
		
	}
}


svmat AF_MC

save "$temp/monte_carlo_results.dta", replace
		
		
		/*
		*/
		
use "$temp/monte_carlo_results.dta", clear
label var AF_MC1 "CAF in year 2099, Degrees C"
