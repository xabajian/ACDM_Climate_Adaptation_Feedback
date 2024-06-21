/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

	clear all
	set more off
	set trace off
	set tracedepth 2
	set maxvar 32000
		

//set file paths
cd ~/Dropbox/adaptation_multiplier_data
	
	


//data folders 
global startDir "/Users/xabajian/Dropbox/adaptation_multiplier_data"
global rawDir "$startDir/rawData_local"
global processedDir "$startDir/processedData_local"
global tempDir "$startDir/temp_local"


/*%%%%%%%%%%%%%%%%%%%%%% MAIN %%%%%%%%%%%%%%%%%%%%%%*/

//Load intermediate data file
	use $tempDir/matched_quantities_factors, clear

//Unique indices
	//unique Country Product year Flow_Type

	//Task for Xander #1: why are observations not uniquely indexed by Country-Product-year-Flow_Type


/*
!@#$!@#$!@#$!@#$!@#$!#@$
!@#$!@#$!@#$!@#$!@#$!#@$
!@#$!@#$!@#$!@#$!@#$!#@$
!@#$!@#$!@#$!@#$!@#$!#@$

ACA 11/10/21 Task 1

		Q: Why are observations not uniquely indexed by Country-Product-year-Flow_Type

		
		A: I coded Bolivia as Venezuela 2x ( bolivaran republic of VZ vs. Bolivia, that's on me)
		
				see line 796 of the Factors_quantites_merged file - this is now fixed
!@#$!@#$!@#$!@#$!@#$!#@$
!@#$!@#$!@#$!@#$!@#$!#@$
!@#$!@#$!@#$!@#$!@#$!#@$
!@#$!@#$!@#$!@#$!@#$!#@$
*/

duplicates r Country Product year Flow_Type


/*
//ok survey says this is a legacy command
unique Country Product year Flow_Type


Duplicates in terms of Country Product year Flow_Type

--------------------------------------
   Copies | Observations       Surplus
----------+---------------------------
        1 |       130996             0
--------------------------------------

. 

*/


/*
!@#$!@#$!@#$!@#$!@#$!#@$
Next Steps
!@#$!@#$!@#$!@#$!@#$!#@$
*/



/*
First, destring the outcome variables in the panel we care about 
*/

//Missing observations
destring conversion_factor, replace force
destring flow_level, replace force

/*
ACA -- NB, missings changed slightly in wake of fixing Bolivia
*/
//Lots more missing conversion and emissions
count if missing(flow_level) //31,125
count if missing(conversion_factor) //62,483
count if missing(emissions_factor) //40,847
	
//Can't do anything about missing flow_level (ie consumption), 


	//But what about observations not missing flow_level but missing conversion factor or emissions factor
	count if !missing(flow_level) & missing(conversion_factor) & !missing(emissions_factor) //26,264
	count if !missing(flow_level) & !missing(conversion_factor) & missing(emissions_factor) //5,029
	count if !missing(flow_level) & missing(conversion_factor) & missing(emissions_factor) //5,108
	count if !missing(flow_level) & missing(emissions_factor) //5,108
	//Main issue is missing conversion_factors

	
/*
!@!!@#$!@#$!@#$!@#$!@#$
!@!!@#$!@#$!@#$!@#$!@#$
!@!!@#$!@#$!@#$!@#$!@#$

Task for Xander #2: 



Impute missing conversion_factors - You should have no missing conversion factors after Step 3. 

Keep a flag variable noting which observations have imputed conversion_factor value.


!@!!@#$!@#$!@#$!@#$!@#$
!@!!@#$!@#$!@#$!@#$!@#$
!@!!@#$!@#$!@#$!@#$!@#$


NB ACA---

Conversion factors are only neede for fuels that are using emissions factors measured in emissions per mass, ie from the energy use sector "Use Outside Electricity and Heat Generation"

*/

tab energy_enduse_sector

/*

                   energy_enduse_sector |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                Combined Heat and Power |     48,927       37.35       37.35
Use Outside Electricity and Heat Gene.. |     82,069       62.65      100.00
----------------------------------------+-----------------------------------
                                  Total |    130,996      100.00
								  
								  
There are only 82,069 entries we actually need to fill in

*/

count if !missing(flow_level) & missing(conversion_factor) & !missing(emissions_factor) & energy_enduse_sector=="Use Outside Electricity and Heat Generation"
//2
count if !missing(flow_level) & !missing(conversion_factor) & missing(emissions_factor) & energy_enduse_sector=="Use Outside Electricity and Heat Generation"
//2,549
count if !missing(flow_level) & missing(conversion_factor) & missing(emissions_factor) & energy_enduse_sector=="Use Outside Electricity and Heat Generation"
//4
/*
OK, far fewer replacements actually needed
*/


/*
test share of flows that have any kind of missing values
*/
//generate totals
bysort Country year: egen total_country_year = total(flow_level)
gen missing_em_flag = (missing(emissions_factor) & !missing(flow_level))
gen missing_cf_flag = (missing(conversion_factor) & !missing(flow_level))

