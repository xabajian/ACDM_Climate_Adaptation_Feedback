* Figure 3: Main CAF figure

/**********************  HEADER ************************************/

//Call global parameters and filepath


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




//Local parameters

/********************** MAIN ************************************/


use $processed/CAF_by_scenario, clear

	rename Adaptation_Feedback CAF
	rename Adaptation_Feedback_q5 CAFq5
	rename Adaptation_Feedback_q95 CAFq95

//Panel a: time series, SSP2-RCP85.
	preserve

	keep if ssp == "SSP2" & rcp=="rcp85"

	//average across "high" and "low" for a given SSP
	collapse (mean) CAF CAFq5 CAFq95, by(year rcp ssp)

	//merge with dynamic CAF
	merge 1:1 year using $processed/dynamic_CAF_rcp85ssp2, keepusing(rcp85_w_dynamic_CAF rcp85_baseline_GMST) 
	gen CAF_dyn=rcp85_w_dynamic_CAF-rcp85_baseline_GMST
	drop _merge

	//Merge with decay CAF
	merge 1:1 year using $processed/AF_withdecay_TS.dta
	drop _merge
	
	//figure
	twoway ///
	(rarea CAFq5 CAFq95 year, color(midgreen%20) lwidth(none)) ///
	(line CAF year,  lwidth(.6) color(midgreen) lpattern(solid)) ///
	(line CAF_dyn year,  lwidth(.4) color(dkgreen) lpattern(shortdash)) ///
	(line decay_CAF year,  lwidth(.4) color(lime%60) lpattern(longdash) ///
	text(.07 2011 "{bf:a}", size(medium)) /// //panel label
	)  ///
	,  ///
	xtitle("Year") ///
	ytitle("CAF ({sup:o}C)", size(small) margin(large)) ///
	ysc(titlegap(-8) outergap(0)) ///
	yline(0, lpattern(solid) lcolor(gs10) lwidth(.25) ) ///
	xlabel(2020(10)2100, nogrid) ///
	ylabel(-0.35(0.05)0.05, nogrid) ///
	legend( ///
	ring(0) position(7) col(1) bmargin(medsmall) size(small) ///
	order( ///
	2 "CAF point estimate (benchmark)" ///
	1 "CAF 90% CI (benchmark)" ///
	3 "CAF point estimate (w/ dynamics)" ///
	4 "CAF point estimate (w/ decaying factors)" ///
	)) ///
	saving($figures/3a.gph, replace) 

	restore

//Panel c: SSP-RCP Bar chart 
	preserve

	keep if year==2099

	//average across "high" and "low" for a given SSP
	collapse (mean) CAF CAFq5 CAFq95, by(year rcp ssp)

	replace rcp="RCP8.5" if rcp=="rcp85"
	replace rcp="RCP4.5" if rcp=="rcp45"

	graph bar CAF, ///
	text(.04 -12.5 "{bf:c}", size(medium)) /// //panel label
	over(ssp, axis(noline) label(labsize(small))) nofill ///
	yline(0, lpattern(solid)) ///
	over(rcp, label(labsize(small)))  ///
	ylabel(-.15(.05)0, nogrid) ///
	ytitle("2099 CAF ({sup:o}C)", size(small)) ///
	ysc(titlegap(-1) outergap(0)) ///
	legend(off) ///
	fysize(25)   ///
 	saving($figures/3c.gph, replace)
 	restore


