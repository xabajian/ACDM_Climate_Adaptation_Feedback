/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*
Alexander Abajian

9/20/2021

Import IEA emissions factors panel datasets for electricity and outside fuel consumption.

Create a panel dataset from the raw data as provided by IEA in wide and .xls form. 

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
	
	
//global project_name "adaptation_multiplier" //enter project name here

//data folders 
global startDir "/Users/xabajian/Dropbox/adaptation_multiplier_data"
global rawDir "$startDir/rawData"
global processedDir "$startDir/processedData"
global tempDir "$startDir/temp"
//global logsDir "$startDir/data/logs"

//repository paths
/*
global tablesDir "$startDir/repo/tables"
global figuresDir "$startDir/repo/figures"
*/

/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%



Step 1: Import emissions factors dataset for fuels outside of heat and/or electricity generation.

Create a .dta file, then reshape into a panel dataset. These stem from the original "Implied emission factors" in IEA's dataset

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/


import excel "$rawDir/IEA_Emissions_Factors/IEA_Emission_Factors.xls", sheet("Implied emission factors") cellrange(A3:AF65536) firstrow clear


/*

Excel formatting pulls in the column names as-displayed in excel.
The following code changes the excel column variable labels to the correct years for reshaping

*/
rename	C	year_1990
rename	D	year_1991
rename	E	year_1992
rename	F	year_1993
rename	G	year_1994
rename	H	year_1995
rename	I	year_1996
rename	J	year_1997
rename	K	year_1998
rename	L	year_1999
rename	M	year_2000
rename	N	year_2001
rename	O	year_2002
rename	P	year_2003
rename	Q	year_2004
rename	R	year_2005
rename	S	year_2006
rename	T	year_2007
rename	U	year_2008
rename	V	year_2009
rename	W	year_2010
rename	X	year_2011
rename	Y	year_2012
rename	Z	year_2013
rename	AA	year_2014
rename	AB	year_2015
rename	AC	year_2016
rename	AD	year_2017
rename	AE	year_2018
rename	estimated	year_2019




//Drop empty rows
drop if Country==""

//Destring all entries 
destring year_*, replace force

/*
Perform reshape into panel data

Replace text entries with standard missing entries in stata formatting

Harmonize labeling for append
*/

reshape long year_,i(Country Product) j(year)
rename year_ emissions_factor
label var emissions_factor "implied emissions factor: kg CO2/kg fuel"
replace emissions_factor = . if emissions_factor==0
gen energy_enduse_sector = "Use Outside Electricity and Heat Generation"

save "$tempDir/outside_use_factors.dta", replace

clear



/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Step 2 (and 3): Repeat the above process for electricity, combined electricity/heat, and (circa 9/27/2021) read in adjustment factors for trade

I'm going to start with electricity factors: Import electricity emissions factors dataset. Creat .dta file, then reshape. This is the primary dataset of interest because this allows me to directly use IEA's emissions factors for electricity only use.

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/



import excel "$rawDir/IEA_Emissions_Factors/IEA_Emission_Factors.xls", sheet("CO2KWH ELE") cellrange(A3:AF1551) firstrow clear

//drop excess entries created by excel formatting.
drop if Country==""


/*

Excel formatting pulls in the column names as-displayed in excel.
The following code changes the excel column variable labels to the correct years for reshaping

*/
rename	C	year_1990
rename	D	year_1991
rename	E	year_1992
rename	F	year_1993
rename	G	year_1994
rename	H	year_1995
rename	I	year_1996
rename	J	year_1997
rename	K	year_1998
rename	L	year_1999
rename	M	year_2000
rename	N	year_2001
rename	O	year_2002
rename	P	year_2003
rename	Q	year_2004
rename	R	year_2005
rename	S	year_2006
rename	T	year_2007
rename	U	year_2008
rename	V	year_2009
rename	W	year_2010
rename	X	year_2011
rename	Y	year_2012
rename	Z	year_2013
rename	AA	year_2014
rename	AB	year_2015
rename	AC	year_2016
rename	AD	year_2017
rename	AE	year_2018
rename	estimated	year_2019


//Destring data for reshape
destring year_*, replace force

/*
Perform reshape into panel data

Replace text entries with standard missing entries in stata formatting

Harmonize labeling for append
*/
reshape long year_,i(Country Product) j(year)
rename year_ emissions_factor
replace emissions_factor = emissions_factor/1000
label var emissions_factor "implied emissions factor: kg CO2/kilowatt hour"
replace emissions_factor = . if emissions_factor==0

gen energy_enduse_sector = "Electric Power Only"