gen missing_of_interest = missing_em_flag
replace missing_of_interest = 1 if missing_cf_flag==1 & energy_enduse_sector=="Use Outside Electricity and Heat Generation"
//(2 real changes made)

tab missing_of_interest
/*missing_of_ |
   interest |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |    120,857       92.26       92.26
          1 |     10,139        7.74      100.00
------------+-----------------------------------
      Total |    130,996      100.00

. 
end of do-file
*/
tab missing_of_interest if  year>2009 & year<2019
gen missing_flows =missing_of_interest*flow_level


tab year, sum(missing_of_interest)
tab Product if missing_of_interest==1

 
 
preserve
collapse (mean)total_country_year (sum)missing_flows flow_level, by(Country year)

gen missing_share = missing_flows/flow_level
sum missing_share, d
tab year, sum(missing_share)
restore
/*
!@!!@#$!@#$!@#$!@#$!@#$
!@!!@#$!@#$!@#$!@#$!@#$
!@!!@#$!@#$!@#$!@#$!@#$

Begin task 2

!@!!@#$!@#$!@#$!@#$!@#$
!@!!@#$!@#$!@#$!@#$!@#$
!@!!@#$!@#$!@#$!@#$!@#$
*/


/*
Ok, first things first flag the entries I care about: those entries not missing levels (quantities) and missing conversion factors
*/

gen cf_imputation_eligible = (!missing(flow_level) & missing(conversion_factor))
tab cf_imputation_eligible

gen no_missing_cf_flag = 1- missing_cf_flag
/*

this comports with above.


conv_for_im |
   putation |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     99,624       76.05       76.05
          1 |     31,372       23.95      100.00
------------+-----------------------------------
      Total |    130,996      100.00

*/



/*

Step 2.1: If there are non-missing conversion_factors in that Country-Product-Flow_Type, estimate a quadratic time trend model at the Country-Product-Flow_Type level  and impute missing conversion_factors with predicted values from the model. 
		
		
		
!@#$!@#!@#$!@#!@#$!@#
!@#$!@#!@#$!@#!@#$!@#!

Ok, to do this I think I can just generate group variables and run a seemingly unrelated regression. SE's won't matter
*/




bysort Country Product Flow_Type: egen ctry_prod_flow_obs = total(no_missing_cf_flag)

egen ctry_prod_flow = group(Country Product Flow_Type)

duplicates r ctry_prod_flow
//OK great, no set should be larger than 30 years as expected.

gen time = year - 1990
gen time_squared = time^2

//run without time fixed effects
reghdfe conversion_factor, absorb(i.ctry_prod_flow i.ctry_prod_flow#c.time i.ctry_prod_flow#c.time_squared, savefe) noconst resid tol(1e-5)

predict test2, xbd
estimates save "$tempDir/conv_factors_hdfe.ster", replace


//well at this point I cannot say what this command is doing
bysort ctry_prod_flow: egen intercept = mean(__hdfe1__ )
bysort ctry_prod_flow: egen slopet1 = mean( __hdfe2__Slope1 )
bysort ctry_prod_flow: egen slopet2 = mean(  __hdfe3__Slope1)


gen hdfe_fitted_cf = intercept + slopet1*time + slopet2*time_squared
corr hdfe_fitted_cf cf_step1_fitted

qqplot hdfe_fitted_cf cf_step1_fitted
 drop intercept _reghdfe_resid-__hdfe3__Slope1 slopet2 slopet1

 
 //Re-Run with time fixed-effects

reghdfe conversion_factor, absorb(i.time i.ctry_prod_flow i.ctry_prod_flow#c.time i.ctry_prod_flow#c.time_squared, savefe) noconst resid tol(1e-5)

predict testfe, xbd
estimates save "$tempDir/conv_factors_hdfe_yearfe.ster", replace


/*

I would normally use the TWFE absorb command but unfortunately it doesn't work

!@#$!@#$%!@#$#@!$
!@#$!@#$%!@#$#@!$

Update, still doesn't work even with the savefe subcommand. However, let's see if i can just replace all of the missing entries

!@#$!@#$%!@#$#@!$
!@#$!@#$%!@#$#@!$

This is strange, but I'll stick with what I do in the interim
*/



/*
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%

Plan 2: Run a bajillion linear regressions: For each country-product-flow tuple, run the quadratic trend specification in sample then extrapolate over all missing entries. 

!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
*/

gen cf_step1_fitted =.

quietly{
forvalues i = 1/8164{
	
	capture reg conversion_factor time time_squared if ctry_prod_flow==`i'

	if _rc==0 {
	predict xb
	replace cf_step1_fitted =xb if ctry_prod_flow==`i'
	drop xb
	}
	
	else {
		
	}
}
}

corr cf_step1_fitted conversion_factor

/* 
(obs=68,322)

             | cf_s1_~s co~actor
-------------+------------------
cf_s1_impu~s |   1.0000
conver~actor |   0.9996   1.0000
*/

corr testfe cf_step1_fitted



/*
Generate imputed values using step 1-predicted values.
*/


//iniate variable tracking existing factors and newly fitted values
gen imputed_cf_values = conversion_factor

//generate flags
gen CF_step_1_imputed_flag = (imputed_cf_values==. & cf_step1_fitted!=.)
tab CF_step_1_imputed_flag

//make replacement for these flagged values
replace imputed_cf_values=cf_step1_fitted if imputed_cf_values==.
//1,321 real changes made

/*
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%

Step 2.2: Conduct step 1 by with a model at the Country-Product level with remaining missing conversion_factors

!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
Ok, standard order here: remake the group variables, run quite a few regressions.
*/


//generate group variables for touples

egen ctry_prod = group(Country Product)
sum ctry_prod

gen cf_step2_fitted =.

quietly{
forvalues i = 1/2523{
	
	capture reg conversion_factor time time_squared if ctry_prod==`i'

	if _rc==0 {
	predict xb
	replace cf_step2_fitted =xb if ctry_prod==`i'
	drop xb
	}
	
	else {
		
	}
}
}

