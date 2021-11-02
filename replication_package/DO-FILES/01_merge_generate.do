*** Merge and generate do-file for "Why do people persist in sea-level rise threatened coastal regions? Empirical evidence on risk aversion and place attachment"

*--------------------------------------------------
* Description
*--------------------------------------------------
* (1) Merge Survey data and add elevation data
* (2) Clean and generate additional variables
* (3) Organize dataset: sort and keep relevant data only
*--------------------------------------------------




*---------------------
* 1) Merge Datasets
*---------------------

// COMBINE SURVEY DATA
use "$datapath\vn_combine.dta"
append using "$datapath\bd_combine.dta", force


// LOCATION IDENTIFIERS AND UNIQUE ID
label var country_id "Source of data"
label define country_l 2 "Bangladesh" 3 "Vietnam"
label values country_id country_l




*---------------------------------------
* 2) Cleaning and generating  variables
*---------------------------------------

*age groups
recode age min/30 = 0 31/40 = 1 41/50=2 51/60=3 61/max=4, gen(agegrp)
tab agegrp

*Preferences
replace risk = (risk-20000)*-1
*normalize preferences for comparability in figure
qui summ place_identity
gen place_identity_norm = (place_identity - r(min)) / (r(max) - r(min))
qui summ place_dependence
gen place_dependence_norm = (place_dependence - r(min)) / (r(max) - r(min))
lab var place_identity_norm "Place identity" 
lab var place_dependence_norm "Place dependence" 

*z-scores outcome variables: preferences 
egen z_identity = std(place_identity)
egen z_dependence = std(place_dependence)
egen z_risk2 =std(risk_aversion_norm)


//AFFECTEDNESS 
*extreme event identifier
bysort country_id: sum number_extremes, detail
gen t_extremes = 0 if number_extremes == 0
replace t_extremes = 1 if number_extremes == 1 |number_extremes == 2
replace t_extremes = 2 if number_extremes > 2
replace t_extremes = . if number_extremes == .
lab def extremes 0 "None" 1 "1 or 2" 2 "3 and more", replace
lab val t_extremes extremes
tab t_extreme, gen(extreme)

*binary identifier
gen exp_extreme = 1 if number_extremes > 0
replace exp_extreme = 0 if number_extremes == 0

* GENERATE EXOGENOUS NUMBER OF EXTREME EVENTS FOR EACH PARTICIPANT
*We generate a community average measure of exposure to climate hazards based on other participants' reports but not individual self-reports – therefore providing an exogenous measure of climate hazards within each village for each participant.
egen sum_extremes = sum(number_extremes), by(location)
egen count_extremes = count(number_extremes), by(location)
gen mean_extremes = (sum_extremes - number_extremes) / (count_extremes - 1)


* extreme evnent alternative specification based on village self-reported values (median)
egen village_extremes = median(number_extremes), by(location)
gen t_extreme2 = 0 if village_extremes==1
replace t_extreme2 = 1 if village_extremes==2
replace t_extreme2 = 2 if village_extremes>2

*rebuilding once house
replace rebuild_frequency = 0 if rebuild_frequency == -1
replace rebuild_frequency = 15 if rebuild_frequency > 15
replace rebuild_days=. if rebuild_days==-1

gen rebuild_house=.
replace rebuild_house=0 if rebuild_frequency==0
replace rebuild_house=1 if rebuild_frequency>0
replace rebuild_house=. if country_id==1
lab var rebuild_house "Respondent had to rebuild house at his current residence."
replace rebuild_costs = 0 if rebuild_house == 0
replace land_lost_value = 0 if land_lost == 0





* Taking the log of asset values and household incomes (+1 to account for reported 0s) to reduce variance in reported values
extremes income_hh, iqr sep(0)
extremes asset_sum, iqr sep(0)
extremes rebuild_costs, iqr sep(0)
extremes rebuild_days, iqr sep(0)

foreach x of varlist income_hh asset_sum rebuild_costs rebuild_days number_extremes {
	gen log_`x'= log(`x'+1)
	}

	
