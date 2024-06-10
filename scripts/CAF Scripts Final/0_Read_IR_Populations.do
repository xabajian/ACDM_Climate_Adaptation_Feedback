/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Read in impact-region level population files
*/




//set file paths
global root "STARTING_CAF_DIRECTORY"
cd $root 
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"

/*
!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$

Step 1: Generate balanced panel of population at the impact-region level 
using raw data from Rode et al Covariates

!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$
*/

import delimited "$raw/population/population-merged.all.csv", clear
encode region, gen(region_byte)
format year %ty
drop index


****LOOP OBJECTS********
************************
****SSP - set of levels
global ssp_list = "SSP1 SSP2 SSP3 SSP4 SSP5"

//loop for series over all 5 SSPs
foreach ssp_type of global ssp_list{

		preserve
		
		//keep select SSP
		keep if ssp == "`ssp_type'"
		drop ssp
		gen ssp = "`ssp_type'"
		xtset region_byte year 

		//generate full time-series
		tsfill, full

		//interpolate values using linear splines
		sort region_byte year
		bysort region_byte: ipolate value year, gen(interpolated_population)
		drop value
		
		//drop missing areas entirely
		drop if interpolated_population==.
		
		
		//replace region string
		sort region_byte year
		bysort region_byte: replace region =  region[_n-1] if region=="" 

		//save out dummy
		local save_dummy = "`ssp_type'" + "_population_ts"
		save "$processed/`save_dummy'.dta", replace
		
		restore

}
