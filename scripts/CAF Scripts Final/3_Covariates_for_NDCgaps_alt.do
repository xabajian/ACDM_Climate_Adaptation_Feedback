/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
3-- cross section dataset for NDC gaps
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



use "$processed/damages_panel.dta", clear
		

//totals through 2099
collapse (sum) emissions , by(ISO3 rcp ssp  ssp_level fuel)


//average across SSP_levels
 collapse   emissions , by(ISO3 rcp ssp fuel)

merge m:1  ISO3 using "$objects/covariates_for_xsection.dta", gen(merge_covariates)
 /*
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
merge covarariates
!$@#$!#$!@$!$@#$!#$!@$!$@#$!#$!@$
*/
keep if merge_covariates==3

gen cml_mean_emiss = emissions
drop emissions
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

save "$processed/cumulative_abatement_revised_byfuel.dta", replace


