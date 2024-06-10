/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Alexander Abajian

9/20/2021

Import IEA World Energy Balances data to create panel data on fuel-specific and broader aggregate energy consumption emissions intensities.


Task from Kyle

Using the IEA emissions intensity and world energy balances data, construct a panel dataset with the following variables:

	1  -- country identifier (for now, use whatever identifier the IEA uses)
	2  -- year
	3  -- fuel type: 
		by whatever is the primary fuel definitions in the IEA (i.e., coal, gas, wind, biofuels etc)

			by "aggregate" energy definition in Tamma's paper (see attached extract) of electricity and "other fuels". Try to follow the coding in Tamma's
			paper as closely as possible. 
			
	4  -- CO2 emissions intensity

		CO2 emissions intensity for primary fuel type (1 above) should come directly from the IEA emissions intensity dataset. 

		CO2 emisisons intensity for aggregate electricity and "other-fuels" will require additional use of the World energy balances data. Specifically make it for country i, year t, if aggregate energy e (i.e. electricity) uses primary energy h (i.e. coal, gas, oil,), construct:

F^e_{it}=\frac{\sum_{h} F^{e,h}_{it} * Q^{e,h}{it}}{Q^{e,h}{it}}

where F^{e,h}{it} is the CO2 emissions intensity of energy e made from primary fuel h (from emisisons factor data) and Q^{e,h}_{it} is consumption of energy e from primary fuel h.



*/

/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Module to allow this code to be run in an adaptive nature from any terminal

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/



//set file paths
cd ~/Dropbox/adaptation_multiplier_data
	
	


//data folders 
global startDir "/Users/xabajian/Dropbox/adaptation_multiplier_data"
global rawDir "$startDir/rawData_local"
global processedDir "$startDir/processedData_local"
global tempDir "$startDir/temp_local"


// //set file paths
// global root "STARTING_CAF_DIRECTORY"
// cd $root 
//
// //data folders 
// global rawDir "$root/rawData"
// global processedDir "$root/processedData"
// global tempDir "$root/temp"



//repository paths
/*
global tablesDir "$startDir/repo/tables"
global figuresDir "$startDir/repo/figures"
*/

/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%



Step 1: Import the world energy balance .txt file from parent directory and save as an intermediate .dta file


I have two options here --one for the extended data file and one for the summary file

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/


/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Old command to import the summary balances

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/
//import delimited "$rawDir/IEA/WORLDBAL.txt", delimiters(" ", collapse) clear


/*
UPDATE 9/22/2021


%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Commands to import the extended data files

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%


Kyle's old file
import delimited "$rawDir/IEA/WBAL_extended_unzipped/WBIG1.TXT", delimiters(" ", collapse) clear


%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Import the two parts
*/

import delimited "$rawDir/IEA/WBIG_Unzip/WBIG1.TXT", delimiters(" ", collapse) clear


rename v1 Country
rename v2 Product
rename v3 year
rename v4 Flow_Type
label var Flow_Type "Energy Flow Type (e.g., production, consumption, NX...) "
rename v5 Units
rename v6 flow_level
drop v7

save "$tempDir/IEAWBX_1.dta", replace


import delimited "$rawDir/IEA/WBIG_Unzip/WBIG2.TXT", delimiters(" ", collapse) clear


**# Bookmark #1
rename v1 Country
rename v2 Product
rename v3 year
rename v4 Flow_Type
label var Flow_Type "Energy Flow Type (e.g., production, consumption, NX...) "
rename v5 Units
rename v6 flow_level
drop v7

save "$tempDir/IEAWBX_2.dta", replace

append using "$tempDir/IEAWBX_1.dta"

//this file is large, save a temp version to ensure I don't do something dumb with the .txt files
save "$tempDir/IEAWB.dta", replace



/*

Note that the above energy balance file is measured in energy units (KTOEs or TerraJoules).

I need to port in conversion factors in order to convert these energy units into primary consumption of actual energy inputs


%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%



Step 2: Import conversion factors


%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

*/

import delimited "$rawDir/IEA/CONV.txt", delimiters(" ", collapse) clear


rename v1 conversion_direction_X_per_Y
rename v2 Country
rename v3 Product
rename v4 conversion_enduse_Sector
label var conversion_enduse_Sector "Sector for End Use that Conversion is Based From"
rename v5 year
rename v6 conversion_factor
drop v7


/*

I only need to keep conversion factors for energy-weight conversions. For now, I'm also going to restrict these to the average ratios

*/
keep if conversion_direction_X_per_Y=="KJKG"
keep if conversion_enduse_Sector=="NAVERAGE"


save "$tempDir/IEAWB_ConversionFactors.dta", replace

//use "$tempDir/IEAWB_ConversionFactors.dta", clear

/*


%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%



Step 3: Merge conversion factors into end-uses


%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

*/

/*
sanity check for summary

WDS thinks this for 2008 USA total coal energy supply:



Select items to view	
Download	
Set dimension order...	View printable version	Print setup...	  
 World Energy Balances Table summary
Other:	   UNIT - ktoe Previous item Next item 	   COUNTRY Dimension summary - United States Item summary 	   TIME - 2008 Previous item Next item 	 
    PRODUCT Dimension summary  	Coal and coal products
    FLOW Dimension summary  	 Sort ascendingSort descending
Total energy supply	544,664


*/

use "$tempDir/IEAWB.dta", clear
//tab Product


destring flow_level, replace force

tab flow_level if Units=="KTOE" & Country=="USA" & year==2008 & Product=="COAL" & Flow_Type=="TES"

//Great, lines up
clear



