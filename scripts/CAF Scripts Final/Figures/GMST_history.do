* Calculate CAF in terms of number of recent years of warming

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

//from here: https://data.giss.nasa.gov/gistemp/graphs_v4/

insheet using $raw/GMST_GISS.csv, comma names clear

rename no_smoothing GMST

reg GMST year if year>=1980 & year<=2019

display .12/_b[year]
//6.3969595

