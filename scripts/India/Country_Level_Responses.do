////start script////
clear all
set more off
macro drop _all

/////////////// SET UP USER SPECIFIC PATHS //////////////////////////////////////////////////////

/*

Path to energy-code-release repo:

NB - this will only work from xander's terminal as given persons will have different GitHub repo paths


*/

//global root "/Users/xabajian/Documents/GitHub/energy-code-release-2020"

/*



10/7/2021

This root directory should now just run straight from Dropbox




*/
global root "/Volumes/ext_drive/india responses/adaptation_multiplier_data/copy_entire_tamma/energy-code-release-2020"



global working_dir "/Volumes/ext_drive/india responses"
/////////////////////////////////////////////////////////////////////////////////////////////////

******Step Zero********************************************************
/*

ACA -- I change some of the local/global macros here to make running code easier and have fewer abstract references

*/
// What model do you want?
global model "TINV_clim"
global model_main "TINV_clim"


****** Set Model Specification Globals ******************************************
global var  "electricity" // What product's response function are we plotting?
// //options: "other_energy" "electricity" 


****** Set Plotting Toggles ****************************************************


// year to plot temporal trend model:

local year = 2099
			
/*
@#$%@#$%@$#%
@#$%@#$%@$#%
@#$%@#$%@$#%



I will be forming estimates for the 140 countries in Rhodes et al.'s sample for the (change in) per capita emissions resulting from marginal changes in demands for electricity and other fuels. See the "README" file in the authors' "make analysis" folder for more details. The regression coefficients I will use  stem from running 

	~/GitHub/energy-code-release-2020/1_analysis/3_interacted_regression.do
	
This produces stored coefficients in the .ster file

	~/GitHub/energy-code-release-2020/sters/FD_FGLS_inter_TINV_clim.ster

I then pull in 140 sets of relevant coefficients (long-run HDDs, CDDs, and income levels) and generate fitted values for each country for marginal demand changes evaluated over the -5 to 35 degree temperature grid.

Finally, I map in my own and IEA's estimates for emisions intensities per kWh of energy used from
	
	~/Dropbox/adaptation_multiplier_data/processedData/country_year_emissions_factor_2010s.dta


	
**************************************
**************************************
**************************************
**************************************

* Step 1: Load Data and Clean for Plotting


ACA -- This step essentially creates the temperature ("x"  variable) grid to plot over along with relevant covariates that are used to plot levels in this estimation

@#$%@#$%@$#%
@#$%@#$%@$#%
@#$%@#$%@$#%
*/


********************************************************************************
//MANUAL read in of the raw data to reprocess
use "$root/data/GMFD_TINV_clim_regsort.dta", clear

//clean data for plotting
drop if _n > 0

//Set up local temperature values for plotting
local obs = 35 + abs(-5) + 1
set obs `obs'

replace temp1_GMFD = _n - 6

foreach k of num 1/2 {
	rename temp`k'_GMFD temp`k'
	replace temp`k' = temp1 ^ `k'
}

gen above20 = (temp1 >= 20) //above 20 indicator
gen below20 = (temp1 < 20) //below 20 indicator


/*******************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************

ACA -- this is unchaged from Tamma's code, I just drop large swathes of loops that allow for options in the 
	more specified version.





* Step 2: Set up for plotting by: 
	* a) finding knot location 
	* b) assigning whether to plot an overlay or not
	
* Get Income Spline Knot Location 
	
********************************************************************************/


	
// preserve
// use "$root/data/break_data_TINV_clim.dta", clear
// summ maxInc_largegpid_$var if largegpid_$var == 1
// scalar ibar_main = `r(max)'
// restore

********************************************************************************
* Step 3: Generate Discrete Differences in Energy Demand for the 140 countries in the dataset
*******************************************************************************


/*
ACA pseudocode:

********************************************************************************
* 	##
********************************************************************************

loop over 140 countries and the two types of energies:
	
	pick energy
	pick country 
	grab covariates through preserve/restore kickout
	set income dummies for splines
	generate fitted data and CIs
	save out there series



*/

/*


Generate numerical country values to loop over by encoding the set of countries


*/
preserve
use "$root/data/break_data_TINV_clim.dta", clear
drop country_index
encode country, gen(country_index)
save "$root/data/break_data_TINV_clim.dta", replace
sum country_index
//140
restore


/*

Perform above loop

*/


