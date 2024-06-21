# Abajian, Carleton, Meng, and Deschenes (ACMD 2024)

Read me file accompanying the scripts required to replicate findings in the main text and supplementary information for “The Climate Adaptation Feedback” (ACMD 2024).

Replication files for the peer review responses are available from xander.abajian@gmail.com on request.

## Setup

Scripts in this repository are written in a combination of Stata and R. Throughout this document, it is assumed that the replicator operates from a working directory containing all the necessary files and folders detailed in the structure below. Most importantly, a replicator must download the associated data repository from Zenodo at [https://doi.org/10.5281/zenodo.10476310.](https://doi.org/10.5281/zenodo.10476310). To run the Stata scripts, this folder should be set as the root directory and the global macro $root should correspond to the folder containing all files in "ACDM_Data". (IE,  global root "{~/ACDM_Data}" needs to be run).

## Requirements

All programs are run in the following versions of these applications:

* Stata: Stata/SE 18.5 for Mac 
* R: R version 4.2.3

and were executed on Mac OS 14.5 (Sonoma -- 23F79). Programs must be run in the order in which they appear in the directory. Running all files associated with the main manuscript takes 5-10 minutes in total on an average laptop. Running the dynamic CAF exercise in the appendix (which generates the impulse response functions) takes a bit longer depending on the computer you're running as it runs quite a few regressions. Running the Monte Carlo simulations and other exercises for the peer review process might take overnight.

Running the Stata scripts requires

* CROSSFOLD
* GTOOLS
* PALETTES
* REGHDFE
* FTOOLS
* SHP2DTA
* SPMAP 

Running the R scripts may require that the following packages are installed:

* tidyverse=2.0.0
* haven=2.5.2
* readxl=1.4.2
* broom=1.0.4
* sf=1.0-12
* rnaturalearthdata=1.0.0
* rnaturalearth=1.0.1
* cowplot=1.1.1
* scales=1.2.1
* biscale=1.0.0
* dichromat=2.0-0.1
* geosphere=1.5-18

# File Tree 

```bash
└── scripts
    ├── CAF Scripts Final
    │   ├── 0_National_emissions_shares_2019_Minx_GHG.do
    │   ├── 0_Read_IR_Populations.do
    │   ├── 0_Read_ISO3_Populations.do
    │   ├── 0_Read_rode_data_noadapt.do
    │   ├── 0_Read_rode_data_uncertainty.do
    │   ├── 0_Read_rode_data_uncertainty_Decay.do
    │   ├── 0_Read_rode_data_uncertainty_Decay_country_level.do
    │   ├── 1_TCRE_analogue.do
    │   ├── 2_CAF_Calculation.do
    │   ├── 2_CAF_Calculation_Decay.do
    │   ├── 2_CAF_Calculation_Decay_Country_Level.do
    │   ├── 2_CAF_Calculation_Decay_Country_Level_Monte_Carlo.do
    │   ├── 2_CAF_Calculation_noadapt.do
    │   ├── 2_CAF_Decomp.do
    │   ├── 3_Covariates_for_NDCgaps.do
    │   ├── 3_Covariates_for_NDCgaps_alt.do
    │   ├── 3_NDC_gaps.do
    │   ├── 4_CAF Damages
    │   │   ├── CAF_avoided_damages.do
    │   │   ├── integration_damage_function_coefficients.csv
    │   │   └── ssp2_growth.csv
    │   ├── Appendix_dynamic_CAF.do
    │   ├── Appendix_dynamic_CAF_makeIRFS.do
    │   ├── Figures
    │   │   ├── Fig1_schematic
    │   │   │   └── CAF_components.R
    │   │   ├── GMST_history.do
    │   │   ├── combined_3.gph
    │   │   ├── figure2_TCRE.do
    │   │   ├── figure2_cumulative_emissions.do
    │   │   ├── figure2_intensity_maps.do
    │   │   ├── figure3.do
    │   │   ├── figure4.do
    │   │   ├── figure4_LOO.do
    │   │   └── figure4_alt.do
    │   └── Robustness_coverage_checking.do
    └── IEA Data Processing
        ├── 0_Check_Global_Factors.do
        ├── 0_Check_otherfuels_emissions_factors.do
        ├── 0_Emissions_Factors_dofile.do
        ├── 0_Factors_Quantities_Merge.do
        ├── 0_Global_Factor_Trends.do
        ├── 0_Local_Factor_Trends.do
        ├── 0_product_name_crosswalks.xlsx
        ├── factor_maps.R
        └── factor_maps_imputed.R

```


# Description of Scripts to Replicate our Analysis


To run the Stata scripts that are not related to processing the proprietary IEA data, one must set their root directory to be the folder containing our Zenodo repository for the paper. All other macros should then be internally consistent.

Stata scripts related to processing the IEA data are present and may be reviewed, but will ultimately not run without access to the IEA’s world energy balances and emissions databases.

To run the R scripts, more directory manipulation may be needed depending on how a replicator has configured their environment.  In principle both should also run out of a correct configuration which sets the Zenodo folder as a root directory.

The replication scripts are separated into two folders (as suggested above): IEA Data Processing and CAF Scripts Final. They (respectively) contain the scripts which process data from the IEA to form emissions factors (section 5.2 equation 5) and run our analysis of how energy demand feeds back into climate change. 

The Stata scripts all contain numerical prefixes. These prefixes roughly denote the section of the analysis they are associated with. Note that not all files in our GitHub repository are used in generating the analysis for the main text — those that are marked “used” are used in the manuscript. Others are used to create portions of the supplementary information file or were used in the peer-review process

## Section 0 — Data Processing: Files in this section read in and process all raw data we use in various portions of the paper.



#### used
- `0_Emissions_Factors_dofile` — solve for country-level fuel-specific average emissions factors between 2010-2018 through the process outlined in section 5.2 of the manuscript.
- `0_Factors_Quantities_Merge` — merge fuel-specific factors and quantities each country consumes to form weighted averages (equation 5 in section 5.2)
- `0_National_emissions_shares_2019_Minx_GHG` — load in country-level time series for emissions
- `0_Read_IR_Populations` — load impact-region level populations from Rode et al 2021
- `0_Read_ISO3_Populations` — load ISO3 (country) level populations from Rode et al 2021
- `0_Read_rode_data_uncertainty` — Read in scenario level point estimates and 5-95 CIs from Rode et al for adaptive energy use under each SSP-RCP scenario we consider. This effectively fetches each element of equation (2) in the methods section we need to construct the CAF.

#### unused
- `0_Read_rode_data_uncertainty_Decay` — reformulate `0_Read_rode_data_uncertainty’ above with global decay rates for emissions factors
- `0_Read_rode_data_uncertainty_Decay_country_level` — reformulate `0_Read_rode_data_uncertainty’ with country-level decay rates for emissions factors
- `0_Check_otherfuels_emissions_factors` — examine the degree to which outliers/other data issues are affecting our factor values (see SI)
- `0_Check_Global_Factors` — solve for global factors (see SI)
- `0_Global_Factor_Trends` — solve for trends in global emissions factors used for sensitivity analysis (see SI)
- `0_Local_Factor_Trends` — local trends in factors 
- `0_Read_rode_data_no_adapt.m` — Matlab script for reading in series with no adaptation (see SI)
- `0_Read_rode_data_no_adapt` — alternative time series for energy demand where interacted ``extensive” adaptation margin is shut down (see SI)


## Section 1 —  Solve for Our Modified Analogue of the TCRE that measures how historical carbon emissions have translated to changes in GMST

#### used
- `1_TCRE_analogue.do` — Solves for our beta on changes in cumulative carbon emissions. This performs the procedure in Methods Section 5.3 by estimating equation 6.

## Section 2 - CAF calculations and sensitivity analysis

####  used
- `2_CAF_Calculation` — solves for our central CAF estimates in the manuscript. Evaluates equations 3 and 4 in the methods section 5.1 given inputs as constructed above.
- `2_CAF_Decomp` — decomposes CAF between the contributions by each fuel type to inform the graphics in Figure 3.

#### unused
- `2_CAF_Calculation_Decay` — solves for the CAF with global decay rates for each emissions factor
- `2_CAF_Calculation_Decay_Country_Level`— solves for the CAF with local decay rates for each emissions factor
- `2_CAF_Calculation_Decay_Country_Level_Monte_Carlo` — sensitivity analysis for emissions factors
- `2_CAF_Calculation_noadapt` — Solves for CAF when extensive margin for adaptation is excluded (see SI)

## Section 3 - CAF in the context of NDCs

#### used
- `3_NDC_gaps` — Solves for the NDC gaps we reference in text as described in the "Baseline country-level emissions and Nationally Determined Contributions” paragraph of 5.2.
- `3_Covariates_for_NDCgaps` — Solves for country-level covariates at various horizons to use to inform the NDC gap analysis
- `3_Covariates_for_NDCgaps_alt` — Repeats the exercise above by fuel.

## Section 4 - Solves for the monetized value of damages using outputs from the DSCIM model

#### used
- `CAF_avoided_damages` — Solves for NPV of damages avoided through 2099 under all SSP-RCP scenarios
- `integration_damage_function_coefficients` -- Damage funciton coefficients from the DSCIM model
- `ssp2_growth` -- GDP growth under SSP2

  
## Figures

#### used
- `Fig1_schematic` — Figure 1
- `figure2_cumulative_emissions` — Figure 2: Cumulative Emissions Time Series
- `figure2_intensity_maps` —Figure 2:  Maps of emissions intensities
- `figure2_TCRE` —Figure 2:  historical TCRE- analogue figure graphically showing results from Methods 5.3
- `figure3` — Figure 3: 
- `figure4` — Figure 4


#### not used
- `figure4_alt` (SI Section 1)
- `figure4_LOO` (SI section 5)


## Appendix

- `Appendix_dynamic_CAF_makeIRFS` — Solves for the impulse responses at the country-level by implementing equations 8 and 9 from methods section 5.4
- `Appendix_dynamic_CAF` — aggregates them globally and resolves the dynamic CAF.


# Data Description for the Data Repo



This is a brief description of the six folders contained in the Zenodo repository for the CAF paper. Each of these folders must exist for all code to run




##  Raw

Raw files used as inputs into calculating the CAF.

1. `RCPs`:  Datasets containing time series of GMST predictions from the GCMs used by Rode et al (2021) as well as time series of cumulative emissions under RCP 4.5 and 8.5 from the RCP Database (Version 2.0.4) at `http://www.iiasa.ac.at/web-apps/tnt/RcpDb `. 
2. `uncertainty_9_12`:  Projections of mean and 5-95 confidence intervals for country-level adaptive energy demand from Rode et al (2021).
3. `no_adapt`: Objects used to calculate the no extensive marign CAF in the appendix



## NDCs:

Contains raw data on nationally determined contributions and baseline emissions forecasts from [Meinhaussen et al. 2022] (https://doi.org/10.1038/s41586-022-04553-z) as well as conversions to STATA’s data format (.dta). The country-level data are taken from `https://zenodo.org/records/6383612`.


## Objects

Contains various intermediate inputs to the CAF that are not per-se processed but are not raw data files

- `essd_ghg_data` : Copernicus historical GHG emissions Data
- `rcp45_global` and `rcp85_global` : time series of cumulative emissions under RCP 4.5 and 8.5 from the RCP Database (Version 2.0.4) at `http://www.iiasa.ac.at/web-apps/tnt/RcpDb `. 

## Figures


Folder where all intermediate files and PDFs for figures in the manuscript and supplementary information sections of the paper are stored





## Temporary


Directory to store intermediate files


## Processed


Finished files that store the results from various procedures documented in the methods section (manuscript section 5) or the SI.



