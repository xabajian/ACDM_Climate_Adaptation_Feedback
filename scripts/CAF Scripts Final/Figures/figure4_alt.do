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
	use $processed/cumulative_abatement_revised_byfuel, replace
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
	
	
//Panel OF only
	preserve
	
	keep if fuel=="other_energy"
	merge 1:1 ISO3 using $processed/country_GIS_db_noAntarctica
	tab _merge
	
	local mapV "cum_emiss_total"
	sum `mapV', d

	local topCut =10
	local botCut = -10
	local int = 2

	gen `mapV'_t=`mapV'
	replace `mapV'_t=`botCut' if `mapV'<`botCut'
	replace `mapV'_t=`topCut' if (`mapV'>`topCut' & !missing(`mapV'))

	local nColors=1+(`topCut'-`botCut')/`int'
	local lColors "`botCut'(`int')`topCut'"
	local colors `r(p)'

	spmap `mapV'_t using $processed/country_GIS_coord_noAntarctica, ///
		id(_ID) ///
		clmethod(custom) clbreaks(`lColors') fcolor(BuYlRd) /// 
		osize(none ..) ocolor(none ..) ///
		ndfcolor(gs15) ndocolor(white) ndsize(vvthin) ///
		legend(on size(small) ///
		label(2 "[-40,-8]")) ///
		legtitle("2099 cumulative" "CO{sub:2} chg (GtCO{sub:2})") ///
		plotregion(margin(zero)) ///
		graphregion(margin(zero)) ///
		saving($figures/four_OF_only.gph, replace) 
		graph export "/Volumes/ext_drive/uncertainty_8_12_22/figures/four_OF_only.png", as(png) name("Graph") replace

restore


//Panel Electricity only


preserve
	
	keep if fuel=="electricity"
	merge 1:1 ISO3 using $processed/country_GIS_db_noAntarctica
	tab _merge
	
	local mapV "cum_emiss_total"
	sum `mapV', d

	local topCut =10
	local botCut = -10
	local int = 2

	gen `mapV'_t=`mapV'
	replace `mapV'_t=`botCut' if `mapV'<`botCut'
	replace `mapV'_t=`topCut' if (`mapV'>`topCut' & !missing(`mapV'))

	local nColors=1+(`topCut'-`botCut')/`int'
	local lColors "`botCut'(`int')`topCut'"
	local colors `r(p)'

	spmap `mapV'_t using $processed/country_GIS_coord_noAntarctica, ///
		id(_ID) ///
		clmethod(custom) clbreaks(`lColors') fcolor(BuYlRd) /// 
		osize(none ..) ocolor(none ..) ///
		ndfcolor(gs15) ndocolor(white) ndsize(vvthin) ///
		legend(on size(small) ///
		label(2 "[-40,-8]")) ///
		legtitle("2099 cumulative" "CO{sub:2} chg (GtCO{sub:2})") ///
		plotregion(margin(zero)) ///
		graphregion(margin(zero)) ///
		saving($figures/four_ELEC_only.gph, replace) 
		graph export "/Volumes/ext_drive/uncertainty_8_12_22/figures/four_ELEC_only.png", as(png) name("Graph") replace

restore
