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
cd "/Volumes/ext_drive/uncertainty_8_12_22"
global root "/Volumes/ext_drive/uncertainty_8_12_22"
global processed "$root/processed"
global temp "$root/temporary"
global raw "$root/raw"
global figures "$root/figures"
global objects "$root/objects"



/********************** MAIN ************************************/

	///new
	use $processed/cumulative_abatement_revised, replace
	rename cml_mean_emiss cum_emiss_total
	keep if ssp == "SSP2" & rcp=="rcp85"
	sum cum_emiss_total
	
	/* in text statistics */
	count if cum_emiss_total>0
	count if cum_emiss_total < 0
	
	//countries dith dE > 0
	sum cum_emiss_total if cum_emiss_total>0, d
	
	//countries dith dE < 0
	sum cum_emiss_total if cum_emiss_total<0, d
	
	//eritrea v US
	sum cum_emiss_total if Country=="Eritrea"
	sum cum_emiss_total if Country=="United States"
	
	
//Panel a top: map
	preserve
	
	merge 1:1 ISO3 using $processed/country_GIS_db_noAntarctica
	tab _merge
	

	
	local mapV "cum_emiss_total"
	sum `mapV', d
	local topCut =2
	local botCut = -16
	local int = 2

	gen `mapV'_t=`mapV'
	replace `mapV'_t=`botCut' if `mapV'<`botCut'
	replace `mapV'_t=`topCut' if (`mapV'>`topCut' & !missing(`mapV'))

	local nColors=1+(`topCut'-`botCut')/`int'
	local lColors "`botCut'(`int')`topCut'"
	local colors `r(p)'

	spmap `mapV'_t using $processed/country_GIS_coord_noAntarctica, ///
		id(_ID) ///
		clmethod(custom) clbreaks(`lColors') fcolor(navy navy*0.8 navy*0.7 navy*0.6 navy*0.5 navy*0.4 navy*0.3 navy*0.2 red*0.75) /// 
		osize(none ..) ocolor(none ..) ///
		ndfcolor(sienna*0.4) ndocolor(white) ndsize(vvthin) ///
		legend(on size(small) ///
		label(2 "[-40,-14]")) ///
		legtitle("2099 cumulative" "CO{sub:2} chg (GtCO{sub:2})") ///
		plotregion(margin(zero)) ///
		graphregion(margin(zero)) ///
		text(83 -179 "{bf:a}", size(medium)) ///
		saving($figures/four_a_top.gph, replace) 
		
		
// 		clmethod(custom) clbreaks(`lColors') fcolor(BuYlRd) /// 



//Panel a bottom: Histogram 
 	sum cum_emiss_total if cum_emiss_total<0, d
	sum cum_emiss_total if cum_emiss_total>0, d


	
	local topCut =2
	local botCut = -10
	local int = 2
	
	drop cum_emiss_total_t
	gen `mapV'_t=`mapV'
	replace `mapV'_t=`botCut' if `mapV'<`botCut'
	replace `mapV'_t=`topCut' if (`mapV'>`topCut' & !missing(`mapV'))


	twoway ///
	(histogram `mapV'_t if `mapV'_t<0,  width(.25) fcolor(navy) lcolor(black) lwidth(.1)  frequency) ///
	(histogram `mapV'_t if `mapV'_t>0,  width(.25) fcolor(red) lcolor(black) lwidth(.1)  frequency) ///
	, ///
	xlabel(-10(2)2, nogrid) ///
	xlabel(-10 "-40,-10", add) ///	
	ylabel(0(15)45, nogrid) ///
	xtitle("Cumulative adaptation-induced CO{sub:2} emissions changes by 2099 (GtCO{sub:2})") ///
	legend(off) ///
	fysize(25)   ///
	plotregion(margin(zero)) ///
	graphregion(margin(zero)) ///
	saving($figures/four_a_bot.gph, replace)

	restore

//Combine top
 	graph combine $figures/four_a_top.gph $figures/four_a_bot.gph, ///
 	col(1) imargin(zero) fysize(82) ///
 	saving($figures/four_a.gph, replace) 

 	graph export $figures/fig4a.pdf, replace



//Panel b: Historical scatter
	local color "purple"

	gen l_future_a=log(-cum_emiss_total)
	gen l_hist_e=log(historical_emissions)

	merge 1:1  ISO3  using ///  
	"$objects/cumulative_historical.dta", gen(merge_cml)
		gen l_hist_cml=log10(historical_cml_co2)
	gen l_future_10=log10(-cum_emiss_total)
	
	
	//summarize cumulative historical emissions
	//Eritrea
	sum historical_cml_co2 if Country=="eritrea"
	
	//USA
	sum historical_cml_co2 if Country=="united states"
	
// 	reg l_future_10 l_hist_cml, robust
// 	lincom l_hist_cml
	reg l_future_a l_hist_e, robust
	lincom l_hist_e

	local b: display %4.2f r(estimate)
	local p: display %4.2f r(p)
	local r2: display %4.2f e(r2)
	local bigN: display %4.2f e(N)
	
	
	/*
	tw ///
		(lfitci l_future_10 l_hist_cml, ///
		level(95) lwidth(.45) lcolor(`color') alwidth(none) fcolor(`color'%30)) ///
		(lpoly l_future_10 l_hist_cml, ///
		lwidth(.2) lcolor(`color') lpattern(dash)) ///
		(sc l_future_10 l_hist_cml, mcolor(purple%100) msy(circle) msize(small) ///
		text(4.5 -9.5 "{bf:b}", size(vlarge)) /// //panel label
		text(-6.3 -1 "Linear coefficient: `b', p-value: `p'. R{sup:2} = `r2'")) ///
		, ///
		xtitle("log past CO{sub:2} emissions (2015-2019 avg)", size(large)) ///
		ytitle("log adaptation-induced CO{sub:2}" "emissions abatement (by 2099)", size(large)) ///
		xlabel(-2(1)3, nogrid) ///
		ylabel(-3(1)3, nogrid) ///
		legend(off) 
		
		*/
		
		
	tw ///
		(lfitci l_future_a l_hist_e, ///
		level(95) lwidth(.45) lcolor(`color') alwidth(none) fcolor(`color'%30)) ///
		(lpoly l_future_a l_hist_e, ///
		lwidth(.2) lcolor(`color') lpattern(dash)) ///
		(sc l_future_a l_hist_e, mcolor(purple%100) msy(circle) msize(small) ///
		text(4.5 -9.5 "{bf:b}", size(vlarge)) /// //panel label
		text(-6.3 -1 "Linear coefficient: `b', p-value: `p'. R{sup:2} = `r2'")) ///
		, ///
		xtitle("log past CO{sub:2} emissions (2015-2019 avg)", size(large)) ///
		ytitle("log adaptation-induced CO{sub:2}" "emissions abatement (by 2099)", size(large)) ///
		xlabel(, nogrid) ///
		ylabel(, nogrid) ///
		legend(off) 

 	graph export $figures/fig4b.pdf, replace

*
//Panel c: Future NDC scatter

	use $processed/NDC_gaps, replace

	gen adapt_abate=ssp5_cumulative-ssp5_adapt_cumulative //adaptation abatement (positive means abatement)
	sum adapt_abate, d

	gen ndc_abate=ssp5_cumulative-ndc_cumulative
	sum ndc_abate

	gen ratio=adapt_abate/ndc_abate
	
	sum ratio if ratio<50 , d 
	sum ratio if ratio>0 &  ratio<50, d
	
	gen ratio_t=ratio
	replace ratio_t=1.05 if ratio_t>1
	replace ratio_t=-1.05 if ratio_t<-1


	tw(hist ratio_t, width(.05) fcolor(gs5) lcolor(black) lwidth(.05) frequency ///
	text(25 -1.25 "{bf:c}", size(vlarge)) /// //panel label
	) ///
	, ///
	xtitle("Share of NDC abatement from adaptation-induced abatement", size(large)) ///
	ytitle("Frequency", size(large)) ///
	xlabel(, nogrid) ///
	ylabel(, nogrid) ///
	yscale(range(0 16)) ///
	saving($figures/four_c.gph, replace)

 	graph export $figures/fig4c.pdf, replace
*/


/*
//This combine failed in STATA to get right aspect ratio


 	graph combine $tempDir/four_b.gph $tempDir/four_c.gph, ///
 	rows(1) imargin(zero) ///
 	saving($tempDir/4bc.gph, replace) 


 	graph combine $tempDir/4a.gph $tempDir/4bc.gph, cols(1) imargin(zero)  

 	graph export $figuresDir/fig4.pdf, as(pdf) replace
*/