/*
sanity check for details

WDS thinks this for 2008 USA antcoal production:

Extended Energy Balances Table summary
Other:	   UNIT - ktoe 	   COUNTRY Dimension summary - United States Item summary 	   TIME - 2008 	 
    PRODUCT Dimension summary  	Anthracite
    FLOW Dimension summary  	 Sort ascendingSort descending
Total energy supply	3,792




*/

use "$tempDir/IEAWB.dta", clear
//tab Product


destring flow_level, replace force

tab flow_level if Units=="KTOE" & Country=="USA" & year==2008 & Product=="ANTCOAL" & Flow_Type=="TES"
/*

Great, per 9/22/2021 we're in business with the full dataset


*/

clear

/*


%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%



Step 3: Merge conversion factors into end-uses


%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

*/




use "$tempDir/IEAWB.dta", clear
//tab Product




//duplicate check pre-merge
duplicates r Country Flow_Type Product year


/*
duplicates r Country Flow_Type Product year

Duplicates in terms of Country Flow_Type Product year

--------------------------------------
   Copies | Observations       Surplus
----------+---------------------------
        1 |          192             0
        2 |     65469878      32734939
--------------------------------------


OK. going to reduce this to the TJ entries only

*/


keep if Units=="TJ"
//(32,735,131 observations deleted)

duplicates r Country Flow_Type Product year



/*
%%%%%%
%%%%%%
%%%%%%

The data are insanely large right now. I'm going to keep the flow variables I need:

TFC ELOUPUT TOTIND RESIDENT COMMPUB AGRICULT FISHING ONONSPEC TOTTRANS

%%%%%%
%%%%%%
%%%%%%
*/

keep if  Flow_Type=="TFC" |  Flow_Type=="ELOUTPUT" |   Flow_Type=="TOTIND" | Flow_Type=="RESIDENT" | Flow_Type=="COMMPUB" | Flow_Type=="AGRICULT" | Flow_Type=="FISHING"  | Flow_Type=="ONONSPEC" | Flow_Type=="TOTTRANS"
//(29,917,247 observations deleted)

count
//2,817,692



/*
%%%%%%
%%%%%%
%%%%%%

Great. Unique panel observations at this point. Now I will merge in conversion factors so that I can convert TerraJoules into KG of fuel later.

%%%%%%
%%%%%%
%%%%%%
*/



merge m:1 year Country Product using "$tempDir/IEAWB_ConversionFactors.dta", gen(merge_DimensionConversion)
/*
. merge m:1 year Country Product using "$tempDir/IEAWB_ConversionFactors.dta", gen(merge_DimensionConversion)


   Result                      Number of obs
    -----------------------------------------
    Not matched                     1,563,397
        from master                 1,362,577  (merge_DimensionConversion==1)
        from using                    200,820  (merge_DimensionConversion==2)

    Matched                         1,455,115  (merge_DimensionConversion==3)
    --------------

	
end of do-file




*/

tab Product if merge_DimensionConversion==3
tab Product if merge_DimensionConversion==2
tab Product if merge_DimensionConversion==1
tab Product 


tab  Flow_Type if merge_DimensionConversion==3
drop if merge_DimensionConversion==2


save "$tempDir/IEAWB_intermediate.dta", replace
/*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FLOWS I'VE KEPT

TFC ELOUTPUT TOTIND RESIDENT COMMPUB AGRICULT FISHING ONONSPEC TOTTRANS
				
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Drop merge==2 indicators will leave behind empty observations that only have conversion factors and no data on consumption. Likewise, at this point in time all I will need to retain is electricity generaiton and total non-energy final consumption (TFC).


*/



/*


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Step 3.2 Check Tamma's specification vs. my construction
				
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



*/


use "$tempDir/IEAWB_intermediate.dta", clear


/*Tamma's approach


Aggregate over the sectors she speaks to in her paper
*/
preserve
keep if  Flow_Type=="TOTIND" | Flow_Type=="RESIDENT" | Flow_Type=="COMMPUB" | Flow_Type=="AGRICULT" | Flow_Type=="FISHING"  | Flow_Type=="ONONSPEC" 
destring flow_level, replace force
collapse (sum) flow_level, by(Country year Units Product )
rename flow_level tamma_aggregate
count
//376,927
save "$tempDir/other_fuels_ag_tamma_definition.dta", replace
restore

/*Tamma's approach


Aggregate over the sectors she speaks to in her paper

Alternate: keep only those which I have all available
*/
preserve
keep if  Flow_Type=="TOTIND" | Flow_Type=="RESIDENT" | Flow_Type=="COMMPUB" | Flow_Type=="AGRICULT" | Flow_Type=="FISHING"  | Flow_Type=="ONONSPEC" 
bysort Country year Product: gen flow_count = _N
keep if flow_count==6
destring flow_level, replace force
collapse (sum) flow_level, by(Country year Units Product )
rename flow_level tamma_aggregate_alt
count
//244,240
save "$tempDir/other_fuels_ag_tamma_fullcoverage.dta", replace
restore




/*My approach

net transportation out of total_emissions*/

preserve
keep if  Flow_Type=="TOTTRANS"
count
//294,001
drop conversion_direction_X_per_Y conversion_enduse_Sector conversion_factor merge_DimensionConversion
destring flow_level, replace force
rename flow_level transit_flow
save "$tempDir/other_fuels_transonly.dta", replace
restore


preserve
keep if  Flow_Type=="TFC"
count
//412,725
drop conversion_direction_X_per_Y conversion_enduse_Sector conversion_factor merge_DimensionConversion
destring flow_level, replace force
rename flow_level tfc_flow
save "$tempDir/other_fuels_TFC.dta", replace
restore


/*


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Compare aggregated file coverage
				
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



*/





