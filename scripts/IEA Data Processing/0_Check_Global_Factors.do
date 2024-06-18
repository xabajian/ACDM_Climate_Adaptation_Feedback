/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Aggregate global aggregate emissions factors

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


//read factors by country-year level

use "$processedDir/country_year_emissions_factor.dta", clear


encode ISO3, gen(country_index)
merge m:1 country_index using "$tempDir/populations.dta", gen(merge_populations)
keep if merge_populations==3 & year==2018

sum otherfuels_emissions_factor electricity_emissions_factor 
sum otherfuels_emissions_factor electricity_emissions_factor [fw= country_year_total_energy]

/*
Rode Elec: 0.3959
https://www.wolframalpha.com/input/?i=0.3959968320253437972496220030239758081935344517243862049103607171&assumption=%22ClashPrefs%22+-%3E+%7B%22Math%22%7D


Rode Other: 0.1799985
https://www.wolframalpha.com/input/?i=1000*0.05%2F277.78
*/