//save electricity factors out
save "$tempDir/electricity_factors.dta", replace


/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Step 3: Import combined heat and electricity emissions factors dataset. Creat .dta file, then reshape.

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/


import excel "$rawDir/IEA_Emissions_Factors/IEA_Emission_Factors.xls", sheet("CO2KWH ELE & HEAT") cellrange(A3:AF1551) firstrow clear

//Drop excess entries
drop if Country==""

rename	C	year_1990
rename	D	year_1991
rename	E	year_1992
rename	F	year_1993
rename	G	year_1994
rename	H	year_1995
rename	I	year_1996
rename	J	year_1997
rename	K	year_1998
rename	L	year_1999
rename	M	year_2000
rename	N	year_2001
rename	O	year_2002
rename	P	year_2003
rename	Q	year_2004
rename	R	year_2005
rename	S	year_2006
rename	T	year_2007
rename	U	year_2008
rename	V	year_2009
rename	W	year_2010
rename	X	year_2011
rename	Y	year_2012
rename	Z	year_2013
rename	AA	year_2014
rename	AB	year_2015
rename	AC	year_2016
rename	AD	year_2017
rename	AE	year_2018
rename	estimated	year_2019

destring year_*, replace force

/*
Perform reshape into panel data

Replace text entries with standard missing entries in stata formatting

Harmonize labeling for append
*/
reshape long year_,i(Country Product) j(year)
rename year_ emissions_factor
replace emissions_factor = emissions_factor/1000
label var emissions_factor "implied emissions factor: kg CO2/kilowatt hour"
replace emissions_factor = . if emissions_factor==0
gen energy_enduse_sector = "Combined Heat and Power"


//save heat and power dataset out
save "$tempDir/heatpower_factors.dta", replace



/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Step 4: Import adjustment factors for electricity emissions from the trade balance page. Create .dta file, then reshape.

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/


import excel "$rawDir/IEA_Emissions_Factors/IEA_Emission_Factors.xls", sheet("Trade adjustment") cellrange(A3:AD261) firstrow clear

//Drop excess entries
drop if Country==""

rename	B	year_1990
rename	C	year_1991
rename	D	year_1992
rename	E	year_1993
rename	F	year_1994
rename	G	year_1995
rename	H	year_1996
rename	I	year_1997
rename	J	year_1998
rename	K	year_1999
rename	L	year_2000
rename	M	year_2001
rename	N	year_2002
rename	O	year_2003
rename	P	year_2004
rename	Q	year_2005
rename	R	year_2006
rename	S	year_2007
rename	T	year_2008
rename	U	year_2009
rename	V	year_2010
rename	W	year_2011
rename	X	year_2012
rename	Y	year_2013
rename	Z	year_2014
rename	AA	year_2015
rename	AB	year_2016
rename	AC	year_2017
rename	AD	year_2018

destring year_*, replace force

/*
Perform reshape into panel data

Replace text entries with standard missing entries in stata formatting

Harmonize labeling for append
*/

reshape long year_,i(Country) j(year)
rename year_ trade_adjustment
replace trade_adjustment = trade_adjustment/1000
label var trade_adjustment "trade adjustment for electricity factor: kg CO2/kilowatt hour"
replace trade_adjustment =0 if trade_adjustment==.
gen energy_enduse_sector = "Trade Adjustment"


//save trade factors dataset out
save "$tempDir/trade_adjustment.dta", replace



/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Step 5: Append the electricity-only factors and the direct-combustion factors together. This will allow for creating the two sets of outcome variables of interest for the panel.

The thing is the data we have will yield *three* different emissions intensities for fuels:



	1 -- by primary fuel definitions in the IEA (i.e., coal, gas, wind, biofuels etc) for elect.
	
	2 -- by primary fuel for elect and heat combined
	
	3 -- by primary fuel for all combustion outside of heat/power
	
	
	

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/


use "$tempDir/electricity_factors.dta", clear

append using "$tempDir/outside_use_factors.dta"
append using "$tempDir/heatpower_factors.dta"
 