use "$tempDir/other_fuels_TFC.dta", clear




merge 1:1 year Country Product using "$tempDir/other_fuels_transonly.dta", gen(merge_transportfuels)

/*


    Result                      Number of obs
    -----------------------------------------
    Not matched                       118,724
        from master                   118,724  (merge_transportfuels==1)
        from using                          0  (merge_transportfuels==2)

    Matched                           294,001  (merge_transportfuels==3)
    -----------------------------------------

. 
end of do-file



Interesting. So transportation use is actually the odd one out here to some extent/
*/

keep if merge_transportfuels==3
drop merge_transportfuels

merge 1:1 year Country Product using "$tempDir/other_fuels_ag_tamma_definition.dta", gen(merge_tamma_data)

/*
. merge 1:1 year Country Product using "$tempDir/other_fuels_ag_tamma_definition.dta", gen(merge_tamma_data)

   Result                      Number of obs
    -----------------------------------------
    Not matched                       113,426
        from master                    15,250  (merge_tamma_data==1)
        from using                     98,176  (merge_tamma_data==2)

    Matched                           278,751  (merge_tamma_data==3)
    -----------------------------------------

. 
end of do-file



Wow. Yes these data don;t make a lot of sense. But we retain ~2/3 for comparison
*/



keep if merge_tamma_data==3
drop merge_tamma_data

gen xanders_aggregate = tfc_flow-transit_flow
sum xanders_aggregate tamma_aggregate 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
xanders_ag~e |     49,016     2964024    1.34e+07          0   2.97e+08
tamma_aggr~e |    278,751    477104.8     5127288          0   2.58e+08

. 
*/


//keep nonzero and missing pairs

keep if xanders_aggregate!=0 & tamma_aggregate!=0
keep if xanders_aggregate!=. & tamma_aggregate!=.
sum xanders_aggregate tamma_aggregate 

gen x_less_t = xanders_aggregate - tamma_aggregate
sum x_less_t, d

count
//48,410

//check correlations
corr tamma_aggregate xanders_aggregate
qqplot tamma_aggregate xanders_aggregate

/*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OK, they're virtual analogues but Tamma's has much larger coverage here.

The flip side is it is "missing" some of the residual that's picked up by my measure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

This time, try with Tamma's data with only full coverage

*/




use "$tempDir/other_fuels_TFC.dta", clear
merge 1:1 year Country Product using "$tempDir/other_fuels_transonly.dta", gen(merge_transportfuels)
keep if merge_transportfuels==3
drop merge_transportfuels
merge 1:1 year Country Product using "$tempDir/other_fuels_ag_tamma_fullcoverage.dta", gen(merge_tamma_alternate)

/*

. merge 1:1 year Country Product using "$tempDir/other_fuels_ag_tamma_fullcoverage.dta", gen(merge_tamma_alternate)

  Result                      Number of obs
    -----------------------------------------
    Not matched                        63,327
        from master                    56,544  (merge_tamma_alternate==1)
        from using                      6,783  (merge_tamma_alternate==2)

    Matched                           237,457  (merge_tamma_alternate==3)
    -----------------------------------------

. 
end of do-file


*/



keep if merge_tamma_alternate==3
drop merge_tamma_alternate

gen xanders_aggregate = tfc_flow-transit_flow
sum xanders_aggregate tamma_aggregate_alt
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
xanders_ag~e |      7,722    1.32e+07    3.04e+07          0   2.97e+08
tamma_aggr~t |    237,457    391708.4     5320320          0   2.58e+08
*/

keep if xanders_aggregate!=0 & tamma_aggregate_alt!=0
keep if xanders_aggregate!=. & tamma_aggregate_alt!=.

sum xanders_aggregate tamma_aggregate_alt


gen x_less_t = xanders_aggregate - tamma_aggregate
sum x_less_t, d


count
// 7,116


corr tamma_aggregate_alt xanders_aggregate
qqplot tamma_aggregate_alt xanders_aggregate

//OK, so perhaps similar problems but it appears Tama's metric coverage is much better

clear

/*


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Resume normal code constructing the emissions panel
			
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



*/

/*


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Step 4: Continue building the emissions intensity panel dataset.
				
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



*/

use "$tempDir/IEAWB_intermediate.dta", clear
drop merge*



