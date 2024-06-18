/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Create historical GHG emissions shares at the country level between 2015-19
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
!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$

Step 0: Grab data on annual emissions from https://zenodo.org/record/5566761#.Ypeehy-B0_U

import

!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$
*/

//read  excel files into .dta files.

import excel "$objects/essd_ghg_data.xlsx", sheet("data") firstrow

//label variables for consistency with other files
label var value "CO2 emissions from all sectors, Metric Tons"
rename ISO ISO3
rename country Country
save  "$objects/essd_ghg_data.dta", replace






/*
!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$

Step 1.5: Solve for global total each year

!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$
*/


gen co2_eq = value*gwp100_ar5
collapse (sum) co2_eq,by(year)
label var co2_eq "Annual Anthropogenic GHG Emissions Excluding LULUCF, GTCO2-eq"
replace co2_eq = co2_eq/1000000000



twoway scatter co2_eq year if year<2020, ///
ytitle("Gigatons, CO2-eq")  title("Annual Anthropogenic GHG Emissions, 1970 - 2019") note("Data taken from Jinx et al. 2021.") ///
xtitle("Year")

graph export "/Users/xabajian/Dropbox/adaptation_multiplier_data/Draft/GHG_emissions_ts.pdf", as(pdf) name("Graph") replace

/*
!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$

Step 2: Solve for annual totals in years 2015-2019, assign each country a share of global total, average for last five years

!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$
*/

use "$objects/essd_ghg_data.dta", clear
keep if year>2014 & year<2020
keep if gas=="CO2"
drop gwp100_ar5 gas



collapse (sum) value,by(year ISO3 Country region_ar6_6 region_ar6_10 region_ar6_22 region_ar6_dev)



/*
create global emissions
*/

by year: egen global_total = sum(value)

/*
create country-year shares
*/

gen country_year_share = value/global_total

/*
collapse over last five years
*/
gen stderror_share = country_year_share
gen stderror_value = value

collapse (mean) value country_year_share (semean) stderror_value stderror_share , by(ISO3 Country region_ar6_6 region_ar6_10 region_ar6_22 region_ar6_dev)

//check 
total country_year_share
sort country_year_share
tab Country, sum(country_year_share)



save "$objects/essd_ghg_shares.dta", replace


/*
!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$

Step 3: Cumulative emissions for TC

!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$
*/


use "$objects/essd_ghg_data.dta", clear
keep if  year<2020
keep if gas=="CO2"
drop gwp100_ar5 gas



collapse (sum) value,by( ISO3 Country region_ar6_6 region_ar6_10 region_ar6_22 region_ar6_dev)
label var value "Historical MTCO2 emitted"
rename value historical_cml_co2
replace historical_cml_co2 = historical_cml_co2/1000000000
keep historical_cml_co2 ISO3
save "$objects/cumulative_historical.dta", replace

export delimited using "$objects/cumulative_historical.csv", replace

