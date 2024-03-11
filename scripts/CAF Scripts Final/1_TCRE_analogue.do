/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Alexander Abajian

5/17/2022

Create a mapping between the RCP 8.5 concentration time samples with a time series of emissions

*/




//set file paths OLD

// cd "/Volumes/ext_drive/Results/
// global root "/Volumes/ext_drive"
// global csv "$root/Results/csv"
// global processed "$root/Results/processed"
// global objects "$root/objects"
// global processed "$root/for_kcm"
//


//set file paths
cd "/Volumes/ext_drive/uncertainty_8_12_22"
global root "/Volumes/ext_drive/uncertainty_8_12_22"
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"
global objects "$root/objects"


/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Step 1: Create TS of annual global emissions and cumulative emissions based on the RCPs. 
RCP forecasts are only decadal so we must interpolate emissions


		RCP series: https://tntcat.iiasa.ac.at/RcpDb/dsd?Action=htmlpage&page=download.
		
		The RCP database aims at documenting the emissions, concentrations, and land-cover change projections of the so-called "Representative Concentration Pathways" (RCPs).
			kept by the IIASA (International Institute for Applied Systems Analysis: IIASA)
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$s
*/


/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
step 1.1: Generate time series of global CO2 emissions, RCP 4.5
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/

//read in raw rcp covered years
import excel "$objects/rcp45_global.xls", sheet("transpose emissions") firstrow clear

//fill time series to interpolate
tsset year
tsfill


//interpolate values using linear splines
ipolate CO2emissionsGTCeq year, generate(fitted_emissions)


//eye check
// twoway (line CO2emissionsGTCeq year) (line fitted_emissions year)


//merge gmst paths
merge 1:1 year using "$objects/GMST_model_average_rcp45_SEs.dta", gen(merge_gmst)

keep if merge_gmst==3
drop merge_gmst

//generate cumulative emissions measure
sort year
gen cum_emissions_RCP = fitted_emissions[1]
replace cum_emissions_RCP = cum_emissions_RCP[_n-1] + fitted_emissions[_n] if _n>1


//save series out
save "$objects/rcp45_baseline_emissions.dta", replace

clear








/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
step 1.2: Repeat for RCP 8.5
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/

//import raw rcp85 emissions data for the set of covered years
import excel "$objects/rcp85_global.xls", sheet("transpose emissions") firstrow clear
drop D


//fill time series to interpolate
tsset year
tsfill

//interpolate values using linear splines
ipolate CO2emissionsGTCeq year, generate(fitted_emissions)

//eye check
// twoway (line CO2emissionsGTCeq year) (line fitted_emissions year)


//merge gmst paths
merge 1:1 year using "$objects/GMST_model_average_rcp85_SEs.dta", gen(merge_gmst)
keep if merge_gmst==3
drop merge_gmst

//generate cumulative emissions measure
sort year
gen cum_emissions_RCP = fitted_emissions[1]
replace cum_emissions_RCP = cum_emissions_RCP[_n-1] + fitted_emissions[_n] if _n>1


//save series out
save "$objects/rcp85_baseline_emissions.dta", replace

clear




/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Step 2: Append the two series and merge into the series wrt adaptation


!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/

use "$objects/rcp85_baseline_emissions.dta", clear
append using "$objects/rcp45_baseline_emissions.dta"
merge 1:m year rcp using "$processed/gcm_temp_series.dta", gen(merge_gcm_temp_series)

keep if merge_gcm_temp_series!=.
tab merge_gcm_temp_series

/*
. tab merge_gcm_temp_series

   Matching result from |
                  merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        Master only (1) |         42        0.10        0.10
            Matched (3) |     41,600       99.90      100.00
------------------------+-----------------------------------
                  Total |     41,642      100.00

*/
drop merge_gcm_temp_series


keep if year>2019 & year<2100
/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/


/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Step 3: Create beta described in section 2 of the paper. This is a mapping between cumulative emissions and change in GMST 

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/


/*
Make alternative temperature and emissions series starting at zero for baseline year 2020, accounting for the initial year (year 2020) adaptation and its effect on temperature that year
*/

sort ssp rcp gcm ssp_level year 

//re-center dT relative to year 2020
bysort ssp rcp gcm ssp_level: gen temp_0 = gcm_temp[1]
bysort ssp rcp gcm ssp_level: gen dT_Cumulative = gcm_temp - temp_0

//re center baseline RCP emissions and emissions with adaptation
//rcp baseline in 2020
bysort ssp rcp gcm ssp_level: gen e_0  = cum_emissions_RCP[1]
bysort ssp rcp gcm ssp_level: gen dE_cum_RCP = cum_emissions_RCP - e_0




/*

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Linear fits of change in GMST on change in cumulative carbon emissions, by SSP/RCP scenarios in order to to generate effects of adaptation on temperature.

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

*/



//run regression of dT on dCarbon fixing an SSP and SSP level so we don't double count multiple GCM-temperature-RCP series runs
reg dT_Cumulative dE_cum_RCP if ssp=="SSP2" & ssp_level=="low", r noconstant




/*
#!$#!%@##!%
Spot checks
#!$#!%@##!%
*/

gen year_floor = year/5 - floor(year/5)

//label variables

label var year "Year"



/*
%%%%%%%%%%%%%%%%%%%%%%
kick out panel
%%%%%%%%%%%%%%%%%%%%%%
*/

preserve
keep dT_Cumulative dE_cum_RCP year ssp rcp ssp_level year_floor gcm
save "$processed/tcre.dta", replace 
restore