/*
From below, I also know I need to harmonize all the incorrect naming conventions. That is, the IEA data on emissions factors are not hamronizedin terms of country names with the IEA world energy balance data.

I need to replace all the names after merging conversion factors,but before merging in the electricity generation efficiency factors, so as to have that merge go smoothly.

*/
replace Country = strlower(Country)
replace Country = "australia" if Country=="australi"
//Fix error here with coding bolivia
/*
//replace Country = "bolivarian republic of venezuela"  if Country=="bolivia"
*/
replace Country = "plurinational state of bolivia" if Country=="bolivia"
replace Country = "bosnia and herzegovina" if Country=="bosniaherz"
replace Country = "brunei darussalam" if Country=="brunei"
replace Country = "china (pr of china and hong kong china)" if Country=="china"
replace Country = "costa rica" if Country=="costarica"
replace Country = "cote d'ivoire" if Country=="coteivoire"
replace Country = "curacao/netherlands antilles" if Country=="curacao"
replace Country = "czech republic" if Country=="czech"
replace Country = "dominican republic" if Country=="dominicanr"
replace Country = "el salvador" if Country=="elsalvador"
replace Country = "equatorial guinea" if Country=="eqguinea"
replace Country = "hong kong (china)" if Country=="hongkong"
replace Country = "islamic republic of iran" if Country=="iran"
replace Country = "lao people's democratic republic" if Country=="lao"
replace Country = "luxembourg" if Country=="luxembou"
replace Country = "memo*: burkina faso" if Country=="mburkinafa"
replace Country = "memo*: chad" if Country=="mchad"
replace Country = "memo: fsu 15" if Country=="fsund"
replace Country = "memo: greenland" if Country=="mgreenland"
replace Country = "memo: madagascar" if Country=="mmadagasca"
replace Country = "memo: mali" if Country=="mmali"
replace Country = "memo*: mauritania" if Country=="mmauritani"
replace Country = "republic of moldova" if Country=="moldova"
replace Country = "memo: palestinian authority" if Country=="mpalestine "
//replace Country = "???" if Country=="mrwanda"
replace Country = "memo: uganda" if Country=="muganda"
replace Country = "netherlands" if Country=="nethland"
replace Country = "republic of north macedonia" if Country=="northmaced"
replace Country = "new zealand" if Country=="nz"
replace Country = "other africa" if Country=="otherafric"
replace Country = "other non-oecd asia" if Country=="otherasia"
replace Country = "other non-oecd americas" if Country=="otherlatin"
replace Country = "philippines" if Country=="philippine"
replace Country = "russian federation" if Country=="russia"
replace Country = "saudi arabia" if Country=="saudiarabi"
replace Country = "slovak republic" if Country=="slovakia"s
replace Country = "south africa" if Country=="southafric"
replace Country = "sri lanka" if Country=="srilanka"
replace Country = "south sudan" if Country=="ssudan"
replace Country = "switzerland" if Country=="switland"
replace Country = "syrian arab republic" if Country=="syria"
replace Country = "chinese taipei" if Country=="taipei"
//lol
replace Country = "united republic of tanzania" if Country=="tanzania"
replace Country = "trinidad and tobago" if Country=="trinidad"
replace Country = "turkmenistan" if Country=="turkmenist"
replace Country = "united arab emirates" if Country=="uae"
replace Country = "united states" if Country=="usa"
replace Country = "united kingdom" if Country=="uk"
replace Country = "bolivarian republic of venezuela" if Country=="venezuela"
replace Country = "viet nam" if Country=="vietnam"
replace Country = "memo: former yugoslavia" if Country=="yugond"




 
/*

To construct the two aggregate emissions intensities, all I need are total final consumption (which will not include transformation by the electricity and heat sectors) of outside fuels, and then total electricity output for each country and each year.

I will make these two datasets separately to ease with the merging process.
*/


preserve
keep if Flow_Type=="ELOUTPUT" 
save "$tempDir/IEA_Elec_Output.dta", replace
restore


/*


This former dataset will ultimately not be useful as IEA does this themselves.


*/

preserve
keep if Flow_Type=="TFC" 
save "$tempDir/IEA_TFC.dta", replace
restore


/*
Alternate releveant flow codes

keep if Flow_Type=="TOTIND" | Flow_Type=="RESIDENT" | Flow_Type=="COMMPUB" | Flow_Type=="AGRICULT" | Flow_Type=="FISHING" | Flow_Type=="ONONSPEC" 
 
*/

preserve
keep if Flow_Type=="TOTIND" | Flow_Type=="RESIDENT" | Flow_Type=="COMMPUB" | Flow_Type=="AGRICULT" | Flow_Type=="FISHING" | Flow_Type=="ONONSPEC" 
save "$tempDir/IEA_tamma_consumption_aggregate.dta", replace
restore

clear
/*

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%



Step 4.1: Harmonize products to be mapped into those which we have emissions factors for from the IEA dataset on emissions intensity. First, restructure the emissions factors dataset for the electricity sector for the merge. I'm going to just create a new variable for aggregate products to merge over that's the same as those in the emissions factors data ("Product_Category_for_Merge"). This may be useful for crosschecking the IEA total emissions factor methodology.


Then repeat this for the generalized CHP combined and "Implied emission factors" datasets

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

*/


use "$tempDir/electricity_factors.dta", clear
tab Product



/*

tab Product
                Product |      Freq.     Percent        Cum.
------------------------+-----------------------------------
Coal peat and oil shale |      7,740       16.67       16.67
         Memo: Biofuels |      7,740       16.67       33.33
            Natural Gas |      7,740       16.67       50.00
   Non-Renewable wastes |      7,740       16.67       66.67
                    Oil |      7,740       16.67       83.33
                  Total |      7,740       16.67      100.00
------------------------+-----------------------------------
                  Total |     46,440      100.00

. 
end of do-file


I need to map all electricity generation sources into one of these categories or mark it as zero emissions(?)

*/

gen Product_Category_for_Merge = Product
drop Product
replace Country = strlower(Country)
save "$tempDir/electricity_factors_formerge.dta", replace

clear

/*

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
Repeat this for the combined heat and power datasets
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

*/


use "$tempDir/heatpower_factors.dta", clear
tab Product

/*

. tab Product

                Product |      Freq.     Percent        Cum.
------------------------+-----------------------------------
Coal peat and oil shale |      7,740       16.67       16.67
         Memo: Biofuels |      7,740       16.67       33.33
            Natural Gas |      7,740       16.67       50.00
   Non-Renewable wastes |      7,740       16.67       66.67
                    Oil |      7,740       16.67       83.33
                  Total |      7,740       16.67      100.00
------------------------+-----------------------------------
                  Total |     46,440      100.00

. 

*/




gen CHP_Products = Product
gen factor_units = "kg CO2 per kWh"
drop Product
replace Country = strlower(Country)
tab Country
save "$tempDir/heatpower_factors_formerge.dta", replace

clear



/*

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Then repeat this for the generalized "Implied emission factors" dataset

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

*/

use "$tempDir/outside_use_factors.dta", clear
tab Product