* winsorize variables with extreme outliers
foreach x of varlist income_hh asset_sum rebuild_costs rebuild_days number_extremes {
	winsor `x', p(.01) gen(`x'_w01) highonly
	}

	
* rebuild intensity index
global rebuild log_rebuild_costs log_rebuild_days rebuild_frequency
pwcorr $rebuild, sig
alpha $rebuild
pca $rebuild, comp(1)
predict pc1, score
estat kmo // kmo=0.63 -> okay
sum pc1
gen pca_rebuild_intensity=pc1



//Distance to nearest urban center (Ca Mau and Bac Lieu, or Barisal)
gen dest_lat_urban = 22.70041 if Orig_ID < 300 //Barisal for BD study sides
gen dest_long_urban = 90.37499 if Orig_ID < 300 //Barisal ID==207

replace dest_lat_urban = 9.290721 if Orig_ID == 306 | Orig_ID == 307 | Orig_ID == 308 | Orig_ID == 309 //Bac Lieu ID == 316
replace dest_long_urban = 105.7218 if Orig_ID == 306 | Orig_ID == 307 | Orig_ID == 308 | Orig_ID == 309 //Bac Lieu ID == 316

replace dest_lat_urban = 9.176185 if Orig_ID == 301 | Orig_ID == 302 | Orig_ID == 303 | Orig_ID == 304 | Orig_ID == 305 //Ca Mau ID == 325
replace dest_long_urban = 105.1508 if Orig_ID == 301 | Orig_ID == 302 | Orig_ID == 303 | Orig_ID == 304 | Orig_ID == 305 //Ca Mau ID == 325

geodist orig_lat orig_long dest_lat_urban dest_long_urban , gen(urban_distance)
lab var urban_distance "kilometers to closest urban center" //population > 100,000

*treatment identifier
gen treatment=1 if treatment_VN==1 | treatment_VN==2 | treatment_BD == 1
replace treatment = 0 if treatment_VN==0 | treatment_BD == 0
lab define treated1 0 "control" 1 "treated"
lab val treatment treated1
drop treatment_VN treatment_BD

*Identity extreme outliers in reported income data due to data entry problems
egen z_income = std(income_hh)
egen z_assets = std(asset_sum)
extremes income_hh, iqr sep(0)

*Create variable to detect extreme outliers that have an iqr above 1.5
gen income_hh_outlier = 0
replace income_hh_outlier = 1 if income_hh > 2647
replace income_hh_outlier = . if income_hh == .

*Identity extreme outliers in reported asset value data due to data entry problems
extremes asset_sum, iqr sep(0)

*Create variable to detect extreme outliers that have an iqr above 1.5
gen asset_sum_outlier = 0
replace asset_sum_outlier = 1 if asset_sum > 86277
replace asset_sum_outlier = . if asset_sum == .

*household size adjusted assets
gen asset_sum_adjusted_hh= asset_sum/people_hh
replace asset_sum_adjusted_hh=. if asset_sum==. & people_hh==.

* Interviewer dummies
replace assistant=. if country_id==1
replace assistant=8+assistant if country_id==3
replace assistant=. if assistant==18

* Considered adaptation strategies
egen n_adapt=rowtotal(sealevel1 sealevel2 sealevel3 sealevel4 sealevel5)
gen only_local=0
replace only_local=1 if n_adapt>0 & sealevel4==0

gen adapt1=0 if n_adapt==0
replace adapt1=1 if only_local==1
replace adapt1=2 if sealevel4==1 & n_adapt==1
replace adapt1=3 if n_adapt>1 & sealevel4==1

lab def l_adapt1 0 "Do nothing" 1 "Only local" 2 "Only Migration" 3 "Local & Migration", replace
lab val adapt1 l_adapt1
tab adapt1, gen(strat)
drop n_adapt


foreach v of varlist cc_resettle_within_area cc_resettle_different_area {
	replace `v'=. if `v'==99 | `v'==-1 
	}
