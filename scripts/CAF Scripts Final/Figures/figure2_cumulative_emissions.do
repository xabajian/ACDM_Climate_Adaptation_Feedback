* Figure 2c: cumulative CO2 from adaptation time series

/**********************  HEADER ************************************/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Read in global emissions and temperature time series.
Read in updated impact-region level files containing mean and 5-95qtile damages for both fuels.
Each file read in gives means as well as 90% CIs across rcp/ssp/iam level scenarios
Combine to create CAF
*/




//set file paths
cd "/Volumes/ext_drive/uncertainty_8_12_22"
global root "/Volumes/ext_drive/uncertainty_8_12_22"
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"
global figures "$root/figures"

/********************** MAIN ************************************/


use $processed/CAF_by_scenario, clear

	rename Delta_Emissions_Mean em
	rename Delta_Emissions_q5 emq5
	rename Delta_Emissions_q95 emq95

//Main time series: SSP2-RCP85.
	preserve

	keep if ssp == "SSP2" & rcp=="rcp85"

	//average across "high" and "low" for a given SSP
	collapse (mean) em emq5 emq95, by(year)

	//convert from GtC to GtCO2
	replace em=em*3.67
	replace emq5=emq5*3.67
	replace emq95=emq95*3.67


	//figure
	twoway ///
	(rarea emq5 emq95 year, color(edkblue%20) lwidth(none)) ///
	(line em year,  lwidth(.6) color(edkblue) lpattern(solid) ///
	text(235 2011 "{bf:c}", size(medlarge)) /// //panel label
	)  ///
	,  ///
	xtitle("Year") ///
	ytitle("Cumulative adaptation-induced CO{sub:2} emission changes (GtCO{sub:2})", size(small)) ///
	yline(0, lpattern(solid) lcolor(gs10) lwidth(.25) ) ///
	xlabel(2020(10)2100, nogrid) ///
	ylabel(, nogrid) ///
	legend(off)
	
 	graph export $figures/fig2c.pdf, as(pdf) replace