corr cf_step2_fitted conversion_factor


/*
Generate imputed values using step 1-predicted values.
*/


//generate flags
gen CF_step_2_imputed_flag = (imputed_cf_values==. & cf_step2_fitted!=.)
tab CF_step_2_imputed_flag

//make replacement for these flagged values
replace imputed_cf_values=cf_step2_fitted if imputed_cf_values==.
//2,429 real changes made


sum imputed_cf_values
count


/*
@#$%#@%$@%@#$%@#$%
@#$%#@%$@%@#$%@#$%
@#$%#@%$@%@#$%@#$%
@#$%#@%$@%@#$%@#$%

Step 2.3: At the Product-year-Flow_Type level, calculate the average conversion_factor across all countries. 
Impute remaining missing conversion_factors with these Product-year-Flow_Type averages. 

@#$%#@%$@%@#$%@#$%
@#$%#@%$@%@#$%@#$%
@#$%#@%$@%@#$%@#$%

OK, this one's pretty straight forward.

@#$%#@%$@%@#$%@#$%
@#$%#@%$@%@#$%@#$%
@#$%#@%$@%@#$%@#$%

Update, I'm illiterate. changing the code accordingly
*/




gen CF_step_3_imputed_flag = (imputed_cf_values==.)


bysort year Product Flow_Type: egen average_Y_P_F_CFactors = mean(conversion_factor)
//(50,347 missing values generated)

bysort year Product: egen average_Y_P_F_CFactors_2 = mean(conversion_factor)
//(42,403 missing values generated)

/*
@#$%#@%$@%@#$%@#$%
I think these averages just need to be at the product level
@#$%#@%$@%@#$%@#$%
*/
bysort Product: egen product_conversion_factors = mean(conversion_factor)
//(41,251 missing values generated)
sum product_conversion_factors


count if average_Y_P_F_CFactors==. & energy_enduse_sector=="Use Outside Electricity and Heat Generation"
//8,127
count if average_Y_P_F_CFactors_2==. & energy_enduse_sector=="Use Outside Electricity and Heat Generation"
//1,152
count if product_conversion_factors==. & energy_enduse_sector=="Use Outside Electricity and Heat Generation"
//0


/*

OK, so if I do it at the product level I cover all the conversion factor basis.

*/
replace imputed_cf_values=average_Y_P_F_CFactors if imputed_cf_values==.
replace imputed_cf_values=average_Y_P_F_CFactors_2 if imputed_cf_values==.
replace imputed_cf_values=product_conversion_factors if imputed_cf_values==.


tab Product if product_conversion_factors==.
sum conversion_factor if energy_enduse_sector=="Use Outside Electricity and Heat Generation"
count if energy_enduse_sector=="Use Outside Electricity and Heat Generation"
count if imputed_cf_values!=. & energy_enduse_sector=="Use Outside Electricity and Heat Generation"


/*

Great, that's 100% coverage for observations that will need mass to energy content conversions
*/
		
replace CF_step_1_imputed_flag=. if energy_enduse_sector=="Combined Heat and Power"
replace CF_step_2_imputed_flag=. if energy_enduse_sector=="Combined Heat and Power"
replace CF_step_3_imputed_flag=. if energy_enduse_sector=="Combined Heat and Power"


/*

CF_step_1_i |
mputed_flag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     80,887       98.56       98.56
          1 |      1,182        1.44      100.00
------------+-----------------------------------
      Total |     82,069      100.00

. tab CF_step_2_imputed_flag

CF_step_2_i |
mputed_flag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     80,011       97.49       97.49
          1 |      2,058        2.51      100.00
------------+-----------------------------------
      Total |     82,069      100.00

. tab CF_step_3_imputed_flag

CF_step_3_i |
mputed_flag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     66,483       81.01       81.01
          1 |     15,586       18.99      100.00
------------+-----------------------------------
      Total |     82,069      100.00

. 
*/



/*
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$

Task for Xander #3:

		Repeat Task #2 but for emissions factor 

!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
*/




/*
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$

Step 3.1

Fit values using quadratic trends

!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
*/

