# Alexander C Abajian, Tamma Carleton, Kyle Meng, and Olivier Deschenes
Read me file accompanying “The Climate Adaptation Feedback” GitHub Scripts 
6/10/2024



## Requirements

All programs run in the following versions of these applications:

Stata: Stata/SE 18.0 for Mac (Apple Silicon)
R: RStudio 2022.12.0+353 
Python: Python 3.11.1 64bit for Mac
Matlab: R2022b

Running the R scripts requires the following:

tidyverse=2.0.0
haven=2.5.2
readxl=1.4.2
broom=1.0.4
sf=1.0-12
rnaturalearthdata=1.0.0
rnaturalearth=1.0.1
cowplot=1.1.1
scales=1.2.1
biscale=1.0.0
dichromat=2.0-0.1
geosphere=1.5-18


# Description of Scripts to Replicate our Analysis


To run the Stata scripts that are not related to processing the proprietary IEA data, one must set their root directory to be the folder containing our Zenodo repository for the paper. All other macros should then be internally consistent.

Stata scripts related to processing the IEA data are present and may be reviewed, but will ultimately not run without access to the IEA’s world energy balances and emissions databases.

To run the python, Matlab, or R scripts, more directory manipulation may be needed depending on how a replicator has configured their environment.  In principle both should also run out of a correct configuration which sets the Zenodo folder as a root directory.

The replication scripts are separated into two folders (as suggested above): IEA Data Processing and CAF Scripts Final. They (respectively) contain the scripts which process data from the IEA to form emissions factors (section 5.2 equation 5) and run our analysis of how energy demand feeds back into climate change. 

The Stata scripts all contain numerical prefixes. These prefixes roughly denote the section of the analysis they are associated with. Note that not all files in our GitHub repository are used in generating the analysis for the main text — those that are marked “used” are used in the manuscript. Others are used to create portions of the supplementary information file or were used in the peer-review process

### Section 0 — Data Processing: Files in this section read in and process all raw data we use in various portions of the paper.



#### used
0_Emissions_Factors_dofile — solve for country-level fuel-specific average emissions factors between 2010-2018 through the process outlined in section 5.2 of the manuscript.
0_Factors_Quantities_Merge — merge fuel-specific factors and quantities each country consumes to form weighted averages (equation 5 in section 5.2)
0_National_emissions_shares_2019_Minx_GHG — load in country-level time series for emissions
0_Read_IR_Populations — load impact-region level populations from Rode et al 2021
0_Read_ISO3_Populations — load ISO3 (country) level populations from Rode et al 2021
0_Read_rode_data_uncertainty — Read in scenario level point estimates and 5-95 CIs from Rode et al for adaptive energy use under each SSP-RCP scenario we consider. This effectively fetches each element of equation (2) in the methods section we need to construct the CAF.

#### unused
0_Read_rode_data_uncertainty_Decay — reformulate `0_Read_rode_data_uncertainty’ above with global decay rates for emissions factors
0_Read_rode_data_uncertainty_Decay_country_level — reformulate `0_Read_rode_data_uncertainty’ with country-level decay rates for emissions factors
0_Check_otherfuels_emissions_factors — examine the degree to which outliers/other data issues are affecting our factor values (see SI)
0_Check_Global_Factors — solve for global factors (see SI)
0_Global_Factor_Trends — solve for trends in global emissions factors used for sensitivity analysis (see SI)
0_Local_Factor_Trends — local trends in factors 
0_Read_rode_data_no_adapt.m — Matlab script for reading in series with no adaptation (see SI)
0_Read_rode_data_no_adapt — alternative time series for energy demand where interacted ``extensive” adaptation margin is shut down (see SI)


### Section 1 —  Solve for Our Modified Analogue of the TCRE that measures how historical carbon emissions have translated to changes in GMST

#### used
1_TCRE_analogue.do — Solves for our beta on changes in cumulative carbon emissions. This performs the procedure in Methods Section 5.3 by estimating equation 6.

### Section 2

####  used
2_CAF_Calculation — solves for our central CAF estimates in the manuscript. Evaluates equations 3 and 4 in the methods section 5.1 given inputs as constructed above.
2_CAF_Decomp — decomposes CAF between the contributions by each fuel type to inform the graphics in Figure 3.

#### unused
2_CAF_Calculation_Decay — solves for the CAF with global decay rates for each emissions factor
2_CAF_Calculation_Decay_Country_Level— solves for the CAF with local decay rates for each emissions factor
2_CAF_Calculation_Decay_Country_Level_Monte_Carlo — sensitivity analysis for emissions factors
2_CAF_Calculation_noadapt — Solves for CAF when extensive margin for adaptation is excluded (see SI)

### Section 3

#### used
3_NDC_gaps — Solves for the NDC gaps we reference in text as described in the "Baseline country-level emissions and Nationally Determined Contributions” paragraph of 5.2.
3_Covariates_for_NDCgaps — Solves for country-level covariates at various horizons to use to inform the NDC gap analysis
3_Covariates_for_NDCgaps_alt — Repeats the exercise above by fuel.

### Section 4

#### used
CAF_avoided_damages — solves for NPV of damages avoided through 2099 under all SSP-RCP scenarios

### Figures

#### used
Fig1_schematic — Figure 1
figure2_cumulative_emissions — Figure 2: Cumulative Emissions Time Series
figure2_intensity_maps —Figure 2:  Maps of emissions intensities
figure2_TCRE —Figure 2:  historical TCRE- analogue figure graphically showing results from Methods 5.3
figure3 — Figure 3: 
figure4 — Figure 4


//not used
figure4_alt (SI Section 1)
figure4_LOO (SI section 5)


### Appendix

Appendix_dynamic_CAF_makeIRFS — Solves for the impulse responses at the country-level by implementing equations 8 and 9 from methods section 5.4
Appendix_dynamic_CAF — aggregates them globally and resolves the dynamic CAF.


# Data Descriptions