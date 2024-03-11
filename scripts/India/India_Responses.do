////start script////
clear all
set more off
macro drop _all

/////////////// SET UP USER SPECIFIC PATHS //////////////////////////////////////////////////////

/*

Path to energy-code-release repo:

NB - this will only work from xander's terminal as given persons will have different GitHub repo paths


*/
global root "/Volumes/ext_drive/india responses/adaptation_multiplier_data/copy_entire_tamma/energy-code-release-2020"



global working_dir "/Volumes/ext_drive/india responses"



//Repeat above loop to form cross section
use "$working_dir/temp/Country_Temp_Respones_Rhodes2020/country_1.dta", clear

forval i = 2/140 {
		
		append using "$working_dir/temp/Country_Temp_Respones_Rhodes2020/country_`i'.dta"
	

}


//merge in country ISO codes and indices for merges
merge m:1 country_index using "$working_dir/temp/country_index_xwalk.dta", gen(merge_names)
drop merge_names

 
 
 

//merge in 15year MA of log income per capita
gen log_income_avg = .

forval i = 1/140 {
		
	//using the break data, copy running MAs of log gdp per capita
	preserve
	use "$root/data/break_data_TINV_clim.dta", clear
	keep if country_index==`i'
	sort year
	gen index = _n
	gen count_dummy = _N
	keep if index == count_dummy
	scalar income_dummy = lgdppc_MA15[1]
	restore
	
	//replace variable in master
	replace log_income_avg = income_dummy if country_index==`i'
		
	

}
 /*
Tamma's paper's responses are in GJ per capita * year^-1

Unit conversions from GJ to kWh - 

1 GJ = 277.8 kwh

 */
 
 replace UB_elec_emissions = UB_elec_emissions * 277.8
 replace predict_elec_emissions = predict_elec_emissions * 277.8
 replace LB_elec_emissions = LB_elec_emissions * 277.8
 replace UB_other_emissions = UB_other_emissions * 277.8
 replace predict_other_emissions = predict_other_emissions * 277.8
 replace LB_other_emissions = LB_other_emissions * 277.8

 
/*
Sanity check on emissions factors
*/
sum electricity_emissions_factor otherfuels_emissions_factor
 

//save this cross section out.
	
/*

Select countries

Brazil - 17
Canada - 20
China - 23
India - 58
Japan - 67
Germany - 34
UK - 47
Russia - 109
Saudi - 110
*/

keep if  country_index== 110 
  
/*
!@#$!@#$!@#$
Plot marginal emissions responses for electricity
!@#$!@#$!@#$
*/

twoway rarea UB_other_emissions LB_other_emissions temp1, col(yellow %30) || ///
line  predict_other_emissions temp1, lc(dkorange) ||  ///
rarea UB_elec_emissions LB_elec_emissions temp1, col(gray %30) || ///
line  predict_elec_emissions temp1, lc(black) || , ///
yline(0, lwidth(vthin)) xlabel(-5(10)35, labsize(vsmall)) ///
 subtitle("", size(vsmall) color(dkgreen)) ///
ytitle("{&Delta} kg CO2 per person", size(vsmall)) xtitle("Long-Run Temperature", size(small))
 
 
 
 
 /*
 , by(country_index) yline(0, lwidth(vthin)) xlabel(-5(10)35, labsize(vsmall)) ///
ylabel(, labsize(vsmall) nogrid) legend(off) ///
subtitle("", size(vsmall) color(dkgreen)) ///
ytitle("{&Delta} kg CO2 per person", size(vsmall)) xtitle("Long-Run Temperature", size(small)) ///
plotregion(color(white)) graphregion(color(white)) //title("Country-Level per-Capita Marginal Emissions" "from Electricity Demand Responses")
//
//   twoway line  predict_elec_emissions temp1, lc(black) ||, by(country_index) yline(0, lwidth(vthin)) xlabel(-5(10)35, labsize(vsmall)) ///
// ylabel(, labsize(vsmall) nogrid) legend(off) ///
// subtitle("", size(vsmall) color(dkgreen)) ///
// ytitle("{&Delta} kg CO2 per person", size(vsmall)) xtitle("Long-Run Temperature", size(small)) ///
// plotregion(color(white)) graphregion(color(white)) //title("Country-Level per-Capita Marginal Emissions" "from Electricity Demand Responses")

  
/*
!@#$!@#$!@#$
Plot marginal emissions responses for other fuels
!@#$!@#$!@#$
*/
twoway rarea UB_other_emissions LB_other_emissions temp1, col(yellow %30) || line  predict_other_emissions temp1, lc(dkorange) ||, by(country_index) yline(0, lwidth(vthin)) xlabel(-5(10)35, labsize(vsmall)) ///
ylabel(, labsize(vsmall) nogrid) legend(off) ///
subtitle("", size(vsmall) color(dkgreen)) ///
ytitle("{&Delta} kg CO2 per person", size(vsmall)) xtitle("Long-Run Temperature", size(small)) ///
plotregion(color(white)) graphregion(color(white)) //title("Country-Level per-Capita Marginal Emissions" "from Other Fuels Demand Responses")

				
				  
