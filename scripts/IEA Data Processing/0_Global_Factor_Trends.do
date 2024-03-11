
/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

11/5/2021


What are global trends in emissions factors.
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


use "$processedDir/country_year_emissions_factor.dta", clear


encode ISO3, gen(country_index)
merge m:1 country_index using "$startDir/temp_local/populations.dta", gen(merge_populations)
keep if merge_populations==3

collapse otherfuels_emissions_factor electricity_emissions_factor [fw= country_year_total_energy], by(year)

twoway (line otherfuels_emissions_factor year if year<2019 & year>1999) ///
 (line electricity_emissions_factor year if year<2019 & year>1999), ///
legend(order(1 "Other Fuels" 2 "Electricity")) ///
ytitle("MTCO2 Emitted per kWh of Energy") ///
xtitle("Year") ///
//note("This figure compares trend in the global average CO2 emissions factors (MTCO2/kWh)" "from energy consumption each year between 2000-18.") 
graph export "/Volumes/ext_drive/uncertainty_8_12_22/figures/global_trends.png", as(png) name("Graph") replace


gen ln_of = ln(otherfuels_emissions_factor) 
gen ln_elec = ln(electricity_emissions_factor) 

nl (ln_of = {k} + {beta}*year) if year<2019 & year>1999

scalar decay_other = e(b)[1,2]



nl (ln_elec =  {k} + {beta}*year) if year<2019 & year>1999
scalar decay_elec = e(b)[1,2]

display decay_other decay_elec
-.00078227-.0088665


/*
Rode Elec: 0.3959
https://www.wolframalpha.com/input/?i=0.3959968320253437972496220030239758081935344517243862049103607171&assumption=%22ClashPrefs%22+-%3E+%7B%22Math%22%7D


Rode Other: 0.1799985
https://www.wolframalpha.com/input/?i=1000*0.05%2F277.78
*/