gen emissions_step1_fitted =.

quietly{
forvalues i = 1/8164{
	
	capture reg emissions_factor time time_squared if ctry_prod_flow==`i'

	if _rc==0 {
	predict xb
	replace emissions_step1_fitted =xb if ctry_prod_flow==`i'
	drop xb
	}
	
	else {
		
	}
}
}


corr emissions_factor emissions_step1_fitted

//iniate variable tracking existing factors and newly fitted values
gen imputed_emiss_factor_values = emissions_factor

//generate flags
gen EM_step_1_imputed_flag = (imputed_emiss_factor_values==. & emissions_step1_fitted!=.)
tab EM_step_1_imputed_flag


//make replacement for these flagged values
replace imputed_emiss_factor_values=emissions_step1_fitted if imputed_emiss_factor_values==.
//(6,572 real changes made)


/*
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$

Step 3.2

!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
*/


gen emissions_step2_fitted =.

quietly{
forvalues i = 1/2523{
	
	capture reg emissions_factor time time_squared if ctry_prod==`i'

	if _rc==0 {
	predict xb
	replace emissions_step2_fitted =xb if ctry_prod==`i'
	drop xb
	}
	
	else {
		
	}
}
}

corr emissions_factor emissions_step2_fitted


/*
Generate imputed values using step 1-predicted values.
*/


//generate flags
gen EM_step_2_imputed_flag = (imputed_emiss_factor_values==. & emissions_step2_fitted!=.)
tab EM_step_2_imputed_flag

//make replacement for these flagged values
replace imputed_emiss_factor_values=emissions_step2_fitted if imputed_emiss_factor_values==.
//2,716 real changes made


/*
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$

Step 3.3

!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
*/


gen EM_step_3_imputed_flag = (imputed_emiss_factor_values==.)




bysort year Product Flow_Type: egen average_3ple_emissions = mean(emissions_factor)
//(17,069 missing values generated)
bysort year Product: egen average_2ple_emissions = mean(emissions_factor)
//(6,683 missing values generated)

/*
@#$%#@%$@%@#$%@#$%
Again, I think these averages just need to be at the product level
@#$%#@%$@%@#$%@#$%
*/
bysort Product: egen product_emissions_factors = mean(emissions_factor)
//(2,970 missing values generated)

//Aside, that means a few products are missing emissions factors for literally all entries even though they were listed somewhere in IEA's dataset
tab Product if  product_emissions_factors==.

replace imputed_emiss_factor_values=average_3ple_emissions if imputed_emiss_factor_values==.
replace imputed_emiss_factor_values=average_2ple_emissions if imputed_emiss_factor_values==.
replace imputed_emiss_factor_values=product_emissions_factors if imputed_emiss_factor_values==.



/*

Step 3.4 -- run twfe regressions for emissions factors as well

*/