egen relocate = rowtotal(cc_resettle_within_area cc_resettle_different_area)
gen cc_relocate = 1 if relocate > 0
replace cc_relocate = 0 if relocate == 0


// MIGRATION ASPIRATION / LIKELIHOOD RELATED
lab def aspiration1 0 "No Aspiration (n=227)" 1 "With aspiration (n=367)", replace
lab val migrate_abroad aspiration1

*Generate region identifier of named ma_country  based on the WorldBank
replace ma_country="No intention" if ma_country==""
replace ma_country="No intention" if ma_country=="No Answer"
replace ma_country="" if country_id==1

gen ma_region=.
replace ma_region=1 if ma_country=="USA" | ma_country=="Canada"
replace ma_region=2 if  ma_country=="Cyprus" | ma_country=="England" | ma_country=="European Country" | ma_country=="France" | ma_country=="Germany" | ma_country=="Italy" | ma_country=="Poland" | ma_country=="Spain" | ma_country=="Sweden"
replace ma_region=3 if ma_country=="India" | ma_country=="Pakistan"
replace ma_region=4 if  ma_country=="Brunei" |  ma_country=="Cambodia" |  ma_country=="China" |  ma_country=="Hongkong" | ma_country=="Japan" |  ma_country=="Lao" |  ma_country=="Malaysia" |  ma_country=="Singapore" |  ma_country=="Korea" |  ma_country=="Thailand" | ma_country=="Taiwan"
replace ma_region=5 if ma_country=="Australia"
replace ma_region=6 if ma_country=="Africa" | ma_country=="Bahrain" | ma_country=="Dubai" | ma_country=="Jordan" | ma_country=="Kuwait" | ma_country=="Katar" | ma_country=="Qatar"|  ma_country=="Lebanon" | ma_country=="Oman" | ma_country=="Saudi Arabia" | ma_country=="UAE"
replace ma_region=7 if ma_country=="Brazil"
replace ma_region=8 if ma_country=="No intention"
lab def region_lab 1 "North America" 2 "Europe" 3 "South Asia" 4 "East Asia" 5 "Australia" 6 "MENA" 7 "Latin America & Caribbean" 8 "No aspiration", replace
lab val ma_region region_lab

*generate region dummies:
tab ma_region, gen(ma_region)

* Emigration costs from Bangladesh Remittances Survey (2009): MENA = 199844 BDT; East Asian country = 228100 BDT; but South Kora / Singapore = 325000 BDT;  North America = 277834 BDT; Europe = 510000 (australia similar), SOuth Asia (india, pakistan)= nearly no costs (25000 for Pakistan)
gen actual_costs=278000 if ma_region==1
replace actual_costs=510000 if ma_region==2
replace actual_costs=25000 if ma_region==3
replace actual_costs=320000 if ma_region==4
replace actual_costs=510000 if ma_region==5
replace actual_costs=200000 if ma_region==6
replace actual_costs=300000 if ma_region==7
*no data on costs available for Vietnam, we assume the same costs as for Bangladesh

*adjust for inflation and PPP: 
* PPP conversion factor from World Bank, 2018: 34
*average inflation Bangladesh: 2009 - 2018 = 9 years = 9*5.6%=50% roughly cumulative inflation rate
gen ia_migration_costs = (actual_costs*1.5)/34

*Perceived individual affordability, householdsize adjusted
gen ma_afford_hhsize_adj=0 if mc_abroad > asset_sum_adjusted_hh
replace ma_afford_hhsize_adj=1 if mc_abroad < asset_sum_adjusted_hh
replace ma_afford_hhsize_adj=0 if migrate_abroad==1 & mc_abroad==.
replace ma_afford_hhsize_adj=. if migrate_abroad==0
lab def afford_lab 0 "Can't afford" 1 "Can afford", replace
lab val ma_afford_hhsize_adj afford_lab

