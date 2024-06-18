*Figure 4

/**********************  HEADER ************************************/


	clear all
	set more off
	set trace off
	set tracedepth 2
	set matsize 11000 //10000
	set maxvar 32000
	set type double
	set scheme plotplain

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



/********************** MAIN ************************************/

	///new
	use $processed/cumulative_abatement_revised, replace
	rename cml_mean_emiss cum_emiss_total
	keep if ssp == "SSP2" & rcp=="rcp85"
	sum cum_emiss_total
	encode ISO3, gen(country_byte)
	count
	
	
//Panel a top: map

matrix LOO_emissions = [.]
matrix country_index = [.]
qui{
forvalues i = 1/142{
	
	preserve
	keep if country_byte!=`i'
	//replace cum_emiss_total = - cum_emiss_total if country_byte==`i'
	total cum_emiss_total
	scalar total_emissions = e(b)[1,1]
	
	matrix LOO_emissions = LOO_emissions \ total_emissions
	matrix country_index  = country_index \ `i'
	restore
}
}


svmat LOO_emissions
svmat country_index
total cum_emiss_total
local bl_emissions = e(b)[1,1]


twoway /// 
(histogram  LOO_emissions, xlabel(-200(20)-140) freq bins(30) color(blue%30)  xline(`bl_emissions', lcolor(gray) lpattern(dash))) , ///
title("Leave-One-Out Cumulative Changes in Global Emissions in 2099" ) ///
ytitle("Frequency") xtitle("Cumulative Change in Global Emissions, 2099 (GTCO{sub:2})") 

graph export $figures/loo_hist.png, as(png) name("Graph") replace





//note("This figure shows the frequency of average daily temperatures across 160 counties" "in historical data for 2006 and in projections under RCP8.5 from the" "ACCESS1-3 (BoM-CSIRO, Australia) model. Dashed vertical lines are at 12.5" "and 27.5 degrees C.")