/*
. tab Product

                        Product |      Freq.     Percent        Cum.
--------------------------------+-----------------------------------
                     Anthracite |      5,670        3.23        3.23
              Aviation gasoline |      5,670        3.23        6.45
                            BKB |      5,670        3.23        9.68
                        Bitumen |      5,670        3.23       12.90
                       Coal tar |      5,670        3.23       16.13
                 Coke oven coke |      5,670        3.23       19.35
                    Coking coal |      5,670        3.23       22.58
                         Ethane |      5,670        3.23       25.81
                       Fuel oil |      5,670        3.23       29.03
                       Gas coke |      5,670        3.23       32.26
        Gas/diesel oil excl bio |      5,670        3.23       35.48
         Gasoline type jet fuel |      5,670        3.23       38.71
                       Kerosene |      5,670        3.23       41.94
Kerosene type jet fuel excl bio |      5,670        3.23       45.16
                        Lignite |      5,670        3.23       48.39
      Liquefied petroleum gases |      5,670        3.23       51.61
                     Lubricants |      5,670        3.23       54.84
        Motor gasoline excl bio |      5,670        3.23       58.06
                        Naphtha |      5,670        3.23       61.29
            Natural gas liquids |      5,670        3.23       64.52
     Non-specified oil products |      5,670        3.23       67.74
        Oil shale and oil sands |      5,670        3.23       70.97
          Other bituminous coal |      5,670        3.23       74.19
                 Paraffin waxes |      5,670        3.23       77.42
                    Patent fuel |      5,670        3.23       80.65
                           Peat |      5,670        3.23       83.87
                  Peat products |      5,670        3.23       87.10
                 Petroleum coke |      5,670        3.23       90.32
                   Refinery gas |      5,670        3.23       93.55
            Sub-bituminous coal |      5,670        3.23       96.77
                   White spirit |      5,670        3.23      100.00
--------------------------------+-----------------------------------
                          Total |    175,770      100.00

. 
*/




gen Product_Category_for_Merge = Product
gen factor_units = "kg CO2 per kg fuel"
drop Product
replace Country = strlower(Country)
save "$tempDir/outside_use_factors_formerge.dta", replace

clear






/*

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%



Step 4.2: Open the IEA Total Final Consumption File. 

Adjust 'Product' labels so that I can merge in fuel-specific emissions factors for those products with 1-1 matches.

Then use ad-hoc or subjective methods to match the remaining fuels with emissions intensities where applicable.

Then, generate the contry-year average emissions factors for fuel use outside of electricity generation.


%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

*/

use "$tempDir/IEA_tamma_consumption_aggregate.dta", clear

/*

Check to see if some entries solely contain missing values

*/

count if Product=="TOTAL"

count if (flow_level==".." & Product=="TOTAL") | (flow_level=="x" & Product=="TOTAL") 

tab flow_level if Product=="HEAT"
tab flow_level if Product=="HEATNS"


/*
Drop the HEATNS and Electricity entries as they're empty and duplicitous.

I'll need to use average emissions for CHP plants for the heat values.

Below code drops some of the aggregates so as to avoid double counting.
*/

drop if Product=="HEATNS" |  Product=="ELECTR" | Product =="TOTAL" | Product=="MRENEW"  | Product=="BROWN"   | Product=="HARDCOAL"  | Product=="CRNGFEED"  | Product=="MANGAS"  | Product=="RENEWNS"
//(402,990 observations deleted)


/*
I'll also neeed to drop renewable energy sources that are inputs into electricity and heat:



gen ze_sector_flag = 0
replace ze_sector_flag=1 if Product=="HYDRO"
replace ze_sector_flag=1 if Product=="NUCLEAR"
replace ze_sector_flag=1 if Product=="WIND"
replace ze_sector_flag=1 if Product=="SOLARPV"
replace ze_sector_flag=1 if Product=="SOLARTH"
replace ze_sector_flag=1 if Product=="TIDE"
replace ze_sector_flag=1 if Product=="GEOTHERM"

tab Product if missing_product_merge_flag==1 & ze_sector_flag==0


*/

drop if  Product=="HYDRO" | Product=="NUCLEAR" | Product=="WIND" | Product=="SOLARPV" | Product=="SOLARTH" | Product=="TIDE" | Product=="GEOTHERM"
//(137,967 observations deleted)
count
//1,252,150

/*
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%

Finally, drop global aggregates that aren't individual countries

%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%

*/

tab Country
drop if Country=="africa"
drop if Country=="other africa"
drop if Country=="other non-oecd americas"
drop if Country=="other non-oecd asia"
drop if Country=="world"
drop if Country=="memo: former yugoslavia"
drop if Country=="memo: fsu 15"
count
//1,191,128



/*
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%

First, create a dataset of country-year pairs logging total energy consumption (outside of the electricity sector) for coverage comparison later. This will allow me to look at the total TJ consumed in each country year in the sectors we care about vs. the consumption that can be paired with emissions factor in those sectors.

%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%

*/

preserve
destring flow_level, replace force
bysort Country year: egen total_energy_consumption = total(flow_level)
collapse total_energy_consumption, by(Country year)
save "$tempDir/total_panel_consumption.dta", replace
restore


/*

After dropping the above categories, change nomenclature in the total final consumption world energy balances data to match the emissions intensity in the IEA
implied data.

*/

gen Product_Category_for_Merge =""


