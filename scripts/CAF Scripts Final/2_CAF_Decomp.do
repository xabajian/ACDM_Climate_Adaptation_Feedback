/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Alexander Abajian

3/16/2023

Decomposition exercise under SSP2-RCP85
*/





//set file paths
cd "/Volumes/ext_drive/uncertainty_8_12_22"
global root "/Volumes/ext_drive/uncertainty_8_12_22"
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"



//generate residualized emissions
use "$processed/country_year_emissions_factor_2010s_imputed.dta", clear

encode ISO3, gen(iso_code)

//assign factors
gen factor_1 = mean_2010s_electric 
gen factor_2 = mean_2010s_otherfuels

//merge these into CAF data
drop mean_2010s_* other_elec_ratio



reshape long factor_, i(iso_code) j(factor)

gen fuel = "electricity" if factor==1
replace fuel = "other_energy" if factor==2
drop factor
rename factor_ emissions_factor
label var emissions_factor "emissions, kgco2 per kwh"



//merge in emissions weights

merge m:1 ISO3 using "$processed/2019_emissions.dta",  gen(merge_2019_emissions)
keep if merge_2019_emissions!=2
//replace lowest emissions

egen min_emissions = min(co2_eq)
replace co2_eq = min_emissions if co2_eq==.
drop merge_2019_emissions min_emissions


/*
run regression
*/

reg emissions_factor i.iso_code, r

//generate fittred values
predict xb
rename xb fitted_factors


//generate intercept term
gen intercept = _b[_cons]

//generate FEs
gen fes = fitted_factors- intercept
//sanity
duplicates r fes


//generate residuals
gen residuals = emissions_factor - fitted_factors


//sanity.2
gen factor_decomp_sum = intercept+fes+residuals
corr factor_decomp_sum emissions_factor



/*
repeat with fixed intercept 
*/

gen moments = co2_eq * emissions_factor

total co2_eq
scalar mass_total = e(b)[1,1]

total moments
scalar moments_total = e(b)[1,1]

gen intercept_weighted =   moments_total/mass_total

/*
re-estimate FEs
*/


gen no_intercept = emissions_factor - intercept_weighted

reg no_intercept i.iso_code, noconstant r 
predict xb
rename xb fes_weighted


//generate intercept term
gen residuals_weighted = no_intercept - fes_weighted

/*
repeat with fixed intercept  no weights
*/
sum emissions_factor

gen intercept_naive = r(mean)
gen no_intercept_naive = emissions_factor - intercept_naive

reg no_intercept_naive i.iso_code, noconstant r 
predict xb
rename xb fes_weighted_naive


//generate intercept term
gen residuals_naive = no_intercept_naive - fes_weighted_naive



drop iso_code factor_decomp_sum Country fitted_factors no_intercept factor_decomp_sum moments co2_eq


save "$processed/factor_panel.dta",  replace



/*
merge for decomp
*/


use "$processed/damages_panel.dta",  clear

//keep means
keep if quantile=="mean"
keep if ssp=="SSP2" & rcp =="rcp85" 
drop emissions_elec_only emissions_of_only other_elec_ratio quantile ssp rcp

merge m:1 ISO3 fuel using "$processed/factor_panel.dta", gen(merge_factor_decomp)
keep if merge_factor_decomp==3

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             8
        from master                         0  (merge_factor_decomp==1)
        from using                          8  (merge_factor_decomp==2)

    Matched                            46,080  (merge_factor_decomp==3)
    -----------------------------------------

. keep if merge_factor_decomp==3
*/


sort ISO3 fuel ssp_level year

//for cumulative damages 
drop damage_pc
by ISO3 fuel ssp_level: gen cumulative_damage = damage[1]
by ISO3 fuel ssp_level: replace cumulative_damage=damage[_n]+ cumulative_damage[_n-1] if _n>1

