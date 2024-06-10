/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
cross section dataset
*/



//set file paths
global root "STARTING_CAF_DIRECTORY"
cd $root 
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"
global objects "$root/objects"



/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Step 1: Create country-level TS of covariates from Rode

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/

use "$objects/covariates_FD_FGLS_719_Exclude_all-issues_break2_semi-parametric_TINV_clim.dta", clear
keep if year==2010
gen ISO3 = substr(region,1,3)

collapse (mean) loggdppc logpopop  tashdd20  tascdd20  (sum) population, by(ISO3)

sort population

xtile gdp_pc_3tile = loggdppc, nquantiles(3)
save "$objects/covariates_for_xsection.dta", replace



/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$

Step 2: Create country-level 2099 cross-section from the full panel

!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/



use "$processed/country_year_scenario_panel_9_12.dta", clear


			

//totals through 2099
collapse (sum)  q5_emissions q95_emissions   mean_emissions mean_elec_only mean_of_only , by(ISO3 rcp ssp  ssp_level)

//average across SSP_levels
 collapse   q5_emissions q95_emissions   mean_emissions mean_elec_only mean_of_only , by(ISO3 rcp ssp)


/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
merge covarariates
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/

merge m:1  ISO3 using "$objects/covariates_for_xsection.dta", gen(merge_covariates)
keep if merge_covariates==3

gen cml_mean_emiss = mean_emissions
drop mean_emissions
gen cumulative_abatement_pc = cml_mean_emiss / (population)
label var cumulative_abatement_pc "cumulative abatment due to adaptation normalized by projected population"
label var population "projected population"




/*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
merge historical  GHG emissions shares 
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/

merge m:1 ISO3 using "$objects/essd_ghg_shares.dta", gen(ghg_shares)

tab  ISO3  if ghg_shares==1

/*

       ISO3 |      Freq.     Percent        Cum.
------------+-----------------------------------
        MNE |          8       50.00       50.00
        SRB |          8       50.00      100.00
------------+-----------------------------------
      Total |         16      100.00

*/

keep if ghg_shares==3

gen historical_emissions = value/1000000000

gen log_historical = log(historical_emissions)
gen log_abatement = log(-cml_mean_emiss)
gen gdp = exp(loggdppc) * population  
gen historical_pc  =  historical_emissions / population


/*
%%%%%%%%%%%%%%%%%%%%%%
kick out data for maps and gaps
%%%%%%%%%%%%%%%%%%%%%%
*/

save "$processed/cumulative_abatement_revised.dta", replace
//save "$processed/cumulative_abatement.dta", replace 