replace Product_Category_for_Merge = "Anthracite" if  Product== "ANTCOAL"
replace Product_Category_for_Merge = "Aviation gasoline" if  Product== "AVGAS"
replace Product_Category_for_Merge = "BKB" if  Product== "BKB"
replace Product_Category_for_Merge = "Bitumen" if  Product== "BITUMEN"
replace Product_Category_for_Merge = "Coal tar" if  Product== "COALTAR"
replace Product_Category_for_Merge = "Coke oven coke" if  Product== "OVENCOKE"
replace Product_Category_for_Merge = "Coking coal" if  Product== "COKCOAL"
replace Product_Category_for_Merge = "Ethane" if  Product== "ETHANE"
replace Product_Category_for_Merge = "Fuel oil" if  Product== "RESFUEL"
replace Product_Category_for_Merge = "Gas coke" if  Product== "GASCOKE"
replace Product_Category_for_Merge = "Gas/diesel oil excl bio" if  Product== "NONBIODIES"
replace Product_Category_for_Merge = "Gasoline type jet fuel" if  Product== "JETGAS"
replace Product_Category_for_Merge = "Kerosene" if  Product== "OTHKERO"
replace Product_Category_for_Merge = "Kerosene type jet fuel excl bio" if  Product== "NONBIOJETK"
replace Product_Category_for_Merge = "Lignite" if  Product== "LIGNITE"
replace Product_Category_for_Merge = "Liquefied petroleum gases" if  Product== "LPG"
replace Product_Category_for_Merge = "Lubricants" if  Product== "LUBRIC"
replace Product_Category_for_Merge = "Motor gasoline excl bio" if  Product== "NONBIOGASO"
replace Product_Category_for_Merge = "Naphtha" if  Product== "NAPHTHA"
replace Product_Category_for_Merge = "Natural gas liquids" if  Product== "NGL"
replace Product_Category_for_Merge = "Non-specified oil products" if  Product== "ONONSPEC"
replace Product_Category_for_Merge = "Oil shale and oil sands" if  Product== "OILSHALE"
replace Product_Category_for_Merge = "Other bituminous coal" if  Product== "BITCOAL"
replace Product_Category_for_Merge = "Paraffin waxes" if  Product== "PARWAX"
replace Product_Category_for_Merge = "Patent fuel" if  Product== "PATFUEL"
replace Product_Category_for_Merge = "Peat" if  Product== "PEAT"
replace Product_Category_for_Merge = "Peat products" if  Product== "PEATPROD"
replace Product_Category_for_Merge = "Petroleum coke" if  Product== "PETCOKE"
replace Product_Category_for_Merge = "Refinery gas" if  Product== "REFINGAS"
replace Product_Category_for_Merge = "Sub-bituminous coal" if  Product== "SUBCOAL"
replace Product_Category_for_Merge = "White spirit" if  Product== "WHITESP"


gen missing_product_merge_flag = (Product_Category_for_Merge=="")
tab missing_product_merge_flag

/*
missing_pro |
duct_merge_ |
       flag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |    734,599       61.67       61.67
          1 |    456,529       38.33      100.00
------------+-----------------------------------
      Total |  1,191,128      100.00

. 


*/

tab Product if missing_product_merge_flag==1

/*

As spoken to above-I've assumed all zero emissions generation goes into either heat or power - theses were matched and dropped

*/


/*

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%



Step 4.3: The above crosswalk covers those that are direct matches. Because none of these have emissions intensity factors in the IEA panel, I'm going to assume they all go directly into electricity production. This may be incorrect for some geothermal generation. This is technically arbitrary.  For now, I'm just going to shoehorn the rest into one of the below categories I can take from the CHP dataset. These are purely heuristic assigments.


I use the table "tab Product if missing_product_merge_flag==1" above to track the products and then assign them a CHP type from

	
                Product |      Freq.     Percent        Cum.
------------------------+-----------------------------------
Coal peat and oil shale |      7,740       16.67       16.67
         Memo: Biofuels |      7,740       16.67       33.33
            Natural Gas |      7,740       16.67       50.00
   Non-Renewable wastes |      7,740       16.67       66.67
                    Oil |      7,740       16.67       83.33
                  Total |      7,740       16.67      100.00
------------------------+-----------------------------------
                  Total |     46,440      100.00

. 

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%



*/

gen CHP_Products =""

replace CHP_Products = "Oil" if  Product== "ADDITIVE"
replace CHP_Products = "Memo: Biofuels" if  Product== "BIODIESEL"
replace CHP_Products = "Memo: Biofuels" if  Product== "BIOGASES"
replace CHP_Products = "Memo: Biofuels" if  Product== "BIOGASOL"
replace CHP_Products = "Memo: Biofuels" if  Product== "BIOJETKERO"
replace CHP_Products = "Natural Gas" if  Product== "BLFURGS"
replace CHP_Products = "Coal peat and oil shale" if  Product== "CHARCOAL"
replace CHP_Products = "Natural Gas" if  Product== "COKEOVGS"
replace CHP_Products = "Oil" if  Product== "CRUDEOIL"
replace CHP_Products = "Natural Gas" if  Product== "GASWKSGS"
replace CHP_Products = "Total" if  Product== "HEAT"
replace CHP_Products = "Non-Renewable wastes" if  Product== "INDWASTE"
replace CHP_Products = "Non-Renewable wastes" if  Product== "MUNWASTEN"
replace CHP_Products = "Memo: Biofuels" if  Product== "MUNWASTER"
replace CHP_Products = "Natural Gas" if  Product== "NATGAS"
replace CHP_Products = "Oil" if  Product== "NONCRUDE"
replace CHP_Products = "Memo: Biofuels " if  Product== "OBIOLIQ"
replace CHP_Products = "Natural Gas" if  Product== "OGASES"
replace CHP_Products = "Coal peat and oil shale" if  Product== "OTHER"
replace CHP_Products = "Memo: Biofuels" if  Product== "PRIMSBIO"
replace CHP_Products = "Oil" if  Product== "REFFEEDS"

