/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
This script checks the share of "damages" (increased energy demand from adaptation) as projected in Rode_et_al our paper is able to pair with emissions factors
*/




//set file paths
global root "STARTING_CAF_DIRECTORY"
cd $root 
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"
global objects "/Volumes/ext_drive/objects"



/*
1 - Check emissions match from read-in stage
*/
//factor match
import delimited "$raw/uncertainty_9_12/rcp45/SSP1/high/unit_electricity_impacts_gj_geography_country_level_years_all_rcp45_SSP1_high_quantiles_mean.csv", clear
rename iso_code ISO3
merge m:1 ISO3 using "$processed/country_year_emissions_factor_2010s_imputed.dta", gen(merge_factors)
count

// we match 146/255 of which 144 are eventually relevant in terms of rode data


/*
2 - Check share of energy covered 
*/


import delimited "$raw/uncertainty_9_12/rcp45/SSP1/high/unit_other_energy_impacts_gj_geography_country_level_years_all_rcp45_SSP1_high_quantiles_mean.csv", clear
reshape long year_ , i(iso_code) j(damages) 
rename year year_i
rename damages year
rename year_i damages
rename iso_code ISO3
label var damages "change in energy demand relative to no adaptation, GigaJoules (10e9) per capita"

merge m:1 ISO3 using "$processed/country_year_emissions_factor_2010s_imputed.dta", gen(merge_factors)
keep if merge_factors!=2

merge m:1 ISO3 year using "$processed/`pop_dummy_import'.dta", gen(merge_populations)
keep if merge_populations!=2
replace damages = interpolated_population*damages
gen absolute_damages = abs(damages)
			
			
			
			
gen covered_dummy = (mean_2010s_electric!=. &  mean_2010s_otherfuels !=.)
tab covered_dummy


/*
covered_dum |
         my |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      8,800       43.48       43.48
          1 |     11,440       56.52      100.00
------------+-----------------------------------
      Total |     20,240      100.00

*/



total absolute_damages if covered_dummy==0
/*
Total estimation                             Number of obs = 4,240

------------------------------------------------------------------
                 |      Total   Std. err.     [95% conf. interval]
-----------------+------------------------------------------------
absolute_damages |   3.14e+10   1.58e+09      2.83e+10    3.45e+10
------------------------------------------------------------------


*/

scalar net_nocover = e(b)[1,1]

total absolute_damages if covered_dummy==1
/*


. total damages if covered_dummy==1
Total estimation                            Number of obs = 11,280

------------------------------------------------------------------
                 |      Total   Std. err.     [95% conf. interval]
-----------------+------------------------------------------------
absolute_damages |   8.49e+11   2.55e+10      7.99e+11    8.99e+11
------------------------------------------------------------------


*/

scalar net_cover = e(b)[1,1]


display net_nocover/net_cover
//.03701336



/*
%%%%%%%%%%%%%%%%%%%%%%
Step 2: check share of countries with net negative emissions in 2099
%%%%%%%%%%%%%%%%%%%%%%	
*/


use "$objects/2099_xsection_forkyle.dta", clear




//codebook for iso3 unique
codebook ISO3
//144


count
//184,320
count if ISO3==""
//0

//count 
collapse cum_emiss_total, by( ISO3)

//dummy

gen net_decrease = ( cum_emiss_total < 0 )
tab net_decrease

/*


net_decreas |
          e |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |         25       17.36       17.36
          1 |        119       82.64      100.00
------------+-----------------------------------
      Total |        144      100.00

. 

*/



total cum_emiss_total if cum_emiss_total > 0 
/*
Total estimation                               Number of obs = 22

-----------------------------------------------------------------
                |      Total   Std. err.     [95% conf. interval]
----------------+------------------------------------------------
cum_emiss_total |   1.891249    .815177      .1959953    3.586502
-----------------------------------------------------------------


*/

scalar gross_increase = e(b)[1,1]

total cum_emiss_total if cum_emiss_total < 0 
/*

Total estimation                              Number of obs = 119

-----------------------------------------------------------------
                |      Total   Std. err.     [95% conf. interval]
----------------+------------------------------------------------
cum_emiss_total |  -150.2799    39.5439     -228.5876   -71.97219
-----------------------------------------------------------------

*/

scalar gross_decrease = e(b)[1,1]



display gross_increase/gross_decrease
//-.01258484




/*
%%%%%%%%%%%%%%%%%%%%%%
Step 3: Check GHG share coveragess
%%%%%%%%%%%%%%%%%%%%%%	
*/


use "$objects/2099_xsection_forkyle.dta", clear

//count 
collapse cum_emiss_total, by( ISO3)



merge 1:1 ISO3 using "$objects/essd_ghg_shares.dta", gen(ghg_shares)


total country_year_share if ghg_shares==3

clear
