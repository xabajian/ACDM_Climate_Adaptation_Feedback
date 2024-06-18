/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Read in (country) level files files containing mean and 5-95qtile damages for both fuels.

Each file will give one of the mean, 5 or 95th quantile across rcp/ssp/iam level scenarios
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
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
Step 1: Create loop block for CSVs. 


The CSV files are the annual energy demand changes (at the country level),
sorted by electricity and other fuels, across all models./ssp/highlow/ that 
occur due to adaptation.

This loop creates a time series for each country for each scenario of changes in energy demand.
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/



/*
%%%%%%%%%%%%%%%%%%%%%%
LOOP BLOCK
%%%%%%%%%%%%%%%%%%%%%%
*/

//Loop parts :

****Fuels
global fuel_list = "other_energy electricity"

/*
%%%%%%%%%%%%%%%%%%%%%%
LOOP BLOCK
%%%%%%%%%%%%%%%%%%%%%%
*/

scalar error_count = 0

/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
Step 2:Run Loop to read in scenarios, reshape, and merge emissions factors and GMST paths for given RCP-GCM-Low/High combination.
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/


foreach fuel_type of global fuel_list{

				
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$

//start capture
capture {

			//set import dummy to identify the scenario I want
			local import_dummy =  "`fuel_type'" + "_noadapt"


			//import damage functions for given fuel/rcp/gcm/ssp/highlow combo

			import delimited using "$no_adapt/`import_dummy'.csv", clear


			//generate ISO 3 codes for each region
			gen ISO3 = substr(regions,1,3)

			//sum all regions in given country
			collapse (sum) year* ,by(ISO3)


			/*
			%%%%%%%%%%%%%%%%%%%%%%
			Step 2.1: Merge emissions factors
			%%%%%%%%%%%%%%%%%%%%%%
			*/

			merge 1:1 ISO3 using "$processed/country_year_emissions_factor_2010s_imputed.dta", gen(merge_factors)
			keep if merge_factors==3
			drop merge*
			gen fuel = "`fuel_type'"
			/*
			%%%%%%%%%%%%%%%%%%%%%%
			Step 2.2: reshape
			%%%%%%%%%%%%%%%%%%%%%%
			*/

			reshape long year_,i(Country mean_2010s_electric mean_2010s_otherfuels ISO3) j(damage)
			rename year_ damages
			rename damage year
			label var damages "change in energy demand relative to no adaptation, GigaJoules (10e9)"

			

			save "$processed/`import_dummy'.dta", replace

			}
			//end capture
			
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$

			//display _rc 
			
				//Count errors in loop
						if _rc!=0 {
						
						scalar error_count = error_count+1
						
						}
						
						
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$
				****end loops over combinations
//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$//!@#$!#@$!@$!@#$!#$!#@$!#$!#@$!$


}
//fuel_list
display error_count



/*
%%%%%%%%%%%%%%%%%%%%%%
Step 3: Append all files and convert damages
%%%%%%%%%%%%%%%%%%%%%%
*/

clear

scalar error_count = 0

foreach fuel_type of global fuel_list {

				//capture to force loop
					capture {

					local append_dummy =  "`fuel_type'" + "_noadapt"
					
					
					append using "$processed/`append_dummy'.dta", force
					//display "`append_dummy'"


					}




}

display error_count
//0 -- note there are no errors because we just append blank files for the missing rcp-ssp combinations




//save full panel dataset
save "$processed/no_adapt_panel.dta", replace


/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
Step 4: Convert Rode damages into emissions damages and rebase to remove effects of 2000 through 2010

%%%%%%%%%%%%%%%%%%%%%%
*/



use "$processed/no_adapt_panel.dta", clear

//convert damages in Exo-Joules (10e9 Joules) to kilowatt hours and then chnage to Gigatons of C 
gen damages_emissions = damages*mean_2010s_electric*277.778/1000000000000 * (12.011/44.01)
replace damages_emissions = damages*mean_2010s_otherfuels*277.778/1000000000000 * (12.011/44.01) if fuel=="other_energy"
label var damages_emissions "Adaptation's Change in Emissions, Billions (gigatons) MTC"



sort ISO3 fuel year 

by ISO3 fuel: egen baseline_2000s_average = mean(damages_emissions) if year>2000 & year < 2011
by ISO3 fuel: egen dummy = max(baseline_2000s_average) 

gen damages_emissions_centered = damages_emissions-dummy
 

//collapse over countries in each year
collapse (sum) damages_emissions_centered, by(year)
label var damages_emissions_centered "Adaptation's Change in Emissions, Billions (gigatons) MTC"



//save out
save "$processed/no_adapt_aggregate.dta", replace