//Panel b: CAF breakdown 

	use $processed/CAF_by_scenario_by_fuel, clear

	keep if ssp == "SSP2" & rcp=="rcp85" 

	//average across "high" and "low" for a given SSP
	collapse (mean) Fuel_CAF, by(fuel year)

	reshape wide Fuel_CAF, i(year) j(fuel) string

	merge 1:1 year using $processed/decomp_panel, keepusing(F_bar_w FEs_w CAF)
	drop _merge

	keep if year==2099

	rename Fuel_CAFelectricity CAF_elec
	rename Fuel_CAFother CAF_other
	rename F_bar CAF_Fbar
	rename FEs CAF_FEs
	rename CAF CAF_all

	reshape long CAF, i(year) j(name) string

	replace name="Total" if name=="_all"
	replace name="Electricity" if name=="_elec"
	replace name="Other fuels" if name=="_other"
	replace name="Constant global CO{sub:2} int." if name=="_Fbar"
	replace name="Global+cntry CO{sub:2} int." if name=="_FEs"

	gen order=.
	replace order=1 if regexm(name, "Total")
	replace order=2 if regexm(name, "Electricity")
	replace order=3 if regexm(name, "Other")
	replace order=4 if regexm(name, "Constant gl")
	sort order 

	graph bar CAF if order<=4, ///
	text(.11 -12.2 "{bf:b}", size(medium)) /// //panel label
	over(name, axis(noline) sort(order) ///
	relabel(4 "Benchmark" 2 "Only electricity" 3 "Only other fuels" 1 `" "w/ constant global" "CO{sub:2} intensity" "') ///
	label(labsize(small))) ///
	yline(0, lpattern(solid)) ///
	ylabel(-.20(.05).05, nogrid) ///
	intensity(40) ///
	ytitle("2099 CAF ({sup:o}C)", size(small) margin(medium)) ///
	ysc(titlegap(-7) outergap(0)) ///
	legend(off) ///
	fysize(25)   ///
 	saving($figures/3b.gph, replace)	

//older b: CAF breakdown (with F breakdown)
/*
	use $dataDir/CAF_by_scenario_by_fuel, clear

	keep if ssp == "SSP2" & rcp=="rcp85" 

	//average across "high" and "low" for a given SSP
	collapse (mean) Fuel_CAF, by(fuel year)

	reshape wide Fuel_CAF, i(year) j(fuel) string

	merge 1:1 year using $dataDir/decomp_panel, keepusing(F_bar_w FEs_w CAF)
	drop _merge

	keep if year==2099

	rename Fuel_CAFelectricity CAF_elec
	rename Fuel_CAFother CAF_other
	rename F_bar CAF_Fbar
	rename FEs CAF_FEs
	rename CAF CAF_all

	reshape long CAF, i(year) j(name) string

	replace name="Total" if name=="_all"
	replace name="Electricity" if name=="_elec"
	replace name="Other fuels" if name=="_other"
	replace name="Global CO{sub:2} int." if name=="_Fbar"
	replace name="Global+cntry CO{sub:2} int." if name=="_FEs"

	gen order=.
	replace order=1 if regexm(name, "Electricity")
	replace order=2 if regexm(name, "Other")
	replace order=3 if regexm(name, "Global CO")
	replace order =4 if regexm(name, "cntry")
	sort order 

	graph bar CAF if name!="Total", ///
	text(.15 -11.5 "{bf:c}", size(medium)) /// //panel label
	over(name, axis(noline) sort(order) ///
	relabel(1 "Electricity" 4 "Other fuels" 2 `" "w/ global" "CO{sub:2} intensity" "' 3 `" "w/ global+cntry" "CO{sub:2} intensities" "') ///
	label(labsize(small))) ///
	yline(0, lpattern(solid)) ///
	yline(-.12, lstyle(foreground) lw(.3) lpattern(solid) lcolor(midgreen)) ///
	ylabel(-.15(.05).05, nogrid) ///
	intensity(40) ///
	ytitle("2099 CAF comp. ({sup:o}C)", size(small)) ///
	ysc(titlegap(-7) outergap(0)) ///
	legend(off) ///
	fysize(25)   ///
 	saving($tempDir/3b.gph, replace)	
*/

//Combining graphs
 	graph combine $figures/3a.gph $figures/3b.gph $figures/3c.gph, ///
 	col(1) imargin(small) xsize(3.4) //3.5 fxsize(80) 


 	graph export $figures/fig3.pdf, as(pdf) replace





