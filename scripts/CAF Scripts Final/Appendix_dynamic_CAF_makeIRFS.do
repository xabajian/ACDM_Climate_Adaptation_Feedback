/*%%%%%%%%%%%%%%%%%%%%%%  HEADER %%%%%%%%%%%%%%%%%%%%%%*/

		clear all
		set more off
		set trace off
		set tracedepth 2
		set maxvar 32000
		
		

/*

This script generates the country-year impulse response functions by fuel and for both fuels combined. 

That is, for each country-model-ssp-GCM time series, run the equivalent of

	reg damages_emissions temp temp2 if  year==2050 & ISO3=="CHN" & fuel=="other_energy", noconstant r

	In each year. this gives one set of coefficients for the quadratic impulse response functions (d Emissions/DT) for each country and each year
	
	
	
The first portion does this process for both fuels combined; we then do the two fuels separately. 

*/



/*

!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$
!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$
!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$
!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$


		Part 1 - Make IRF coefficients at country elvel

!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$
!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$
!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$
!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$
!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$!@$#%$#!@#!$#@!$

*/

clear all


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


//create estimation sample from ful panel
use "$processed/full_panel.dta", clear
keep if rcp=="rcp85" & ssp=="SSP2"
save "$processed/full_panel_rcp85ssp2.dta", replace


use "$processed/full_panel_rcp85ssp2.dta", clear


****RCPs
global rcp_list = "rcp85"
****Fuels
global fuel_list = "other_energy electricity"
****SSP
global ssp_list = "SSP2"
****ISO codes
global country_list  = "AGO 	 ALB 	 ARE 	 ARG 	 ARM 	 AUS 	 AUT 	 AZE 	 BEL 	 BEN 	 BFA 	 BGD 	 BGR 	 BHR 	 BIH 	 BLR 	 BOL 	 BRA 	 BRN 	 BWA 	 CAN 	 CHE 	 CHL 	 CHN 	 CIV 	 CMR 	 COL 	 CRI 	 CUB 	 CYP 	 CZE 	 DEU 	 DNK 	 DOM 	 DZA 	 ECU 	 EGY 	 ERI 	 ESP 	 EST 	 ETH 	 FIN 	 FRA 	 GAB 	 GBR 	 GEO 	 GHA 	 GNQ 	 GRC 	 GRL 	 GTM 	 HKG 	 HND 	 HRV 	 HTI 	 HUN 	 IDN 	 IND 	 IRL 	 IRN 	 IRQ 	 ISL 	 ISR 	 ITA 	 JAM 	 JOR 	 JPN 	 KAZ 	 KEN 	 KGZ 	 KHM 	 KOR 	 KWT 	 LAO 	 LBN 	 LBY 	 LKA 	 LTU 	 LUX 	 LVA 	 MAR 	 MDA 	 MDG 	 MEX 	 MKD 	 MLI 	 MLT 	 MMR 	 MNE 	 MNG 	 MOZ 	 MRT 	 MUS 	 MYS 	 NAM 	 NER 	 NGA 	 NIC 	 NLD 	 NOR 	 NPL 	 NZL 	 OMN 	 PAK 	 PAN 	 PER 	 PHL 	 POL 	 PRT 	 PRY 	 QAT 	 ROU 	 RUS 	 SAU 	 SDN 	 SEN 	 SGP 	 SLV 	 SRB 	 SSD 	 SUR 	 SVK 	 SVN 	 SWE 	 SYR 	 TCD 	 TGO 	 THA 	 TJK 	 TKM 	 TTO 	 TUN 	 TUR 	 TWN 	 TZA 	 UGA 	 UKR 	 URY 	 USA 	 UZB 	 VEN 	 VNM 	 YEM 	 ZAF 	 ZMB 	 ZWE"



/*
%%%%%%%%%%%%%%%%%%%%%%
LOOP BLOCK
%%%%%%%%%%%%%%%%%%%%%%


/*
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
Create aggregate impulse responses of emissions to changes in temperature for the globe evaluated at different horizons.

These are the sum across all countries, for each fuel, of coefficients on emissions response to temperature level
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
*/
*/

//set error count
scalar error_count = 0
/*
%%%%%%%%%%%%%%%%%%%%%%
Preallocate matrices
%%%%%%%%%%%%%%%%%%%%%%
*/

matrix beta_1_mat_other  = [.]
matrix beta_2_mat_other = [.]
matrix beta_1_mat_elec  = [.]
matrix beta_2_mat_elec = [.]


//loop RCP
foreach rcp_type of global rcp_list {
	//loopSSP
	foreach ssp_type of global ssp_list {
		//loop year/horizon
		forvalues year_loop = 2020/2099 {
				
				
					scalar beta_1_elec = 0
					scalar beta_2_elec = 0
					scalar beta_1_other = 0
					scalar beta_2_other = 0
					
				//loop over countries in year to solve for the world aggregate emissions impulse
				
				
				foreach country of global country_list {
					capture{

						
					/*
					perform quadratic regression for given country, year, fuel, ssp, and rcp
					over the results of the GCMs and high/low combos.
					
					For each year, sum all coefficients across all countries on T and T^2, by fuel
					*/
					
			
					//short version for rcp85 and ssp2
					reg damages_emissions temp temp2 if ISO3=="`country'" & year==`year_loop' & fuel=="electricity", noconstant r
					scalar beta_1_elec = beta_1_elec + _b[temp]
					scalar beta_2_elec = beta_2_elec + _b[temp2]
					
					reg damages_emissions temp temp2 if ISO3=="`country'" & year==`year_loop' & fuel=="other_energy", noconstant r
					scalar beta_1_other = beta_1_other + _b[temp]
					scalar beta_2_other = beta_2_other + _b[temp2]
			
		
				}
					//Count errors in loop
						if _rc!=0 {
						
						scalar error_count = error_count+1
						
						display error_count
						}
					
				
				}
					
						//display _rc 
			
			
						
				//append this years' coefficient to the coefficient matrix
				matrix beta_1_mat_other  =  beta_1_mat_other  \ beta_1_other
				matrix beta_2_mat_other =  beta_2_mat_other  \ beta_2_other
				matrix beta_1_mat_elec  =  beta_1_mat_elec  \ beta_1_elec
				matrix beta_2_mat_elec =  beta_2_mat_elec  \ beta_2_elec

				}
			}
		}

//pull in coefficient series
svmat beta_1_mat_other
svmat beta_2_mat_other
svmat beta_1_mat_elec
svmat beta_2_mat_elec


//index coefficients to the year they correspond to
gen index=_n
gen year_index = index+2018

//keep variables of interest and save out
keep beta_1_mat_other beta_2_mat_other beta_1_mat_elec beta_2_mat_elec year_index
drop if beta_1_mat_other1==.
rename year_index year

save "$objects/aggregate_IRF_coefficients_rcp8ssp2.dta", replace