/*
Module to drop regional aggregates (drop countries that aren't countries)

*/
drop if Country=="Africa"
drop if Country=="Annex B Countries (Kyoto Protocol)"
drop if Country=="Annex I Countries (UNFCCC)"
drop if Country=="Annex I EIT (UNFCCC)"
drop if Country=="Annex II Asia Oceania (UNFCCC)"
drop if Country=="Annex II Countries (UNFCCC)"
drop if Country=="Annex II Europe (UNFCCC)"
drop if Country=="Annex II North America (UNFCCC)"
drop if Country=="Memo: ASEAN"
drop if Country=="Memo: Americas (UN)"
drop if Country=="Memo: Asia (UN)"
drop if Country=="Memo: Europe (UN)"
drop if Country=="Memo: European Union - 27"
drop if Country=="Memo: European Union - 28"
drop if Country=="Memo: G20"
drop if Country=="Memo: G7"
drop if Country=="Memo: G8"
drop if Country=="Memo: IEA Total"
drop if Country=="Memo: IEA and Accession/Association c.."
drop if Country=="Memo: OPEC"
drop if Country=="Middle East"
drop if Country=="Non-OECD Americas"
drop if Country=="Non-OECD Asia (excluding China)"
drop if Country=="Non-OECD Europe and Eurasia"
drop if Country=="Non-OECD Total"
drop if Country=="Non-annex I Countries (UNFCCC)"
drop if Country=="World"
drop if Country=="OECD Americas"
drop if Country=="OECD Asia Oceania"
drop if Country=="OECD Europe"
drop if Country=="OECD Total"


//keep units visible for emissions factors
gen emissions_factor_units = "kg CO2/kilowatt hour"
replace emissions_factor_units = "kg CO2/kg fuel" if energy_enduse_sector=="Sectors Outside Electricity and Heat"


save "$tempDir/IEA_AllFactors_Panel.dta", replace


/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Step 4.1: Generate a dataset for country-year pairs that establishes the emissions intensity of heat generation using the CHP data here as well as electricity-only generation.

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/

use "$tempDir/IEA_AllFactors_Panel.dta", clear

//keep only CHP entries
keep if energy_enduse_sector =="Combined Heat and Power"

//keep only aggregates
keep if Product=="Total"

//replace product with "heat" label to merge into electricity generation panel as an emissions factor for heat use.
replace Product = "HEAT"


save "$tempDir/IEA_Heat_Factors.dta", replace


/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Step 5.2: Generate a dataset for country-year pairs that solely contains the electricity emissions factors

and then an analagous dataset with adjustment factors

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/

use "$tempDir/electricity_factors.dta", clear

//keep only countries
drop if Country=="Africa"
drop if Country=="Annex B Countries (Kyoto Protocol)"
drop if Country=="Annex I Countries (UNFCCC)"
drop if Country=="Annex I EIT (UNFCCC)"
drop if Country=="Annex II Asia Oceania (UNFCCC)"
drop if Country=="Annex II Countries (UNFCCC)"
drop if Country=="Annex II Europe (UNFCCC)"
drop if Country=="Annex II North America (UNFCCC)"
drop if Country=="Memo: ASEAN"
drop if Country=="Memo: Americas (UN)"
drop if Country=="Memo: Asia (UN)"
drop if Country=="Memo: Europe (UN)"
drop if Country=="Memo: European Union - 27"
drop if Country=="Memo: European Union - 28"
drop if Country=="Memo: G20"
drop if Country=="Memo: G7"
drop if Country=="Memo: G8"
drop if Country=="Memo: IEA Total"
drop if Country=="Memo: IEA and Accession/Association c.."
drop if Country=="Memo: OPEC"
drop if Country=="Middle East"
drop if Country=="Non-OECD Americas"
drop if Country=="Non-OECD Asia (excluding China)"
drop if Country=="Non-OECD Europe and Eurasia"
drop if Country=="Non-OECD Total"
drop if Country=="Non-annex I Countries (UNFCCC)"
drop if Country=="World"
drop if Country=="OECD Americas"
drop if Country=="OECD Asia Oceania"
drop if Country=="OECD Europe"
drop if Country=="OECD Total"

//keep only aggregates
keep if Product=="Total"

replace Country = strlower(Country)
save "$processedDir/IEA_Electric_Factors.dta", replace

/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Generate a dataset for country-year adjustment factors for trade

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/


use "$tempDir/trade_adjustment.dta", clear

