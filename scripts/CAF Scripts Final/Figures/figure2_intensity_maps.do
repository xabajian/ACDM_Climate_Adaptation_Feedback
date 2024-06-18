* Figure 2: CO2 intensity maps

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




//Local parameters
	local topCut =.9
	local botCut = 0
	local int = .1

/********************** MAIN ************************************/

	use $processed/cumulative_abatement, replace

	duplicates drop ISO3, force
	rename mean_2010s_electric elec
	rename mean_2010s_otherfuels other
 
	//currently in kgco2 per kWh. need to convert to tons CO2 per GJoule
	replace elec=elec*(1/1000)*(1/.0036)
	replace other=other*(1/1000)*(1/.0036)


//Panel a top: CO2 intensity maps: electricity

preserve

	local mapV "elec"

	keep ISO3 Country elec other
	
	merge 1:1 ISO3 using $processed/country_GIS_db_noAntarctica
	tab _merge

	sum `mapV', d


	gen `mapV'_t=`mapV'
	replace `mapV'_t=`botCut' if `mapV'<`botCut'
	replace `mapV'_t=`topCut' if (`mapV'>`topCut' & !missing(`mapV'))

	local nColors=1+(`topCut'-`botCut')/`int'
	local lColors "`botCut'(`int')`topCut'"
	colorpalette hcl, n(`nColors')  reverse nograph
	//colorpalette hcl, n(`nColors') heat reverse nograph
	local colors `r(p)'

	spmap `mapV'_t using $processed/country_GIS_coord_noAntarctica, ///
		id(_ID) ///
		clmethod(custom) clbreaks(`lColors') fcolor("`colors'") /// 
		osize(none ..) ocolor(none ..) ///
		ndfcolor(gs15) ndocolor(white) ndsize(vvthin) ///
		legend(on size(medsmall) ///
		) ///
		legtitle("Electricity CO{sub:2}" "intensity (tCO{sub:2}/GJ)") ///
		plotregion(margin(zero)) ///
		graphregion(margin(zero)) ///
		text(83 -179 "{bf:a}", size(large)) ///
		saving($figures/fig2a_top.gph, replace) 

//Panel a bottom: Histogram 
	sum `mapV', d
	sum `mapV'_t, d
	
	twoway ///
	(histogram `mapV'_t,  width(.01) fcolor(gs5) lcolor(black) lwidth(.05)  frequency) ///
	, ///
	ylabel(, nogrid) ///
	xlabel(`botCut'(`int')`topCut', nogrid) ///
	xtitle("Electricity CO{sub:2} intensity (tCO{sub:2}/GJ)", size(medium)) ///
	ytitle("Frequency", size(medium)) ///
	legend(off) ///
	fysize(20)   ///
	plotregion(margin(zero)) ///
	graphregion(margin(zero)) ///
	saving($figures/fig2a_bot.gph, replace) 

restore


//Combine top
 	graph combine $figures/fig2a_top.gph $figures/fig2a_bot.gph, ///
 	col(1) imargin(zero) ///
 	fysize(80) ///
 	saving($figures/fig2a.gph, replace) 

 	graph export $figures/fig2a.pdf, replace



//Panel b top: CO2 intensity maps: other

preserve

	local mapV "other"

	keep ISO3 Country elec other
	
	merge 1:1 ISO3 using $processed/country_GIS_db_noAntarctica
	tab _merge

	sum `mapV', d
	local max=r(max)
	local max: display %2.1f r(max)

	gen `mapV'_t=`mapV'
	replace `mapV'_t=`botCut' if `mapV'<`botCut'
	replace `mapV'_t=`topCut' if (`mapV'>`topCut' & !missing(`mapV'))

	local nColors=1+(`topCut'-`botCut')/`int'
	local lColors "`botCut'(`int')`topCut'"
	colorpalette hcl, n(`nColors')  reverse nograph
	//colorpalette hcl, n(`nColors') heat reverse nograph
	local colors `r(p)'

	spmap `mapV'_t using $processed/country_GIS_coord_noAntarctica, ///
		id(_ID) ///
		clmethod(custom) clbreaks(`lColors') fcolor("`colors'") /// 
		osize(none ..) ocolor(none ..) ///
		ndfcolor(gs15) ndocolor(white) ndsize(vvthin) ///
		legend(on size(medsmall) ///
		label(`nColors' "(.8, `max']") ///
		) ///
		legtitle("Other fuels CO{sub:2}" "intensity (tCO{sub:2}/GJ)") ///
		plotregion(margin(zero)) ///
		graphregion(margin(zero)) ///
		text(83 -179 "{bf:b}", size(large)) ///
		saving($figures/fig2b_top.gph, replace) 


//Panel a bottom: Histogram 
	sum `mapV', d
	sum `mapV'_t, d

	twoway ///
	(histogram `mapV'_t, width(.01) fcolor(gs5) lcolor(black) lwidth(.05)  frequency) ///
	, ///
	ylabel(, nogrid) ///
	xlabel(`botCut'(`int')`topCut', nogrid) ///
	xlabel(`topCut' "`topCut',`max'", add) ///
	xtitle("Other fuels CO{sub:2} intensity (tCO{sub:2}/GJ)", size(medium)) ///
	ytitle("Frequency", size(medium)) ///
	legend(off) ///
	fysize(20)   ///
	plotregion(margin(zero)) ///
	graphregion(margin(zero)) ///
	saving($figures/fig2b_bot.gph, replace) 

restore


//Combine top
 	graph combine $figures/fig2b_top.gph $figures/fig2b_bot.gph, ///
 	col(1) imargin(zero) ///
 	fysize(80) ///
 	saving($figures/fig2b.gph, replace) 

 	graph export $figures/fig2b.pdf, replace