*Average affordability by region
bysort ma_region: egen avg_mc_abroad = mean(mc_abroad)
gen avg_ma_afford = 0 if asset_sum_adjusted_hh < avg_mc_abroad
replace avg_ma_afford = 1 if asset_sum_adjusted_hh > avg_mc_abroad
replace avg_ma_afford=0 if migrate_abroad==1 & avg_mc_abroad==.
replace avg_ma_afford=. if migrate_abroad==0
lab val avg_ma_afford afford_lab

*estimated affordability based on actual labour migration costs
gen ma_afford_realistic = 0 if ia_migration_costs > asset_sum_adjusted_hh
replace ma_afford_realistic = 1 if ia_migration_costs < asset_sum_adjusted_hh
replace ma_afford_realistic = 0 if migrate_abroad==1 & ia_migration_costs==.
replace ma_afford_realistic=. if migrate_abroad==0 | ia_migration_costs==.
lab val ma_afford_realistic afford_lab
tab  ma_afford_realistic

*Migration likelihood abroad next 3 years
replace ma_likeliness=0 if migrate_abroad==0
gen prob_next3y=0 if ma_likeliness<0.5
replace prob_next3y=1 if ma_likeliness>=0.5
replace prob_next3y=. if ma_likeliness==.
lab def mig_prob_abroad 0 "Rather unlikely" 1 "At least somewhat likely", replace
lab val prob_next3y mig_prob_abroad

gen likelihood_next3y=1 if ma_likeliness<=0.2
replace likelihood_next3y=2 if ma_likeliness>0.2 & ma_likeliness <=0.7
replace likelihood_next3y=3 if ma_likeliness>0.7
replace likelihood_next3y=. if ma_likeliness==.
lab def mig_prob_abroad2 1 "Very unlikely" 2 "Neither" 3 "Very likely", replace
lab val likelihood_next3y mig_prob_abroad2


*binary migration likelihood = 1 if "very likely"
gen d_next3y = 0 if likelihood_next3y <3
replace d_next3y = 1 if likelihood_next3y==3

* cluster aspired destination regions into low-, medium- & high-cost
tab ma_region
gen costliness_destinations = 1 if ma_region==3
replace costliness_destinations = 2 if ma_region==6
replace costliness_destinations = 3 if ma_region==1 | ma_region==2 | ma_region==4 | ma_region==5 
replace costliness_destination = 0 if migrate_abroad == 0
lab def costly1 0 "No aspiration" 1 "Low income" 2 "Medium income" 3 "High income", replace 
lab val costliness_destination costly1 

* aspiration dummies
tab costliness_destination, gen(aspired_destination)


gen aspirations = 1 if migrate_abroad == 0
replace aspirations = 2 if migrate_abroad == 1 & avg_ma_afford == 0
replace aspirations = 3 if migrate_abroad == 1 & avg_ma_afford == 1
lab def aspirations_lab 1 "No aspiration" 2 "Aspiration beyond ability" 3 "Aspiration within ability", replace
lab val aspirations aspirations_lab
tab aspirations, gen (aspiring)



* Affordability by costliness of destinations
bysort costliness_destinations: sum mc_abroad

gen afford_destination=1 if asset_sum_adjusted_hh < 767 
replace afford_destination=2 if asset_sum_adjusted_hh >= 767 & asset_sum_adjusted_hh < 9195
replace afford_destination=3 if asset_sum_adjusted_hh >= 9195 & asset_sum_adjusted_hh < 19566
replace afford_destination=4 if asset_sum_adjusted_hh >= 19566 
replace afford_destination=. if country_id==1 | asset_sum_adjusted_hh==.
lab def afford3 1 "Nothing" 2 "Low cost (South Asia)" 3 "Medium cost (MENA)" 4 "High cost (NA, EU, AU, EA)", replace
lab val afford_destination afford3

gen aspiration_strength = 1 if migrate_abroad==0
replace aspiration_strength = 2 if migrate_abroad==1
replace aspiration_strength = 3 if likelihood_next3y==3
replace aspiration_strength=. if  asset_sum_adjusted_hh==.
lab def aspiration_str1 1 "No aspiration (n=224)" 2 "Weak intention (n=339)" 3 "Strong intention (n=22)", replace
lab val aspiration_strength aspiration_str1