/*
!@#$!@#$!@#$
Plot combined emissions responses
!@#$!@#$!@#$
*/
twoway rarea UB_other_emissions LB_other_emissions temp1, col(yellow %30) || line  predict_other_emissions temp1, lc(dkorange) || rarea UB_elec_emissions LB_elec_emissions temp1, col(gray %30) || line  predict_elec_emissions temp1, lc(black) ||, by(country_index) yline(0, lwidth(vthin)) xlabel(-5(10)35, labsize(vsmall)) ///
ylabel(, labsize(vsmall) nogrid)  legend(off) ///
subtitle("", size(vsmall) color(dkgreen)) ///
ytitle("{&Delta} kg CO2 per person", size(vsmall)) xtitle("Long-Run Temperature", size(small)) ///
plotregion(color(white)) graphregion(color(white))  //title("Country-Level per-Capita Marginal Emissions" "from Total Energy Demand Responses")

  
/*
!@#$!@#$!@#$
Plot changes in demand
!@#$!@#$!@#$
*/		
twoway line  predict_elec_demand temp1, lc(black) || line predict_other_demand temp1, lc(dkorange) ||, by(country_index) yline(0, lwidth(vthin)) xlabel(-5(10)35,labsize(vsmall)) ///
ylabel(, labsize(vsmall) nogrid) legend(off) ///
subtitle("", size(vsmall) color(dkgreen)) ///
ytitle("{&Delta} per-capita energy demand", size(vsmall)) xtitle("Long-Run Temperature", size(small)) ///
plotregion(color(white)) graphregion(color(white)) 


/*




/*
@#$%@#$%@#$%@#$%@
@#$%@#$%@#$%@#$%@
@#$%@#$%@#$%@#$%@
*******************************************************************************
* Step 5: Kyle task. Make scatter of income vs. marginal GHG responses for electricity and other fuels
*******************************************************************************



10/5/2021



This section will hopefully be recreated using a different regression output.
@#$%@#$%@#$%@#$%@
@#$%@#$%@#$%@#$%@
@#$%@#$%@#$%@#$%@
*/




use "$working_dir/temp/temperature_response_xsection.dta", clear


  
/*
!@#$!@#$!@#$

Per Kyle's 10/4 comments, I'm going to do some sanity checks on these emissions responses

!@#$!@#$!@#$
*/


sum electricity_emissions_factor otherfuels_emissions_factor, d 
sum predict_elec_demand predict_other_demand, d
duplicates r predict_other_demand
duplicates r predict_elec_demand


/*
!@#$!@#$!@#$
drop missing factors
!@#$!@#$!@#$
*/


drop if electricity_emissions_factor ==. | otherfuels_emissions_factor ==.
//(328 observations deleted)


/*
Form factor quantiles for Kyle's metric
*/
xtile electric_intensity_quartile = electricity_emissions_factor, nquantiles(4)
xtile other_intensity_quartile = otherfuels_emissions_factor, nquantiles(4)





/*
Income nonciles by country
*/
xtile income_noncile = log_income_avg, nquantiles(9)



 
 
 
/*
!@#$!@#$!@#$
!@#$!@#$!@#$
!@#$!@#$!@#$
Try to recreate Tamma's deciles figure using (pop weighted) rudimentary aggregation at the noncile level for visual ease
!@#$!@#$!@#$
!@#$!@#$!@#$
!@#$!@#$!@#$
*/
preserve
collapse UB_other_emissions LB_other_emissions predict_other_emissions predict_other_demand , by(income_noncile temp1)

//with CIs

// twoway  rarea UB_other_emissions LB_other_emissions temp1, col(yellow %30) || line  predict_other_emissions temp1, lc(dkorange) ||, by(income_noncile) yline(0, lwidth(vthin)) xlabel(-5(10)35, labsize(vsmall)) ///
// ylabel(, labsize(vsmall) nogrid) legend(off) ///
// subtitle("", size(vsmall) color(dkgreen)) ///
// ytitle("{&Delta} kg CO2 per person", size(vsmall)) xtitle("Long-Run Temperature", size(small)) ///
// plotregion(color(white)) graphregion(color(white)) 	

//w/o CIs


twoway  line  predict_other_emissions temp1, lc(dkorange) ||, by(income_noncile) yline(0, lwidth(vthin)) xlabel(-5(10)35, labsize(vsmall)) ///
ylabel(, labsize(vsmall) nogrid) legend(off) ///
subtitle("", size(vsmall) color(dkgreen)) ///
ytitle("{&Delta} kg CO2 per person", size(vsmall)) xtitle("Long-Run Temperature", size(small)) ///
plotregion(color(white)) graphregion(color(white)) 			
restore
 
 
/*
!@#$!@#$!@#$
!@#$!@#$!@#$
 Detour - pop weight above calculation
!@#$!@#$!@#$
!@#$!@#$!@#$
 */
 