//run without time fixed effects
reghdfe emissions_factor, absorb(i.ctry_prod_flow i.ctry_prod_flow#c.time i.ctry_prod_flow#c.time_squared, savefe) noconst resid tol(1e-5)

estimates save "$tempDir/emiss_factors_hdfe.ster", replace



 drop  _reghdfe_resid-__hdfe3__Slope1

 
 //Re-Run with time fixed-effects

reghdfe conversion_factor, absorb(i.time i.ctry_prod_flow i.ctry_prod_flow#c.time i.ctry_prod_flow#c.time_squared, savefe) noconst resid tol(1e-5)

estimates save "$tempDir/emiss_factors_hdfe_yearfe.ster", replace



save "$tempDir/imputed_quantities_factors.dta", replace



/*
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$

Step 4 -- 

Perform a few sanity checks on each type of factor 


!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
*/



use "$tempDir/imputed_quantities_factors.dta", clear


/*
!@#$!@#$!@#$!@$#!@#$
Step 4.1 -- check on conversion factors
!@#$!@#$!@#$!@$#!@#$
*/

//check overall distribution
sum imputed_cf_values,d  


//check distribution of CF values for each level of imputation
sum conversion_factor
sum imputed_cf_values if EM_step_1_imputed_flag==1  
sum imputed_cf_values if EM_step_2_imputed_flag==1 
sum imputed_cf_values if EM_step_3_imputed_flag==1 

//Ok, all of these distributions are pretty similar
twoway kdensity imputed_cf_values if missing_cf_flag==1 || kdensity conversion_factor

tab Product if missing_cf_flag==1 , sum(imputed_cf_values)
tab Product, sum(conversion_factor)
//This looks pretty solid

gen imputed_cf_only = imputed_cf_values
replace imputed_cf_only=. if missing_cf_flag==0

preserve
collapse conversion_factor imputed_cf_only, by(Product  Country )
qqplot conversion_factor imputed_cf_only
restore

/*

These genuinely look pretty good

*/


/*
!@#$!@#$!@#$!@$#!@#$
Step 4.2 -- check on emissions factors
!@#$!@#$!@#$!@$#!@#$
*/

sum imputed_emiss_factor_values, d

count if imputed_emiss_factor_values<0
//246
/*
@#$%#@%$@%@#$%@#$%
OOOK we have negative values here, that obviously cannot be correct


Replace negative emissions values first with second-step regressions, then tuple averages, then product averages
@#$%#@%$@%@#$%@#$%
*/


/*
First replace any negative imputed values with step 2 fitted values if:

	They're not missing
	They're greater than zero
	
Then go through the prior imputation process
	
*/
replace imputed_emiss_factor_values=emissions_step2_fitted if imputed_emiss_factor_values<0 & emissions_step2_fitted!=. &emissions_step2_fitted>0
//(15 real changes made)
count if imputed_emiss_factor_values<0
//231



replace imputed_emiss_factor_values=average_3ple_emissions if imputed_emiss_factor_values<0 & average_3ple_emissions!=.
//(166 real changes made)
replace imputed_emiss_factor_values=average_2ple_emissions if imputed_emiss_factor_values<0 & average_2ple_emissions!=.
//(65 real changes made)

//OK that should do it
count if imputed_emiss_factor_values<0




save "$processedDir/imputed_quantities_factors.dta", replace


clear




/*
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$

Step 5 -- 

Repeat this process for electricity

!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
!@#$!@#$!@#$!@$#!@#$
*/

use "$processedDir/IEA_Electric_Factors.dta", clear

//Drop the memorandum countries
/*
gen memo=substr(Country,1,4)
tab memo
drop if memo=="memo"
*/


//tag the memorandum countries
gen memo=substr(Country,1,4)
gen memo_country = (memo=="memo")
tab memo_country


sum emissions_factor

//Flag missing factors
gen missing_factor_flag = (emissions_factor==.)
tab missing_factor_flag

tab memo_country missing_factor_flag
/*

*/
tab year if missing_factor_flag==1 & memo_country==0
tab Country if missing_factor_flag==1 & memo_country==0 & year!=2019

//generate total missing entries by Country-Product
bysort Country: egen total_missing = total(missing_factor_flag)

tab Country, sum(total_missing)
//generate covariates
gen time = year - 1990
gen time_squared = time^2

encode(Country), gen(country_byte)
sum country_byte
/*
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%

Run a bajillion linear regressions: For each country-product-flow tuple, run the quadratic trend specification in sample then extrapolate over all missing entries. 

!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
*/
gen emissions_fitted =.

quietly{
forvalues i = 1/228{
	
	//capture reg emissions_factor time time_squared if country_byte==`i'
	//capture reg emissions_factor time if country_byte==`i'
	capture reg emissions_factor if country_byte==`i'

	if _rc==0 {
	predict xb
	replace emissions_fitted =xb if country_byte==`i'
	drop xb
	}
	
	else {
		
	}
}
}


sum emissions_fitted emissions_factor
/*

. 
. sum emissions_fitted emissions_factor

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
emissions_~d |      4,770     .494644    .2931106   .0004429   1.661693
emissions_~r |      4,507    .4943631    .3195339      .0001     5.8792


Great, we're covered

*/


corr emissions_factor emissions_fitted

gen imputed_emissions_factor = emissions_factor
gen imputed_elec_emissions_flag = (imputed_emissions_factor==.)
replace imputed_emissions_factor = emissions_fitted if imputed_elec_emissions_flag==1

count
count if imputed_emissions_factor!=.
sum imputed_emissions_factor if imputed_elec_emissions_flag==1



/*

OOOOK this is a terrible fit, perhaps linear trend....

linear is also bad - I'm just taking the country-level averages

*/





//clean
drop total_missing time_squared time country_byte
//drop total_missing time_squared time memo country_byte


save "$processedDir/IEA_Electric_Factors_Imputations.dta", replace
















/*
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%

Step 6: Recreate "$processedDir/country_year_emissions_factor.dta" panel file, but this time use imputed data


!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
*/

//start with file from above.

use "$processedDir/imputed_quantities_factors.dta", clear
count
//130,996
count if imputed_emiss_factor_values !=.
//128,026

gen missing_em_flag = missing(emissions_factor)
tab missing_em_flag
tab missing_cf_flag

//these should be the same
sum imputed_emiss_factor_values if missing_em_flag ==0
sum emissions_factor 
//great


sum imputed_emiss_factor_values if missing_em_flag ==0, d
sum imputed_emiss_factor_values if missing_em_flag ==1, d

//visual check
twoway (kdensity imputed_emiss_factor_values if missing_em_flag ==1 & imputed_emiss_factor_values <5  ) ( kdensity imputed_emiss_factor_values if missing_em_flag ==0 & imputed_emiss_factor_values <5)


/*
Noting at this point there are some gargantuan imputed values
*/


/*
Now to convert to aggregated otherfuels values:

Conversion dimensional analysis is as follows: Mass (kg) = flow levels (TJ) * (1,000,000,000 KJ/Terrajoule) * (KJ/kilogram) ^-1

*/
count if imputed_cf_values==. &  energy_enduse_sector=="Use Outside Electricity and Heat Generation"

gen consumption_masses = flow_level * (1000000000) * (1/imputed_cf_values) if energy_enduse_sector=="Use Outside Electricity and Heat Generation"
//(67,761 missing values generated)

//generate total emissions factors for mass-based fuels from the "outside CHP" data
gen total_emissions = consumption_masses * imputed_emiss_factor_values
sum total_emissions

/*

For emissions factors in that are in units of emissions per energy (Joules) I just need to convert Joules to kWh:

1 TJ = 277778 kWh

*/

//NB: Replace total emissions for those derived from CHP emissions factors
gen kwh_consumption = 277778 * flow_level if energy_enduse_sector=="Combined Heat and Power"
//(94,360 missing values generated)
replace total_emissions = kwh_consumption * imputed_emiss_factor_values if energy_enduse_sector=="Combined Heat and Power"
//(36,636 real changes made)
label var total_emissions "country-year-fuel emissions in kg of cO2"


count if total_emissions!=. & flow_level!=.
//99,871
count if  flow_level!=.
//99,871


//great, we're in business

/*

ACA 11/11/2021:

!@#$!@#$!#@$
!@#$!@#$!#@$
!@#$!@#$!#@$

We've gone from 89,732 to  99,871 covered entries 

Now, collapse over all products to generate country-year total emissions and total energy pairs for fuels used outside the electric sector

!@#$!@#$!#@$
!@#$!@#$!#@$
!@#$!@#$!#@$
*/

//generate country-year total emissions 
bysort Country year: egen country_year_total_emissions =total(total_emissions)

//generate country-year total energy consumption 
bysort Country year: egen country_year_total_energy =total(flow_level) 

//scale consumption down to kJ from TJ
replace country_year_total_energy = 1000000000*country_year_total_energy

//collapse into single country-year observations
collapse country_year_total_energy country_year_total_emissions (max) CF_step_1_imputed_flag CF_step_2_imputed_flag CF_step_3_imputed_flag EM_step_1_imputed_flag EM_step_2_imputed_flag EM_step_3_imputed_flag, by(Country year)


label var country_year_total_energy "country - year energy of non-electric fuel consumption in kJoules"
label var country_year_total_emissions "country - year total emissions from non-electric fuel consumption in kg CO2"


//average emissions factors are ratio of total emissions from covered fuels to total energy from covered fuels
gen non_electricity_emissions_factor = country_year_total_emissions/country_year_total_energy
label var non_electricity_emissions_factor "country - year kg cO2 per kiloJoule from outside fuels"
sum non_electricity_emissions_factor, d
/*
Create equivalent variable with kWh as denominator
NB: 1 kJ = 3600 kWh
*/
gen factor_kwh = non_electricity_emissions_factor*3600

label var factor_kwh "country - year kg cO2 per kWh from outside fuels"



count
//4,440
count if factor_kwh!=. & non_electricity_emissions_factor!=.
//4,341



save "$tempDir/preliminary_non_electric_factors_imputed.dta", replace



/*
!@#$!@#$!#$!#$#!@$
!@#$!@#$!#$!#$#!@$
!@#$!@#$!#$!#$#!@$

Note from above we have 59 country-year entries with no factors even after interpolation due to lack of any data on the products they're using. This corresponds to comment around line 693 above

ACA 11/11/2021

!@#$!@#$!@#$
!@#$!@#$!@#$
!@#$!@#$!@#$

merge in electricity factors from the IEA factor data *including* imputations
*/

use "$tempDir/preliminary_non_electric_factors_imputed.dta", clear

merge 1:1 Country year using "$processedDir/IEA_Electric_Factors_Imputations.dta", gen(merge_electricity_factors)

/*

 merge 1:1 Country year using "$processedDir/IEA_Electric_Factors_Imputations.dta", gen(merge_electricity_factors)

    Result                      Number of obs
    -----------------------------------------
    Not matched                         2,400
        from master                         0  (merge_electricity_factors==1)
        from using                      2,400  (merge_electricity_factors==2)

    Matched                             4,440  (merge_electricity_factors==3)
    -----------------------------------------

. 
end of do-file


*/
tab Country if merge_electricity_factors!=3


/*
Noting again we have a similar missing list of countries with any non-electricity emissions factors available:

*/


keep if merge_electricity_factors==3
//(2,400 observations deleted)
rename emissions_factor electricity_emissions_factor
rename factor_kwh otherfuels_emissions_factor
label var energy_enduse_sector "Sector of Energy Use (elec vs. other)"
label var electricity_emissions_factor "country - year kg cO2 per kWh of electricity"
drop Product merge* energy_enduse_sector

encode(Country),gen (country_byte)
format year %ty

/*

Panel balance check -- this should be balanced by construction

*/

bysort year: gen number_countries = _N

tab year, sum(number_countries)

drop number_countries
//nice


merge m:1 Country using "$rawDir/iso3_xwalk.dta", gen(merge_isocodes)
//great

//clean and adjust to Bolivia 
drop missing_factor_flag imputed_emissions_factor emissions_fitted country_byte merge non_electricity_emissions_factor

replace ISO3= "BOL" if Country=="plurinational state of bolivia"

//save finished dataset
save "$processedDir/country_year_emissions_factor_imputed.dta", replace





/*
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%

Step 6.1: Compare the panel data of imputed factors to the panel of existing factors (with no imputed observations)


!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
*/

use "$processedDir/country_year_emissions_factor_imputed.dta", clear


rename otherfuels_emissions_factor imputed_other_factors
rename electricity_emissions_factor imputed_elec_factors

keep ISO3 Country year imputed_elec_factors imputed_other_factors EM_step_1_imputed_flag-EM_step_3_imputed_flag



merge 1:1 ISO3 year using  "$processedDir/country_year_emissions_factor.dta", gen(compare)



/*
!@#$!@#$!@#$!
!@#$!@#$!@#$!

6.1.1: check other fuels factors, remembering to not keep 2019 because of copious missign values

!@#$!@#$!@#$!
!@#$!@#$!@#$!
*/


gen equal_other = (otherfuels_emissions_factor==imputed_other_factors)
tab equal_other if year!=2019

/*

OK, fewer directly the same now



equal_other |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      2,732       63.65       63.65
          1 |      1,560       36.35      100.00
------------+-----------------------------------
      Total |      4,292      100.00





*/

//examine means
mean otherfuels_emissions_factor imputed_other_factors if year!=2019


mean otherfuels_emissions_factor imputed_other_factors if EM_step_1_imputed_flag==1  & year!=2019
mean otherfuels_emissions_factor imputed_other_factors if EM_step_2_imputed_flag==1  & year!=2019
mean otherfuels_emissions_factor imputed_other_factors if EM_step_3_imputed_flag==1  & year!=2019

//This should be exactly the same
mean otherfuels_emissions_factor imputed_other_factors if EM_step_1_imputed_flag==0 & EM_step_2_imputed_flag==0 & EM_step_3_imputed_flag==0  & year!=2019
//great

corr  otherfuels_emissions_factor imputed_other_factors
//wow that is low


//find the largest discrepency?

gen other_differences = (imputed_other_factors - otherfuels_emissions_factor)/otherfuels_emissions_factor
sum other_differences, d


tab Country if other_differences>1 
tab Country if other_differences>1  & year!=2019

//Ok so most of this comes from 2019 imputations.

sum other_differences if year!=2019, d
//great
sum other_differences if year<2019 & year>2009, d

//better
corr  otherfuels_emissions_factor imputed_other_factors if year<2019 & year>2009


/*
!@#$!@#$!@#$!
!@#$!@#$!@#$!
6.1.2: check electricity
!@#$!@#$!@#$!
!@#$!@#$!@#$!
*/
corr imputed_elec_factors electricity_emissions_factor
gen equal_elec = (imputed_elec_factors==electricity_emissions_factor)
tab equal_elec
//go figure.







/*
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%


Step 7: Create output to make maps


!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
*/

//port in data 
use "$processedDir/country_year_emissions_factor_imputed.dta", clear



//keep year range
keep if year>=2010 & year<2019

count if electricity_emissions_factor==0
//0
count if otherfuels_emissions_factor==0
//27
count if electricity_emissions_factor==.
//52
count if otherfuels_emissions_factor==.
//2


/*

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Turn zeros to missing entries for other fuels.

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

*/

replace otherfuels_emissions_factor=. if otherfuels_emissions_factor==0
//(27 real changes made, 27 to missing)

bysort Country year: egen mean_2010s_electric = mean(electricity_emissions_factor)
bysort Country year: egen mean_2010s_otherfuels = mean(otherfuels_emissions_factor)

collapse mean_2010s_electric mean_2010s_otherfuels, by(Country ISO3)

label var mean_2010s_otherfuels "country - year kg cO2 per kWh from outside fuels"
label var mean_2010s_electric "country - year kg cO2 per kWh of electricity"

save "$processedDir/country_year_emissions_factor_2010s_imputed.dta", replace


use "$processedDir/country_year_emissions_factor_2010s_imputed.dta", replace

sort mean_2010s_otherfuels

list Country ISO3 mean_2010s_otherfuels in 139/148

sort mean_2010s_electric

list Country ISO3 mean_2010s_electric in 136/148

/*
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%


Step 8: Sanity Checks for 20 countries of interest


!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
!@#$%@#$%@$%@$#%
*/

//grab flow-product level factors
use "$processedDir/imputed_quantities_factors.dta", clear

merge m:1 Country using "$rawDir/iso3_xwalk.dta", gen(merge_isocodes)
keep if merge_isocodes==3


/*
!@#$!@#$!#@$!@#$!@#$!#@$
!@#$!@#$!#@$!@#$!@#$!#@$
Step 8.1 keep the 10 countries Kyle wants spot checked


	UPDATE - Change these 10 countries to reflect updated imputed heat emissions factors
!@#$!@#$!#@$!@#$!@#$!#@$
!@#$!@#$!#@$!@#$!@#$!#@$
*/
//mark electricity and heat outliers


//electricity targets
//keep if ISO3 == "BWA" | ISO3 == "MNG" | ISO3 == "IRQ" | ISO3 == "XKX" | ISO3 == "NER" | ISO3 == "EST" | ISO3 == "ZAF" | ISO3 == "TKM" | ISO3 == "SSD"| ISO3 == "HTI" | ///


//keep 10 heat targets
keep if  ISO3 == "MLI" |ISO3 == "GAB" | ISO3 == "BEN" |ISO3 == "LKA" |ISO3 == "PAN" |ISO3 == "GTM" |ISO3 == "SEN" |ISO3 == "NIC" |ISO3 == "ZWE" | ISO3 == "LAO" 

//keep the subsample between 2010-18
keep if year>2009 & year<2019


count
//1,294

//check what kind of factors I'll end up using

tab energy_enduse_sector
/*


                   energy_enduse_sector |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                Combined Heat and Power |        393       30.37       30.37
Use Outside Electricity and Heat Gene.. |        901       69.63      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,294      100.00

. 

*/
count if imputed_cf_values==.& energy_enduse_sector!="Combined Heat and Power"
//great no missing factors
count if flow_level==.
//great, no missign flow values either



/*

Now, convert each observation in the outside electric/heat sector into an implied 
emissions factor per kWh.


Conversion dimensional analysis is as follows:


Mass (kg) = flow levels (TJ) * (1,000,000,000 KJ/Terrajoule) * (KJ/kilogram) ^-1

*/
gen consumption_masses = flow_level * (1000000000) * (1/imputed_cf_values) if energy_enduse_sector!="Combined Heat and Power"
//(393 missing values generated)

//generate total emissions factors for mass-based fuels from the "outside CHP" data
gen total_emissions = consumption_masses * imputed_emiss_factor_values
//(393 missing values generated)
label var total_emissions "country-year-fuel emissions in kg of cO2"

/*

For emissions factors in that are in units of emissions per energy (Joules) I just need to convert Joules to kWh:

1 TJ = 277778 kWh

*/

//NB: Replace total emissions for those derived from CHP emissions factors
gen kwh_consumption = 277778 * flow_level

//use existing factors for the values derived from the CHP sector
gen final_emissions_factors = imputed_emiss_factor_values

//replace the co2 per kg values with co2 per kwh valeus i can generate on aggregate above
replace final_emissions_factors = total_emissions/kwh_consumption if energy_enduse_sector!="Combined Heat and Power"
//(934 real changes made), perfect
sum final_emissions_factors, d



/*


                   final_emissions_factors
-------------------------------------------------------------
      Percentiles      Smallest
 1%     .2263323       .2263322
 5%     .2283296       .2263322
10%     .2283296       .2263322       Obs               1,294
25%     .2547943       .2263322       Sum of wgt.       1,294

50%      .268807                      Mean            1.01723
                        Largest       Std. dev.      1.634063
75%     1.098298         11.144
90%       3.1004         11.144       Variance       2.670161
95%     3.977808        11.2245       Skewness       3.316606
99%      10.2158        11.2245       Kurtosis       16.84825

. 
end of do-file



OK, large right tail.

*/

/*
!@#$!@#$!#@$!@#$!@#$!#@$
!@#$!@#$!#@$!@#$!@#$!#@$

Step 8.2 Why are the values gigantic?


Check the level of flows going into each of these factors
!@#$!@#$!#@$!@#$!@#$!#@$
!@#$!@#$!#@$!@#$!@#$!#@$
*/


tab  Country, sum(final_emissions_factors)

/*
for each country-year pair, generate each fuel's share of total consumption
*/
bysort  Country year: egen total_cons = total(flow_level) 


/*
By product, sum over all flows but keep emissions factors and the consumption totals as above (for each country in each year)
*/
collapse (sum) flow_level (mean) total_cons final_emissions_factors, by(Product Country year)
gen share_fuel = flow_level/total_cons

/*
Take the average over all years
*/

collapse share_fuel flow_level total_cons final_emissions_factors, by(Product Country)

/*
!@#$!@#$!#@$!@#$!@#$!#@$
!@#$!@#$!#@$!@#$!@#$!#@$

Step 8.3: Check what's contributing to large factors

!@#$!@#$!#@$!@#$!@#$!#@$
!@#$!@#$!#@$!@#$!@#$!#@$
*/


tab Product, sum(share_fuel)
tab Product, sum(flow_level) 
/*
OK, so it would appear that it is largely driven by this "primsbio" category. for reference, this is

	"Primary solid biofuels is defined as any plant matter used directly as fuel or converted into other forms before combustion."
	
So essentially this is burning wood, which we'd expect would indeed have a very high carbon/BTU input given it's a shitty fuel. The quantities of this consumed confirm that it dwarfs the other fuels.
*/



tab Product, sum(final_emissions_factors) 
tab Country if Product=="PRIMSBIO", sum(final_emissions_factors)

//It also has gargantuan emissions factors across the board



//OK, use of biofuels is driving this.

tab Country if Product=="PRIMSBIO", sum(share_fuel)
/*
huge shares of consumption across the board too.
*/