//for cumulative emissions 
by ISO3 fuel ssp_level: gen cumulative_emissions = emissions[1]
by ISO3 fuel ssp_level: replace cumulative_emissions=emissions[_n]+ cumulative_emissions[_n-1] if _n>1

label var cumulative_emissions "Emissions from Mean Change in energy use, Billions (gigatons) metric TCO2"
label var cumulative_damage "change in energy demand relative to no adaptation, GigaJoules (10e9)"




//unweighted emissions from damages, converting to billionns tons CO2 
gen emissions_Fbar = cumulative_damage * intercept  * 277.778/1000000000000 
gen emissions_fes =cumulative_damage *  fes *277.778/1000000000000 
gen emissions_residual = residuals *277.778/1000000000000 

//weighted
gen emissions_Fbar_w = cumulative_damage *  intercept_weighted  * 277.778/1000000000000 
gen emissions_fes_w = cumulative_damage *  fes_weighted *277.778/1000000000000 
gen emissions_residual_w = cumulative_damage *  residuals_weighted *277.778/1000000000000 

//naive weighted
gen emissions_Fbar_naive = cumulative_damage *  intercept_naive  * 277.778/1000000000000 
gen emissions_fes_naive = cumulative_damage *  fes_weighted_naive *277.778/1000000000000 
gen emissions_residual_naive = cumulative_damage *  residuals_weighted *277.778/1000000000000 


//collapse over all countries
collapse (sum) cumulative_emissions emissions_Fbar emissions_fes emissions_residual emissions_Fbar_w emissions_fes_w emissions_residual_w emissions_Fbar_naive emissions_residual_naive emissions_fes_naive, by(year ssp_level)
collapse (mean) cumulative_emissions emissions_Fbar emissions_fes emissions_residual emissions_Fbar_w emissions_fes_w emissions_residual_w emissions_Fbar_naive emissions_residual_naive emissions_fes_naive, by(year)


//convert to carbon and then to temperature 

/*

From "1_TCRE_analogue" do file


. reg dT_Cumulative dE_cum_RCP if ssp=="SSP2" & ssp_level=="low", r noconstant

Linear regression                               Number of obs     =      5,200
                                                F(1, 5199)        =   10801.21
                                                Prob > F          =     0.0000
                                                R-squared         =     0.8544
                                                Root MSE          =     .68588

------------------------------------------------------------------------------
             |               Robust
dT_Cumulat~e | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  dE_cum_RCP |   .0022562   .0000217   103.93   0.000     .0022136    .0022987
------------------------------------------------------------------------------


*/

gen F_bar =.0022562   *  emissions_Fbar * (12.011 / 44.009 ) 
gen FEs = .0022562   * (emissions_fes + emissions_Fbar) * (12.011 / 44.009 ) 
gen F_bar_w = .0022562 * emissions_Fbar_w * (12.011 / 44.009 ) 
gen FEs_w = .0022562 *(emissions_Fbar_w + emissions_fes_w) * (12.011 / 44.009 ) 
gen F_bar_naive = .0022562 * emissions_Fbar_naive * (12.011 / 44.009 ) 
gen FEs_naive =  .0022562 *(emissions_fes_naive + emissions_Fbar_naive) * (12.011 / 44.009 ) 
gen CAF = .0022562 *  (12.011 / 44.009 ) * cumulative_emissions



twoway (line F_bar_naive year, lcolor(blue)) (line FEs_naive year, lcolor(red))  (line CAF year, lcolor(black) lpattern(dash)) , ///
legend(order(1 "FBar" 2 "+ FEs" 3 "CAF")) ///
title("Naive Weight for Fbar")
twoway (line F_bar_w year, lcolor(blue) ) (line FEs_w year, lcolor(red))  (line CAF year, lcolor(black) lpattern(dash)) , ///
legend(order(1 "FBar" 2 "+ FEs" 3 "CAF")) ///
title("Historical Emissions-Weighted Fbar")


save  "$processed/decomp_panel.dta"