preserve
use "$root/data/GMFD_TINV_clim_regsort.dta", clear
encode country, gen(country_index)
keep country_index year pop
sort country_index year
by country_index: gen index=_n
by country_index: gen dummy =_N
keep if dummy == index
save  "$working_dir/temp/populations.dta", replace
restore
 
 merge m:1 country_index using "$working_dir/temp/populations.dta", gen(merge_populations)
 keep if merge_populations==3
 drop merge*
 
 
 
/*
!@#$!@#$!@#$
!@#$!@#$!@#$
!@#$!@#$!@#$
Try to recreate Tamma's deciles figure using (pop weighted) rudimentary aggregation at the noncile level for visual ease
!@#$!@#$!@#$
!@#$!@#$!@#$
!@#$!@#$!@#$
*/
preserve
collapse UB_other_emissions LB_other_emissions predict_other_emissions predict_other_demand [pw=1/pop] , by(income_noncile temp1)

twoway  rarea UB_other_emissions LB_other_emissions temp1, col(yellow %30) || line  predict_other_emissions temp1, lc(dkorange) ||, by(income_noncile) yline(0, lwidth(vthin)) xlabel(-5(10)35, labsize(vsmall)) ///
ylabel(, labsize(vsmall) nogrid) legend(off) ///
subtitle("", size(vsmall) color(dkgreen)) ///
ytitle("{&Delta} kg CO2 per person", size(vsmall)) xtitle("Long-Run Temperature", size(small)) ///
plotregion(color(white)) graphregion(color(white)) 

				
restore


egen total_population = total(pop)
 
 
 
 
 
/*
!@#$!@#$!@#$
Kyle's ask
!@#$!@#$!@#$

[fw=floor(pop/total_population)]
*/ 
 collapse log_income_avg  electric_intensity_quartile other_intensity_quartile (sum) predict_elec_demand predict_other_demand predict_elec_emissions predict_other_emissions, by(country_index country)



twoway lowess predict_elec_emissions log_income_avg if electric_intensity_quartile==1, lcolor(red)  || lowess predict_elec_emissions log_income_avg if electric_intensity_quartile==2  , lcolor(blue) || lowess predict_elec_emissions log_income_avg if electric_intensity_quartile==3, lcolor(green)   || lowess predict_elec_emissions log_income_avg if electric_intensity_quartile==4 ,lcolor(orange) title("Total of Marginal Emissions from Electricity Demand Responses" "by Emissions Intensity Quartile") ytitle("{&Sigma} {&Delta} kg CO2 per person", size(vsmall)) xtitle("15 year MA of log per-Capita Income, 2018", size(small)) legend(order(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" ))

twoway lowess predict_other_emissions log_income_avg if other_intensity_quartile==1, lcolor(red)  || lowess predict_other_emissions log_income_avg if other_intensity_quartile==2  , lcolor(blue) || lowess predict_other_emissions log_income_avg if other_intensity_quartile==3, lcolor(green)   || lowess predict_other_emissions log_income_avg if other_intensity_quartile==4 ,lcolor(orange) title("Total of Marginal Emissions from Other Fuels Demand Responses" "by Emissions Intensity Quartile") ytitle("{&Sigma} {&Delta} kg CO2 per person", size(vsmall)) xtitle("15 year MA of log per-Capita Income, 2018", size(small)) legend(order(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" ))

sort other_intensity_quartile log_income_avg 


twoway scatter predict_other_emissions log_income_avg if other_intensity_quartile<3 || scatter predict_other_emissions log_income_avg if other_intensity_quartile>2, title("Total of Marginal Emissions from Other Fuels Demand Responses" "for Above and Below Median Intensity") ytitle("{&Sigma} {&Delta} kg CO2 per person", size(vsmall)) xtitle("15 year MA of log per-Capita Income, 2018", size(small)) legend(order(1 "Lower Half" 2 "Upper Half"))



twoway scatter predict_elec_demand log_income_avg if other_intensity_quartile<3 || scatter predict_elec_demand log_income_avg if other_intensity_quartile>2, title("Total of Marginal Emissions from Other Fuels Demand Responses" "for Above and Below Median Intensity") ytitle("{&Sigma} {&Delta} kg CO2 per person", size(vsmall)) xtitle("15 year MA of log per-Capita Income, 2018", size(small)) legend(order(1 "Lower Half" 2 "Upper Half"))


twoway scatter predict_other_demand log_income_avg if other_intensity_quartile<3 || scatter predict_other_demand log_income_avg if other_intensity_quartile>2, title("Total of Marginal Emissions from Other Fuels Demand Responses" "for Above and Below Median Intensity") ytitle("{&Sigma} {&Delta} kg CO2 per person", size(vsmall)) xtitle("15 year MA of log per-Capita Income, 2018", size(small)) legend(order(1 "Lower Half" 2 "Upper Half"))
