* Figure 2d: TCRE scatter

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
cd "/Volumes/ext_drive/uncertainty_8_12_22"
global root "/Volumes/ext_drive/uncertainty_8_12_22"
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"
global figures "$root/figures"

/********************** MAIN ************************************/


	use $processed/tcre, clear

	//values are just duplicated across SSP and SSP-level
	keep if ssp=="SSP2" & ssp_level=="low" & rcp=="rcp85"


//regression
	reg dT_C dE_cum_RCP, robust
	lincom dE_cum_RCP

	local b: display %5.4f r(estimate)
	local p: display %5.4f r(p)
	local r2: display %4.2f e(r2)

//scatter
	tw ///
		(sc dT_C dE_cum_RCP, mcolor(gs8%30) msy(circle) msize(.75pt)) ///
		(lfitci dT_C dE_cum_RCP , ///
		level(90) lwidth(.8) lp(solid) lcolor(`color') alwidth(none) fcolor(`color'%30)) ///
		(lpoly dT_C dE_cum_RCP, ///
		lwidth(.8) lcolor(`color') lpattern(dash) ///
		text(8.2 -150 "{bf:d}", size(medium)) /// //panel label
		text(.2 1250 "Linear coefficient: `b', p-value: `p'. R{sup:2} = `r2'")) ///
		, ///
		xtitle("Cumulative CO{sub:2} emissions (in GtC)", size(medium)) ///
		ytitle("GMST change ({sup:o}C)", size(medium)) ///
		xlabel(0(300)1800, nogrid) ///
		ylabel(, nogrid) ///
		legend(off) 

 	graph export $figures/fig2d.pdf, replace




