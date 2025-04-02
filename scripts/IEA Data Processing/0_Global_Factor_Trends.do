/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
Global trends in emissions factors.
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/


//set file paths
cd ~/Dropbox/adaptation_multiplier_data
	
	


//data folders 
global startDir "/Users/xabajian/Dropbox/adaptation_multiplier_data"
global rawDir "$startDir/rawData_local"
global processedDir "$startDir/processedData_local"
global tempDir "$startDir/temp_local"
set scheme plotplain


//load factors

use "$processedDir/country_year_emissions_factor.dta", clear


encode ISO3, gen(country_index)
merge m:1 country_index using "$startDir/temp_local/populations.dta", gen(merge_populations)
keep if merge_populations==3

collapse otherfuels_emissions_factor electricity_emissions_factor [fw= country_year_total_energy], by(year)

twoway (line electricity_emissions_factor year if year<2019 & year>1999) ///
 (line otherfuels_emissions_factor  year if year<2019 & year>1999), ///
legend(order(1 "Electricity" 2 "Other Fuels")) ///
ytitle("Global Emissions from Energy Use, MTCO{sub:2} x kWh {sup:-1}") ///
xtitle("Year") ///
//note("This figure compares trend in the gslobal average CO2 emissions factors (MTCO2/kWh)" "from energy consumption each year between 2000-18.") 
graph export "/Users/xabajian/Desktop/AF Ref Response/global_trends.png", as(png) name("Graph") replace


gen ln_of = ln(otherfuels_emissions_factor) 
gen ln_elec = ln(electricity_emissions_factor) 

nl (ln_of = {k} + {beta}*year) if year<2019 & year>1999

scalar decay_other = e(b)[1,2]



nl (ln_elec =  {k} + {beta}*year) if year<2019 & year>1999
scalar decay_elec = e(b)[1,2]

display decay_other decay_elec
//-.00078227-.0088665