gen interpolated_product_flag = (CHP_Products !="")

//check for none left out
tab Product if missing_product_merge_flag==1 & interpolated_product_flag==0

//great.




/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%



Step 4.4: Merge in the CHP-based factors for the emissions from products not explicitly covered that I have determined (using heuristic)


%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/



preserve
merge m:m year Country CHP_Products using "$tempDir/heatpower_factors_formerge.dta", gen(merge_CHP_Factors)
keep if merge_CHP_Factors==3
drop merge*
count
// 48,927
save "$tempDir/matched_CHP_use.dta", replace
restore



/*

Note from 11/10/2021:

Fixing Bolivia (which was encoded previously as a duplicate venezuela) has changed some of these entries.
 
*/




/*

Execute Total Final Consumption Merge from implied emissions factors. -- Rerun above block in similar way

*/

preserve
merge m:m year Country Product_Category_for_Merge using "$tempDir/outside_use_factors_formerge.dta", gen(merge_emissions_factors)
keep if merge_emissions_factors==3
drop merge*
count
//  82,069
save "$tempDir/matched_otherfuel_use.dta", replace
restore



/*

Append the above datasets

*/




use "$tempDir/matched_otherfuel_use.dta", clear
append using "$tempDir/matched_CHP_use.dta"


duplicates r Country Flow_Type Product year conversion_enduse_Sector

/*

OK, Venezuela and Bolivia are now fixed

Duplicates in terms of Country Flow_Type Product year conversion_enduse_Sector

--------------------------------------
   Copies | Observations       Surplus
----------+---------------------------
        1 |       130996             0
--------------------------------------

. 

. 

*/




/*
!@#$!@#$!@#$
!@#$!@#$!@#$
save data out for kyle
!@#$!@#$!@#$
save "$tempDir/matched_quantities_factors.dta" , replace
!@#$!@#$!@#$
!@#$!@#$!@#$
!@#$!@#$!@#$
*/

/*

Check how much generation is missing emissions intensity factors after merge

*/

count
// 130,996
count if emissions_factor!=.
//90,149




/*

OK, so about 1/3 entries are still missing emissions factors (such that factors are nonzero)

*/

keep if emissions_factor!=.

destring flow_level, replace force
bysort Country year: egen covered_energy_consumption = total(flow_level)

collapse covered_energy_consumption, by(Country year)

save "$tempDir/covered_panel_consumption.dta", replace


/*

NB: Reminder that emissions factors only start in 1990

*/



use "$tempDir/covered_panel_consumption.dta", clear

merge 1:1 Country year using "$tempDir/total_panel_consumption.dta", gen(merge_coverage_check)

/*
. merge 1:1 Country year using "$tempDir/total_panel_consumption.dta", gen(merge_cover
> age_check)

    Result                      Number of obs
    -----------------------------------------
    Not matched                         6,950
        from master                         0  (merge_coverage_check==1)
        from using                      6,950  (merge_coverage_check==2)

    Matched                             4,171  (merge_coverage_check==3)
    -----------------------------------------

. 
end of do-file




%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%




OK, so a decennt amount of country-year pairs contain no products which I can match with emissions.

However, this could be a product of the NB above for years before 1990.


*/

drop if year<1990
//(5,478 observations deleted)

tab merge_coverage_check
/*
. tab merge_coverage_check

   Matching result from |
                  merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
         Using only (2) |      1,472       26.09       26.09
            Matched (3) |      4,171       73.91      100.00
------------------------+-----------------------------------
                  Total |      5,643      100.00

. 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


OK, getting better

*/


tab Country if merge_coverage_check==2 & year<2019
/*

OK great. Almost all of these are aggregates


I am missing datapoints on emissions intensity (for all individual Products) for a given country-year pair for some years after 1990 for the following countries:

cambodia
congo
congorep
eritrea
guyana
koreadpr
kosovo
laos
burkina faso
chad
mauritania
greenland
mali
montenegro
palestine
rwanda
namibia
niger
south sudan
suriname


*/

keep if merge_coverage_check==3

sum covered_energy_consumption total_energy_consumption
count
//4,171

gen coverage_ratio = covered_energy_consumption / total_energy_consumption

sum coverage_ratio, d

/*

!@#$!@@#$!$!@#$
!@#$!@@#$!$!@#$
!@#$!@@#$!$!@#$

OK, circa 11/10 my coverage got a little worse

!@#$!@@#$!$!@#$
!@#$!@@#$!$!@#$
!@#$!@@#$!$!@#$


. sum coverage_ratio, d

                       coverage_ratio
-------------------------------------------------------------
      Percentiles      Smallest
 1%     .0219715       .0092892
 5%     .0583177       .0101372
10%     .1239256       .0102537       Obs               4,171
25%     .7631143       .0102539       Sum of wgt.       4,171

50%     .9972495                      Mean           .8034827
                        Largest       Std. dev.      .3254778
75%            1              1
90%            1              1       Variance       .1059358
95%            1              1       Skewness      -1.458417
99%            1              1       Kurtosis       3.507436

. 
end of do-file



*/


/*

OK, so a decent amount of coverage remains missing here if I want to use solely what I have in panel form. That being said, a lot of this is probably for small countries...

What if I weight it by total energy consumpion?

*/

gen fweights = floor(total_energy_consumption)
sum coverage_ratio [fw=fweights] , d

/*


!@#$!@@#$!$!@#$
!@#$!@@#$!$!@#$
!@#$!@@#$!$!@#$

	Old: OK. As expected, coverage is much better for larger nations.


	11/10: Coverage is better!

!@#$!@@#$!$!@#$
!@#$!@@#$!$!@#$
!@#$!@@#$!$!@#$



OK. As expected, coverage is much better for larger nations.


*/

