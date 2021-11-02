*** Master do-file for "Why do people persist in sea-level rise threatened coastal regions? Empirical evidence on risk aversion and place attachment"

*--------------------------------------------------
* Description
*--------------------------------------------------
*** This file sets globals, directories, installs programs
* creates additioanl variables and runs the analysis do-files

*--------------------------------------------------



*--------------------------------------------------
* Program Setup
*--------------------------------------------------
version 16              // Set Version number for backward compatibility
clear all               
set more off            
set linesize 80         
macro drop _all        
set matsize 2000
* -------------------------------------------------


*--------------------------------------------------
* Directory
*--------------------------------------------------
global workpath	"YOURPATH+ \OUTPUT"
global datapath	"YOURPATH+ \DTA-FILES"
global output	"YOURPATH+ \OUTPUT"
* replace with the path you saved the downloaded folder

*--------------------------------------------------

*--------------------------------------------------
* Directory
*--------------------------------------------------
global workpath	"C:\Users\istei\Google Drive\Promotion\2_Paper Drafts\Risk and Place Attachment\Submission\06_Climate Risk Management\replication_package\OUTPUT"
global datapath	"C:\Users\istei\Google Drive\Promotion\2_Paper Drafts\Risk and Place Attachment\Submission\06_Climate Risk Management\replication_package\DTA-FILES"
global output	"C:\Users\istei\Google Drive\Promotion\2_Paper Drafts\Risk and Place Attachment\Submission\06_Climate Risk Management\replication_package\OUTPUT"
global xls	"C:\Users\istei\Google Drive\Promotion\2_Paper Drafts\Risk and Place Attachment\Submission\06_Climate Risk Management\replication_package\XLS-FILES"
* please replace with the path you saved the downloaded folder
*------

** Install programs
*capture: ssc install estout
*capture: ssc install coefplot


** Run generate do-file
do "01_merge_generate.do" 


** Run analysis do-file
do "02_analysis.do" 