foreach type in "electricity"  "other_energy" { //loop over energy types (kind of)

	preserve
	use "$root/data/break_data_TINV_clim.dta", clear
	summ maxInc_largegpid_`type' if largegpid_`type' == 1
	scalar ibar_main = `r(max)'
	restore

	

forval i = 1/140 {	//loop through 140 countries

		


	// grab income and climate covariates to trace out response for this cell
	preserve
	use "$root/data/break_data_TINV_clim.dta", clear
	//keep if country_index==`i'
	keep if country_index==58
	
	//Tamma's code to run with deciles
	/*
	sort tpid tgpid
	duplicates drop country_index, force
	scalar subCDD = avgCDD_tpid[1]
	scalar subHDD = avgHDD_tpid[1]
	scalar subInc = avgInc_tgpid[1]
	*/
	
	
	//My code to run over individual countries grabbing latest year in panel
	sort year 
	gen index = _n
	gen count_dummy = _N
	keep if index == count_dummy
	scalar subCDD = cdd20_TINV_GMFD[1]
	scalar subHDD = hdd20_TINV_GMFD[1]
	scalar subInc = lgdppc_MA15[1]
	restore
					
		// construct income spline
		scalar deltacut_subInc = subInc - ibar_main


		// assign the large income group based on the cell's income covariate
		if subInc > ibar_main local ig 2
		else if subInc <= ibar_main local ig 1

	
		// trace out does response equation and add to local for plotting 
		estimates use "$root/sters/FD_FGLS_inter_TINV_clim"

		

//*		
			/*@#$%@#$%@#$%@@#$%@#$%@#$%@
			@#$%@#$%@#$%@@#$%@#$%@#$%@
			@#$%@#$%@#$%@@#$%@#$%@#$%@

			This generates responses as-written in the Rode paper, normalized to differences from 20C
			
			@#$%@#$%@#$%@@#$%@#$%@#$%@
			@#$%@#$%@#$%@@#$%@#$%@#$%@
			@#$%@#$%@#$%@@#$%@#$%@#$%@*/

		
		//Lazy loop to spit out estimates for both energy types
/*
				 if  "`type'" =="electricity" {
							predictnl yhat_`i'_`type' = _b[c.indp1#c.indf1#c.FD_temp1_GMFD] * (temp1 - 20) + ///
							above20*_b[c.indp1#c.indf1#c.FD_cdd20_TINVtemp1_GMFD]*subCDD * (temp1 - 20) + ///
							below20*_b[c.indp1#c.indf1#c.FD_hdd20_TINVtemp1_GMFD]* subHDD * (20 - temp1) + ///
							_b[c.indp1#c.indf1#c.FD_dc1_lgdppc_MA15I`ig'temp1]* deltacut_subInc *(temp1 - 20^1) + ///
							_b[c.indp1#c.indf1#c.FD_temp2_GMFD] * (temp2 - 20^2) + ///
							above20*_b[c.indp1#c.indf1#c.FD_cdd20_TINVtemp2_GMFD]* subCDD * (temp2 - 20^2) + ///
							below20*_b[c.indp1#c.indf1#c.FD_hdd20_TINVtemp2_GMFD]* subHDD * (20^2 - temp2) + ///
							_b[c.indp1#c.indf1#c.FD_dc1_lgdppc_MA15I`ig'temp2]* deltacut_subInc *(temp2 - 20^2) , /// 
							se(se_`i'_`type') ci(lower_`i'_`type' upper_`i'_`type') 
				
				
			}
			
			else if "`type'"=="other_energy" {
				
							predictnl yhat_`i'_`type' = _b[c.indp2#c.indf1#c.FD_temp1_GMFD] * (temp1 - 20) + ///
							above20*_b[c.indp2#c.indf1#c.FD_cdd20_TINVtemp1_GMFD]*subCDD * (temp1 - 20) + ///
							below20*_b[c.indp2#c.indf1#c.FD_hdd20_TINVtemp1_GMFD]* subHDD * (20^1 - temp1) + ///
							_b[c.indp2#c.indf1#c.FD_dc1_lgdppc_MA15I`ig'temp1]* deltacut_subInc *(temp1 - 20) + ///
							_b[c.indp2#c.indf1#c.FD_temp2_GMFD] * (temp2 - 20^2) +///
							above20*_b[c.indp2#c.indf1#c.FD_cdd20_TINVtemp2_GMFD]* subCDD * (temp2 - 20^2) + ///
							below20*_b[c.indp2#c.indf1#c.FD_hdd20_TINVtemp2_GMFD]* subHDD * (20^2 - temp2) + ///
							_b[c.indp2#c.indf1#c.FD_dc1_lgdppc_MA15I`ig'temp2]* deltacut_subInc *(temp2 - 20^2),///
							se(se_`i'_`type') ci(lower_`i'_`type' upper_`i'_`type') 
				 
	
		}
*/
		

if  "`type'" =="electricity" {
							predictnl yhat_`i'_`type' = _b[c.indp1#c.indf1#c.FD_temp1_GMFD] * (temp1 - 20) + ///
							above20*_b[c.indp1#c.indf#c.FD_cdd20_TINVtemp1_GMFD]*subCDD * (temp1 - 20) + ///
							below20*_b[c.indp1#c.indf#c.FD_hdd20_TINVtemp1_GMFD]* subHDD * (20 - temp1) + ///
							_b[c.indp1#c.indf#c.FD_dc1_lgdppc_MA15I`ig'temp1]* deltacut_subInc *(temp1 - 20^1) + ///
							_b[c.indp1#c.indf1#c.FD_temp2_GMFD] * (temp2 - 20^2) + ///
							above20*_b[c.indp1#c.indf#c.FD_cdd20_TINVtemp2_GMFD]* subCDD * (temp2 - 20^2) + ///
							below20*_b[c.indp1#c.indf#c.FD_hdd20_TINVtemp2_GMFD]* subHDD * (20^2 - temp2) + ///
							_b[c.indp1#c.indf#c.FD_dc1_lgdppc_MA15I`ig'temp2]* deltacut_subInc *(temp2 - 20^2) , /// 
							se(se_`i'_`type') ci(lower_`i'_`type' upper_`i'_`type') 
				
				
			}
			
else if "`type'"=="other_energy" {
				
							predictnl yhat_`i'_`type' = _b[c.indp2#c.indf1#c.FD_temp1_GMFD] * (temp1 - 20) + ///
							above20*_b[c.indp2#c.indf#c.FD_cdd20_TINVtemp1_GMFD]*subCDD * (temp1 - 20) + ///
							below20*_b[c.indp2#c.indf#c.FD_hdd20_TINVtemp1_GMFD]* subHDD * (20^1 - temp1) + ///
							_b[c.indp2#c.indf#c.FD_dc1_lgdppc_MA15I`ig'temp1]* deltacut_subInc *(temp1 - 20) + ///
							_b[c.indp2#c.indf1#c.FD_temp2_GMFD] * (temp2 - 20^2) + ///
							above20*_b[c.indp2#c.indf#c.FD_cdd20_TINVtemp2_GMFD]* subCDD * (temp2 - 20^2) + ///
							below20*_b[c.indp2#c.indf#c.FD_hdd20_TINVtemp2_GMFD]* subHDD * (20^2 - temp2) + ///
							_b[c.indp2#c.indf#c.FD_dc1_lgdppc_MA15I`ig'temp2]* deltacut_subInc *(temp2 - 20^2), ///
							se(se_`i'_`type') ci(lower_`i'_`type' upper_`i'_`type') 
				 
	
		}
				 
///	
		
/*		
			/*@#$%@#$%@#$%@@#$%@#$%@#$%@
			@#$%@#$%@#$%@@#$%@#$%@#$%@
			@#$%@#$%@#$%@@#$%@#$%@#$%@

			This generates responses in levels
			
			@#$%@#$%@#$%@@#$%@#$%@#$%@
			@#$%@#$%@#$%@@#$%@#$%@#$%@
			@#$%@#$%@#$%@@#$%@#$%@#$%@*/

		
		//loop to spit out estimates for both energy types
				 if  "`type'" =="electricity" {
							predictnl yhat_`i'_`type' = _b[c.indp1#c.indf1#c.FD_temp1_GMFD] * (temp1) + above20*_b[c.indp1#c.indf1#c.FD_cdd20_TINVtemp1_GMFD]*subCDD * (temp1) + below20*_b[c.indp1#c.indf1#c.FD_hdd20_TINVtemp1_GMFD]* subHDD * (- temp1) + _b[c.indp1#c.indf1#c.FD_dc1_lgdppc_MA15I`ig'temp1]* deltacut_subInc *(temp1) + _b[c.indp1#c.indf1#c.FD_temp2_GMFD] * (temp2) + above20*_b[c.indp1#c.indf1#c.FD_cdd20_TINVtemp2_GMFD]* subCDD * (temp2) + below20*_b[c.indp1#c.indf1#c.FD_hdd20_TINVtemp2_GMFD]* subHDD * (- temp2) + _b[c.indp1#c.indf1#c.FD_dc1_lgdppc_MA15I`ig'temp2]* deltacut_subInc *(temp2 ), se(se_`i'_`type') ci(lower_`i'_`type' upper_`i'_`type') 
				
				
			}
			
			else if "`type'"=="other_energy" {
				
								predictnl yhat_`i'_`type' = _b[c.indp2#c.indf1#c.FD_temp1_GMFD] * (temp1) + above20*_b[c.indp2#c.indf1#c.FD_cdd20_TINVtemp1_GMFD]*subCDD * (temp1 ) + below20*_b[c.indp2#c.indf1#c.FD_hdd20_TINVtemp1_GMFD]* subHDD * ( - temp1) + _b[c.indp2#c.indf1#c.FD_dc1_lgdppc_MA15I`ig'temp1]* deltacut_subInc *(temp1 ) + _b[c.indp2#c.indf1#c.FD_temp2_GMFD] * (temp2) + above20*_b[c.indp2#c.indf1#c.FD_cdd20_TINVtemp2_GMFD]* subCDD * (temp2 ) + below20*_b[c.indp2#c.indf1#c.FD_hdd20_TINVtemp2_GMFD]* subHDD * ( - temp2) + _b[c.indp2#c.indf1#c.FD_dc1_lgdppc_MA15I`ig'temp2]* deltacut_subInc *(temp2), se(se_`i'_`type') ci(lower_`i'_`type' upper_`i'_`type') 
				 
	
		}
				 
*/
		
		
		
		

	} //loop countries
} //loop fuels

/*

Save the output from above. 


Note that this manually specifies the Dropbox directory we use and will not run on other machines.
*/



//save "/Users/xabajian/Dropbox/adaptation_multiplier_data/temp", replace
save "$working_dir/temp/rhodes_regression_outputs.dta", replace




////////*************////////
////////*************////////
////////*************////////
/*
Ok, now I need to kick out the numerical country indices that I assigned from before and make a crosswalk. This allows me to merge in the emissions intensity factors from the other dropbox files.

*/
////////*************////////
////////*************////////
////////*************////////


use "$root/data/break_data_TINV_clim.dta", clear
collapse country_index , by(country )
save "$working_dir/temp/country_index_xwalk.dta", replace
rename country ISO3
merge 1:1 ISO3 using "$working_dir/processedData/country_year_emissions_factor_2010s.dta", gen(merge_intensities)

/*

merge 1:1 ISO3 using "$working_dir/processedData/country_year_emissions_factor_2010s.dta", gen(merge_intensities)

    Result                      Number of obs
    -----------------------------------------
    Not matched                            23
        from master                         8  (merge_intensities==1)
        from using                         15  (merge_intensities==2)

    Matched                               132  (merge_intensities==3)
    -----------------------------------------

. 
end of do-file



*/

//keep only entries tamma tracks
drop if merge_intensities==2
drop merge_intensities



save "$working_dir/temp/factors_xwalk.dta", replace
clear

/*
////////*************////////
////////*************////////
////////*************////////

//Loop through countries to make dataset of all response functions and upper/lower bounds using the regression output from earlier

////////*************////////
////////*************////////
////////*************////////
*/

use "$working_dir/temp/rhodes_regression_outputs.dta", clear


	

forval i = 1/140 {	//country loop





		//pull in country i's emissions factors
		preserve
		use "$working_dir/temp/factors_xwalk.dta", clear
		keep if country_index==`i'
		scalar elect_factor = mean_2010s_electric 
		scalar other_factor = mean_2010s_otherfuels
		restore
			
			
			
		// keep country i's data
		preserve
		keep temp1 upper_`i'_other_energy lower_`i'_electricity lower_`i'_other_energy upper_`i'_electricity yhat_`i'_electricity yhat_`i'_other_energy
		gen country_index = `i'
		gen UB_elec_emissions = elect_factor * upper_`i'_electricity
		gen predict_elec_emissions = elect_factor * yhat_`i'_electricity 
		gen LB_elec_emissions = elect_factor * lower_`i'_electricity
		gen UB_other_emissions = other_factor * upper_`i'_other_energy
		gen predict_other_emissions = other_factor * yhat_`i'_other_energy
		gen LB_other_emissions = other_factor * lower_`i'_other_energy
		
		gen electricity_emissions_factor = elect_factor
		gen otherfuels_emissions_factor = other_factor
		//generate change in energy demand in kWh
		gen predict_elec_demand = 277.8 * yhat_`i'_electricity 
		gen predict_other_demand = 277.8 * yhat_`i'_other_energy
		
		drop upper_`i'_other_energy lower_`i'_electricity lower_`i'_other_energy upper_`i'_electricity yhat_`i'_electricity yhat_`i'_other_energy

		save "$working_dir/temp/Country_Temp_Respones_Rhodes2020/country_`i'.dta", replace
	
	
		restore
				
		
}