tab year, sum(coverage_ratio)

preserve

collapse (sum) covered_energy_consumption total_energy_consumption, by(year)

generate coverage_ratio = covered_energy_consumption/total_energy_consumption 

tab year, sum(coverage_ratio)


twoway line coverage_ratio year if year<2019


 graph export "/Users/xabajian/Documents/GitHub/adaptation_multiplier/figures/coverage_ratios.jpg", replace as(jpg) name("Graph") quality(90)

restore
clear



/*

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Step 5.1: Perform unit conversions and calculate the panel data for average emissions per unit consumption of heat not in the electricity or transportation sectors

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

*/




use "$tempDir/matched_otherfuel_use.dta", clear
append using "$tempDir/matched_CHP_use.dta"

count
//130,996



/*

For emissions factors that come in emissions per mass, I need to convert TJ of energy consumed to kg of fuels.

*/

destring conversion_factor, replace force
destring flow_level, replace force
/*
conversion dimensional analysis is as follows:


Mass (kg) = flow levels (TJ) * (1,000,000,000 KJ/Terrajoule) * (KJ/kilogram) ^-1

*/
gen consumption_masses = flow_level * (1000000000) * (1/conversion_factor) if energy_enduse_sector=="Use Outside Electricity and Heat Generation"


gen total_emissions = consumption_masses * emissions_factor if energy_enduse_sector=="Use Outside Electricity and Heat Generation"


/*

For emissions factors in that are in units of emissions per energy (Joules) I just need to convert Joules to kWh:

1 TJ = 277778 kWh

*/

//NB: Flag for missing product marks all entries with other fuels emissions factors taken from the CHP sector
gen kwh_consumption = 277778 * flow_level if missing_product_merge_flag==1
replace total_emissions = kwh_consumption * emissions_factor if missing_product_merge_flag==1
label var total_emissions "country-year-fuel emissions in kg of cO2"


count if total_emissions!=.
// 89,732

/*
Ok, so still missing a decent amount of emissions levels for quite a few country-year-product pairs but that to some extent is to be expected from above.


Now, collapse over all products to generate country-year total emissions and total energy pairs for fuels used outside the electric sector

*/

//generate country-year total emissions 
bysort Country year: egen country_year_total_emissions =total(total_emissions)

//generate country-year total energy consumption 
bysort Country year: egen country_year_total_energy =total(flow_level) 

//scale consumption down to kJ from TJ
replace country_year_total_energy = 1000000000*country_year_total_energy

//collapse into single country-year observations
collapse country_year_total_energy country_year_total_emissions, by(Country year)
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



sum factor_kwh non_electricity_emissions_factor, d

/*
 sum factor_kwh non_electricity_emissions_factor, d

      country - year kg cO2 per kWh from outside fuels
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%     .0062181              0
10%     .0221546              0       Obs               4,341
25%     .2091302              0       Sum of wgt.       4,341

50%     .3436839                      Mean           .5220536
                        Largest       Std. dev.      .7902805
75%     .5116295       8.403714
90%     1.151904       10.21645       Variance       .6245432
95%     1.746136       10.63845       Skewness       9.347542
99%     3.311624        24.0438       Kurtosis        205.424

      country - year kg cO2 per kiloJoule from outside
                            fuels
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%     1.73e-06              0
10%     6.15e-06              0       Obs               4,341
25%     .0000581              0       Sum of wgt.       4,341

50%     .0000955                      Mean            .000145
                        Largest       Std. dev.      .0002195
75%     .0001421       .0023344
90%       .00032       .0028379       Variance       4.82e-08
95%      .000485       .0029551       Skewness       9.347542
99%     .0009199       .0066788       Kurtosis        205.424

. 
end of do-file
*/

count if factor_kwh!=0 & non_electricity_emissions_factor!=0
// 4,270


save "$tempDir/preliminary_non_electric_factors.dta", replace



/*
merge in electricity factors from the IEA's original factor data
*/

use "$tempDir/preliminary_non_electric_factors.dta", clear

merge 1:1 Country year using "$processedDir/IEA_Electric_Factors.dta", gen(merge_electricity_factors)

/*
. merge 1:1 Country year using "$processedDir/IEA_Electric_Factors.dta", gen(merge_ele
> ctricity_factors)

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

cambodia
congo
congorep
eritrea
guyana
koreadpr
kosovo
laos
burkina faso
chad
mauritania
greenland
mali
montenegro
palestine
rwanda
namibia
niger
south sudan
suriname



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
xtset country_byte year

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
drop merge

replace ISO3= "BOL" if Country=="plurinational state of bolivia"

//save finished dataset
save "$processedDir/country_year_emissions_factor.dta", replace






/*

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Step 5.2: Create dataset at the country level for average eletricity and other fuels emissions factors for 2010-2018

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

*/


use "$processedDir/country_year_emissions_factor.dta", clear


/*

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Check how many missing entries and spurious zeros we have.

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

*/

count if electricity_emissions_factor==0
//0
count if otherfuels_emissions_factor==0
//170
count if electricity_emissions_factor==.
//325
count if otherfuels_emissions_factor==.
//99

tab Country if electricity_emissions_factor==.


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


bysort Country year: egen mean_2010s_electric = mean(electricity_emissions_factor)
bysort Country year: egen mean_2010s_otherfuels = mean(otherfuels_emissions_factor)

collapse mean_2010s_electric mean_2010s_otherfuels, by(Country ISO3)

save "$processedDir/country_year_emissions_factor_2010s.dta", replace


