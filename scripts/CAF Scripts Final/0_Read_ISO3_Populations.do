/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Read in country-level opulation levels from Rode
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

Step 1: Aggregate IR files up to the ISO level from the ones in "READ IR POPULATIONS" script

!#@$!@#$!$#$
!#@$!@#$!$#$
!#@$!@#$!$#$
*/


****LOOP OBJECTS********
************************
****SSP - set of levels
global ssp_list = "SSP1 SSP2 SSP3 SSP4 SSP5"

//loop for series over all 5 SSPs
foreach ssp_type of global ssp_list{
		
	
		local import_dummy = "`ssp_type'" + "_population_ts"
		use "$processed/`import_dummy'.dta", clear
		
		gen ISO3 = substr(region ,1, 3)
		
		collapse (sum) interpolated_population, by(year ssp ISO3)
		
		local save_dummy = "`ssp_type'" + "_ISO3_population_ts"
		save "$processed/`save_dummy'.dta", replace
		

}