* Set variables related to ma_country to missing if no country was named (migrate_abroad==0)
foreach v of varlist mc_abroad mr_abroad prob_next3y likelihood_next3y ma_afford m_steps_passport m_steps_visa m_steps_language m_steps_money m_steps_id m_steps_ticket   m_steps_none ma_reason_rel {
	replace `v'=. if migrate_abroad==0
	}

*replace m_steps_healthcheck=0 if migrate_abroad==1 & country_id==3
replace m_steps_ticket=0 if migrate_abroad==1 & country_id==3






*---------------------------------------
* (3) Organzie the data set
*---------------------------------------
sort country_id location female married age edu people_hh income income_hh 
drop if age==.
gen id=_n
lab var id "Unique identifier"

keep id country_id location   treatment ///
	/*socio*/ female married age edu people_hh income income_hh religion ///
	occupation income_meals_month income_meals_frequency rel_wealth1 rel_wealth2 rel_wealth3 ///
	asset_sum assets_correct assets_personal_estimation life_satisfaction z_immovables_value z_movables_value fix_assets immovables_value movables_value village_same ///
	///
	/*cc*/ number_extremes mean_extremes pc_livelihood pc_relocate rebuild_house rebuild_frequency rebuild_days rebuild_costs land_lost land_lost_value /// extreme events, perceived threat and damages
	pp_slr cc_pp pca_cc_pp pp_drought pp_cyclones pp_drought pp_cyclones  cc_perception_past1 cc_perception_past2 cc_perception_past3 cc_perception_past4 cc_perception_past6 cc_perception_past7 cc_perception_past8 cc_perception_past9 /// Past climatic changes
	 fp_slr cc_fp pca_cc_fp fp_drought fp_cyclones fp_drought fp_cyclones  cc_expectation1 cc_expectation2 cc_expectation3 cc_expectation4 cc_expectation6 cc_expectation7 cc_expectation8 cc_expectation9 /// future climatic changes
	 ///
	sealevel1 sealevel2 sealevel3 sealevel4 sealevel5  /// adaptatation stratgies
	///
	/*migration*/ migrate_abroad migration_perm_place migration_perm_area distance distance_self migration_perm_option urban ///
	ma_place ma_country ma_region ma_reason ///
	ma_reason_relig ma_reason_econ ma_reason_rel ma_reason_prox ma_reason_lifesat ///
	mc_city mc_abroad mr_city ma_afford_hhsize_adj ma_afford_realistic mr_abroad m_steps  ma_likeliness prob_next3y likelihood_next3y ///
	m_steps_passport m_steps_visa m_steps_language m_steps_money /// 
	m_steps_id  m_steps_ticket m_steps_none ///
	m_willingness_to_pay_legal m_willingness_to_pay_illlegal ///
	ms_successful ms_success_legal_immigration ///
	ms_success_skills ms_success_effort ms_success_network ms_success_luck ///
	ms_unsuccessful ms_unsuccess_illegal_immigration ms_unsuccess_unskilled ///
	ms_unsuccess_loweffort ms_unsuccess_nonetwork ms_unsuccess_noluck ///
	place_identity_norm place_dependence_norm z_identity z_dependence z_risk2 risk_aversion_norm survey_time survey_risk risk t_extremes extreme1 extreme2 extreme3 exp_extreme village_extremes t_extreme2 log_income_hh log_asset_sum log_rebuild_costs log_rebuild_days log_number_extremes income_hh_w01 asset_sum_w01 rebuild_costs_w01 rebuild_days_w01 number_extremes_w01 pc1 pca_rebuild_intensity dest_lat_urban dest_long_urban urban_distance z_income z_assets income_hh_outlier asset_sum_outlier asset_sum_adjusted_hh only_local adapt1 strat1 strat2 strat3 strat4 relocate cc_relocate ma_region1 ma_region2 ma_region3 ma_region4 ma_region5 ma_region6 ma_region7 ma_region8 actual_costs ia_migration_costs avg_mc_abroad avg_ma_afford d_next3y costliness_destinations aspired_destination1 aspired_destination2 aspired_destination3 aspired_destination4 aspirations aspiring1 aspiring2 aspiring3 afford_destination aspiration_strength assistant
	
order id country_id location  treatment ///
	/*socio*/ female married age edu people_hh income income_hh religion ///
	occupation income_meals_month income_meals_frequency rel_wealth1 rel_wealth2 rel_wealth3 ///
	asset_sum assets_correct assets_personal_estimation life_satisfaction z_immovables_value z_movables_value fix_assets immovables_value movables_value village_same ///
	///
	/*cc*/ number_extremes mean_extremes pc_livelihood pc_relocate rebuild_house rebuild_frequency rebuild_days rebuild_costs land_lost land_lost_value /// extreme events, perceived threat and damages
	pp_slr cc_pp pca_cc_pp pp_drought pp_cyclones pp_drought pp_cyclones  cc_perception_past1 cc_perception_past2 cc_perception_past3 cc_perception_past4 cc_perception_past6 cc_perception_past7 cc_perception_past8 cc_perception_past9 /// Past climatic changes
	 fp_slr cc_fp pca_cc_fp fp_drought fp_cyclones fp_drought fp_cyclones  cc_expectation1 cc_expectation2 cc_expectation3 cc_expectation4 cc_expectation6 cc_expectation7 cc_expectation8 cc_expectation9 /// future climatic changes
	 ///
	sealevel1 sealevel2 sealevel3 sealevel4 sealevel5  /// adaptatation stratgies
	///
	/*migration*/ migration_perm_place migration_perm_area distance distance_self migration_perm_option urban ///
	ma_place ma_country ma_region ma_reason ///
	ma_reason_relig ma_reason_econ ma_reason_rel ma_reason_prox ma_reason_lifesat ///
	mc_city mc_abroad mr_city ma_afford_hhsize_adj ma_afford_realistic mr_abroad m_steps  ma_likeliness prob_next3y likelihood_next3y ///
	m_steps_passport m_steps_visa m_steps_language m_steps_money /// 
	m_steps_id  m_steps_ticket m_steps_none ///
	m_willingness_to_pay_legal m_willingness_to_pay_illlegal ///
	ms_successful ms_success_legal_immigration ///
	ms_success_skills ms_success_effort ms_success_network ms_success_luck ///
	ms_unsuccessful ms_unsuccess_illegal_immigration ms_unsuccess_unskilled ///
	ms_unsuccess_loweffort ms_unsuccess_nonetwork ms_unsuccess_noluck ///
	place_identity_norm place_dependence_norm z_identity z_dependence z_risk2 risk_aversion_norm t_extremes extreme1 extreme2 extreme3 exp_extreme village_extremes t_extreme2 log_income_hh log_asset_sum log_rebuild_costs log_rebuild_days log_number_extremes income_hh_w01 asset_sum_w01 rebuild_costs_w01 rebuild_days_w01 number_extremes_w01 pc1 pca_rebuild_intensity dest_lat_urban dest_long_urban urban_distance z_income z_assets income_hh_outlier asset_sum_outlier asset_sum_adjusted_hh only_local adapt1 strat1 strat2 strat3 strat4 relocate cc_relocate ma_region1 ma_region2 ma_region3 ma_region4 ma_region5 ma_region6 ma_region7 ma_region8 actual_costs ia_migration_costs avg_mc_abroad avg_ma_afford d_next3y costliness_destinations aspired_destination1 aspired_destination2 aspired_destination3 aspired_destination4 aspirations aspiring1 aspiring2 aspiring3 afford_destination aspiration_strength assistant

*save cleaned dataset for further analysis
save "$datapath\data_analysis.dta", replace
