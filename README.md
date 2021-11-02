# Why do people persist in sea-level rise threatened coastal regions? Empirical evidence on risk aversion and place attachment
This repository provides the data and analysis files to reproduce the results of the paper "Why do people persist in sea-level rise threatened coastal regions? Empirical evidence on risk aversion and place attachment" forthcoming in Climate Risk Management.

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5638671.svg)](https://doi.org/10.5281/zenodo.5638671)

__Authors:__ Ivo Steimanis<sup>1</sup>, Matthias Mayer<sup>1</sup> & Björn Vollan<sup>1</sup>,* <br>
__Affiliations:__ <sup>1</sup> Department of Economics, Philipps University Marburg, 35032 Marburg, Germany <br>
__ORCID:__  Steimanis: 0000-0002-8550-4675; Mayer: 0000-0003-0323-9124; Vollan: 0000-0002-5592-4185 <br>
__Classification:__ Social Sciences, Economic Sciences <br>
__Keywords:__ climate hazards, risk aversion, place attachment, international migration aspiration, societal resilience, trapped population <br>


## Abstract
Climate change is projected to increase the number of extreme weather events, which may lead to cascading impacts, feedbacks, and tipping points not only in the biophysical system but also in the social system. To better understand societal resilience in risky environments, we analyzed people’s attachment to place, their willingness to take risks, and how these change in response to extreme weather events. We conducted a survey with 624 respondents at the forefront of climate change in Asia: the river deltas in Bangladesh and Vietnam. Our findings confirm that most people prefer staying. Yet crucially, we find that (i) self-reported experiences of climate-related hazards are associated with increased risk aversion and place attachment, reinforcing people’s preferences to stay in hazardous environments; (ii) people with experiences of hazards are more likely aspiring to move to high-income destinations, arguably being beyond the reach of their capacities; and (iii) changes in aspirations to move abroad are connected to the changes in risk aversion and place attachment. The fact that preferences are associated with cumulative experiences of hazards and interact with aspirations to move to high-income destinations may contribute to our understanding of why so many people stay in hazardous environments.

# Steps to replicate the tables and figures 
## General information:
- Instructions for replication of the results using Stata. All do-files were created in Stata 16.
- There are 4 subfolders (DO-FILES, DTA-FILES, OUTPUT, XLS-FILES) in the replication_package folders. Copy these folders to your local computers and continue with the next step.

## Do-files:
- In the DO-FILES folder run the __“00_master.do”__ to replicate the results reported in the main manuscript and the supplementary materials. The results will be saved in the OUTPUT folder. All additional Stata packages will be automatically installed.
- __“01_merge_generate.do”__ merges the different datasets and creates additional variables using in the analysis
- __“02_analysis.do”__ provides the code to replicate all figures and tables reported in the main manuscript and supplementary materials

## Data sets:
-	“bd_combine.dta”: cleaned survey data from Bangladesh
-	“vn_combine.dta”: cleaned survey data from Vietnam
- “data_analysis.dta”: main data set with the survey data from Bangladesh and Vietnam merged


