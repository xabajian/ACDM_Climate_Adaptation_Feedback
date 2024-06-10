/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Script 0 accounting for globally-decaying emissions factors.
*/




//set file paths

global root "STARTING_CAF_DIRECTORY"
cd $root 
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"
global objects "$root/objects"



/*
%%%%%%%%%%%%%%%%%%%%%%
Step 1: Recreate country-year-scenario-panel
%%%%%%%%%%%%%%%%%%%%%%	
*/

use "$processed/damages_panel.dta", clear

reshape wide damage_pc damages emissions emissions_elec_only emissions_of_only  , i(year ISO3 interpolated_population Country fuel rcp ssp  ssp_level mean_2010s_electric mean_2010s_otherfuels) j(quantile, string)


//Decay Coefficients
//decay_other decay_elec
//-.00078227-.0088665

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

gen d_year = year - 2020

gen electric_decay_factor = exp(-.0088665 * d_year)
gen otherfuel_decay_factor = exp(-.00078227 * d_year)

replace mean_emissions = mean_emissions * electric_decay_factor if fuel=="electricity"
replace mean_emissions = mean_emissions * otherfuel_decay_factor if fuel=="other_energy"

//collapse over fuels for each scenario
collapse (sum) mean_emissions , by(year ISO3 Country rcp ssp  ssp_level)



//relabel
label var mean_emissions "Emissions from Mean Change in energy use, Billions (gigatons) metric TCO2"

//save proper panel 
save "$processed/country_year_scenario_panel_9_12_decay.dta", replace





/*
%%%%%%%%%%%%%%%%%%%%%%
Step 2: collapse over all countries each year
%%%%%%%%%%%%%%%%%%%%%%	
*/


use "$processed/country_year_scenario_panel_9_12_decay.dta", clear

//sum over all ISO codes

collapse (sum)   mean_emissions  , by(year rcp ssp  ssp_level)


//relabel
label var mean_emissions "Emissions from Mean Change in energy use, Billions (gigatons) metric TCO2"

//generate cumulative effects

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



save "$processed/aggregate_adaptation_9_12_decay.dta", replace




