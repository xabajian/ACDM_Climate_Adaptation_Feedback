
/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

11/5/2021


What are country-level trends in emissions factors.
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

keep if year >1999 & year<2019

//Save index crosswalk

preserve
keep ISO3 country_index
collapse country_index , by(ISO3)
save  "$processedDir/index_country_xwalk.dta", replace
restore

matrix trend_of =[.]
matrix trend_elec = [.]
matrix country_index =[.]

	gen ln_of = ln(otherfuels_emissions_factor) 
	gen ln_elec = ln(electricity_emissions_factor) 
	
	
//run trend for each country, each fuel
forvalues i = 1/140{
	
		//alphas post
	capture{

	nl (ln_of = {k} + {beta}*year)  if country_index==`i'
	scalar decay_other = e(b)[1,2]
	nl (ln_elec =  {k} + {beta}*year) if country_index==`i'
	scalar decay_elec = e(b)[1,2]
	
	matrix trend_of = trend_of \ decay_other
	matrix trend_elec = trend_elec \ decay_elec
	
	}
	
	if _rc!=0{
		
	matrix trend_of = trend_of \ .
	matrix trend_elec = trend_elec \ .
	}
		
	
	//append coefficients
	matrix country_index = country_index \ `i'

	//restore
	
	
}

svmat trend_of 
svmat country_index 
svmat trend_elec
sum trend_of1 country_index1 trend_elec1

keep if country_index1!=.
keep trend_of1 country_index1 trend_elec1
rename country_index1 country_index

merge 1:1 country_index using "$processedDir/index_country_xwalk.dta"
drop _merge*

sum 

count

twoway (kdensity trend_elec1) (kdensity trend_of1), ///
xtitle("Country-Level Trends in Emissions Factors") ///
legend(order(1 "Electicity" 2 "Other Fuels"))

//counts
count if trend_of1>0
count if trend_elec1>0

/*
Soft min
*/

replace trend_elec1 = 0 if trend_elec1==.
replace trend_elec1 = 0 if trend_elec1>0
replace trend_of1 = 0 if trend_of1==.
replace trend_of1 = 0 if trend_of1>0




save  "$processedDir/country_level_trends.dta", replace


/*
Rode Elec: 0.3959
https://www.wolframalpha.com/input/?i=0.3959968320253437972496220030239758081935344517243862049103607171&assumption=%22ClashPrefs%22+-%3E+%7B%22Math%22%7D


Rode Other: 0.1799985
https://www.wolframalpha.com/input/?i=1000*0.05%2F277.78
*/
