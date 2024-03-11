/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		set scheme plotplain
		

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




use "$processed/damages_panel.dta", clear
keep if ISO3=="IND" & ssp=="SSP3" & rcp=="rcp85" 

reshape wide damage_pc damages emissions emissions_elec_only emissions_of_only  , i(year ISO3 interpolated_population Country fuel rcp ssp  ssp_level mean_2010s_electric mean_2010s_otherfuels) j(quantile, string)


drop emissions_of_onlyq95 emissions_of_onlyq5 emissions_elec_onlyq95 emissions_elec_onlyq5
rename emissionsq95 q95_emissions
rename emissionsq5 q5_emissions
rename emissionsmean mean_emissions
rename damagesq95 q95_damages
rename damagesq5 q5_damages
rename damagesmean mean_damages
rename emissions_of_only mean_of_only
rename emissions_elec_only mean_elec_only

collapse (mean) q5_damages q5_emissions q95_damages q95_emissions mean_damages mean_elec_only mean_emissions mean_of_only (mean)  mean_2010s_electric mean_2010s_otherfuels , by(year fuel ISO3 Country)


//relabel
label var mean_emissions "Emissions from Mean Change in energy use, Billions (gigatons) metric TCO2"
label var q5_emissions "Emissions from q5 Change in energy use, Billions (gigatons) metric TCO2"
label var q95_emissions "Emissions from q95 Change in energy use, Billions (gigatons) metric TCO2"
label var q5_damages "q5 change in energy demand relative to no adaptation, GigaJoules (10e9)"
label var mean_damages "mean change in energy demand relative to no adaptation, GigaJoules (10e9)"
label var q95_damages "q95 change in energy demand relative to no adaptation, GigaJoules (10e9)"

//emissions
twoway (line mean_emissions year if fuel=="electricity") ///
 (line mean_emissions year if fuel=="other_energy") , ///
 legend(order(1 "Electricity" 2 "Other Fuels")) ///
   ytitle("Annual Change in Emissions from" "Adaptation, GTCO2") ///
 xtitle("Year") ///
 title("Annual Change in Emissions from Energy Use" "for Adaptation in India, 2020-2099") 
graph export "/Volumes/ext_drive/india responses/india_emissions.png", as(png) name("Graph") replace

 //damages
 replace mean_damages = mean_damages/1000000000
 twoway (line mean_damages year if fuel=="electricity") ///
 (line mean_damages year if fuel=="other_energy") , ///
 legend(order(1 "Electricity" 2 "Other Fuels")) ///
   ytitle("Annual Change in Energy use, EJ") ///
 xtitle("Year") ///
 title("Annual Change in Energy Use" "for Adaptation in India, 2020-2099") 
graph export "/Volumes/ext_drive/india responses/india_damage.png", as(png) name("Graph") replace

 
 
  title("Decomposition of Annual Change in Emissions from Energy Use" "for Adaptation in India, 2020-2099") 

 title("Decomposition of Annual Change in Energy Use" "for Adaptation in India, 2020-2099") 