//keep only countries
drop if Country=="Africa"
drop if Country=="Annex B Countries (Kyoto Protocol)"
drop if Country=="Annex I Countries (UNFCCC)"
drop if Country=="Annex I EIT (UNFCCC)"
drop if Country=="Annex II Asia Oceania (UNFCCC)"
drop if Country=="Annex II Countries (UNFCCC)"
drop if Country=="Annex II Europe (UNFCCC)"
drop if Country=="Annex II North America (UNFCCC)"
drop if Country=="Memo: ASEAN"
drop if Country=="Memo: Americas (UN)"
drop if Country=="Memo: Asia (UN)"
drop if Country=="Memo: Europe (UN)"
drop if Country=="Memo: European Union - 27"
drop if Country=="Memo: European Union - 28"
drop if Country=="Memo: G20"
drop if Country=="Memo: G7"
drop if Country=="Memo: G8"
drop if Country=="Memo: IEA Total"
drop if Country=="Memo: IEA and Accession/Association c.."
drop if Country=="Memo: OPEC"
drop if Country=="Middle East"
drop if Country=="Non-OECD Americas"
drop if Country=="Non-OECD Asia (excluding China)"
drop if Country=="Non-OECD Europe and Eurasia"
drop if Country=="Non-OECD Total"
drop if Country=="Non-annex I Countries (UNFCCC)"
drop if Country=="World"
drop if Country=="OECD Americas"
drop if Country=="OECD Asia Oceania"
drop if Country=="OECD Europe"
drop if Country=="OECD Total"


replace Country = strlower(Country)
save "$processedDir/IEA_Elect_Trade_Adjustment.dta", replace

/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Step 5.3: Generate a dataset for country-year pairs that solely contains the CHP emissions factors

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/

use "$tempDir/heatpower_factors.dta", clear

//keep only aggregates
keep if Product=="Total"


save "$processedDir/IEA_CHP_Factors.dta", replace

/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Step 5.4: Generate a dataset for country-year pairs that contains emissions factors for all products.

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/


use  "$tempDir/outside_use_factors.dta", clear

save "$processedDir/IEA_non_energy_use_Factors.dta", replace




/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

Step 6: Check emissions factor coverage for individual products in non-energy use vs. ideal panel coverage

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/

use  "$tempDir/outside_use_factors.dta", clear

 

/*
Module to drop regional aggregates (drop countries that aren't countries)

*/
drop if Country=="Africa"
drop if Country=="Annex B Countries (Kyoto Protocol)"
drop if Country=="Annex I Countries (UNFCCC)"
drop if Country=="Annex I EIT (UNFCCC)"
drop if Country=="Annex II Asia Oceania (UNFCCC)"
drop if Country=="Annex II Countries (UNFCCC)"
drop if Country=="Annex II Europe (UNFCCC)"
drop if Country=="Annex II North America (UNFCCC)"
drop if Country=="Memo: ASEAN"
drop if Country=="Memo: Americas (UN)"
drop if Country=="Memo: Asia (UN)"
drop if Country=="Memo: Europe (UN)"
drop if Country=="Memo: European Union - 27"
drop if Country=="Memo: European Union - 28"
drop if Country=="Memo: G20"
drop if Country=="Memo: G7"
drop if Country=="Memo: G8"
drop if Country=="Memo: IEA Total"
drop if Country=="Memo: IEA and Accession/Association c.."
drop if Country=="Memo: OPEC"
drop if Country=="Middle East"
drop if Country=="Non-OECD Americas"
drop if Country=="Non-OECD Asia (excluding China)"
drop if Country=="Non-OECD Europe and Eurasia"
drop if Country=="Non-OECD Total"
drop if Country=="Non-annex I Countries (UNFCCC)"
drop if Country=="World"
drop if Country=="OECD Americas"
drop if Country=="OECD Asia Oceania"
drop if Country=="OECD Europe"
drop if Country=="OECD Total"


count
//147,870


count if emissions_factor!=.
//43,143

count if emissions_factor==0
//0



gen missing_factor_flag = (emissions_factor==.)

preserve
collapse missing_factor_flag, by (year)

twoway line missing_factor_flag year if year<2019


restore

//graph of range for motor gasoline
preserve
keep if Product=="Motor gasoline excl bio"
bysort year: egen gas_5 =  pctile(emissions_factor), p(5)
bysort year: egen gas_mean =  mean(emissions_factor)
bysort year: egen gas_95 =  pctile(emissions_factor), p(95)

twoway line gas_5 year || line gas_mean year || line gas_95 year 

restore


//graph of range for anthracite
preserve
keep if Product=="Anthracite"
bysort year: egen factor_min =  min(emissions_factor)
bysort year: egen factor_mean =  mean(emissions_factor)
bysort year: egen factor_max =  max(emissions_factor)

twoway line factor_min year || line factor_mean year || line factor_max year 

restore




//graph of range for lignite
preserve
keep if Product=="Lignite"
bysort year: egen lignite_min =  min(emissions_factor)
bysort year: egen lignite_mean =  mean(emissions_factor)
bysort year: egen lignite_max =  max(emissions_factor)

twoway line lignite_min year || line lignite_mean year || line lignite_max year 

restore

