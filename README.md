## Hackathon with Insight Seattle 2019A in partnership with Microsoft AI for Good

### Team Members
#### [Priscilla Addison](https://github.com/Peaddison), [Tyler Blair](https://github.com/tblair7), [Kyle Chezik](https://github.com/kchezik), [Colin Dietrich](https://github.com/crdietrich), [Stephanie Lee](https://github.com/stephanieylee), [Marie Salmi](https://github.com/salmim), [Gareth Walker](https://github.com/InternetGareth), [Hao Zheng](https://github.com/pkufelix)

### Data Descriptions  
#### [GapMinder Data](https://www.gapminder.org/data/)

##### Raw Format
* header row has variable names
* Columns = country,year,year,year, ...
* comma delimited, no tabs
* contents described in file names as below

'aged_15plus_employment_rate_percent.csv'  
'aid_received_per_person_current_us.csv'  
'cell_phones_per_100_people.csv'  
'child_mortality_0_5_year_olds_dying_per_1000_born.csv'  
'corruption_perception_index_cpi.csv'  
'crude_birth_rate_births_per_1000_population.csv'  
'democracy_score_use_as_color.csv'  
'hdi_human_development_index.csv'  
'inequality_index_gini.csv'  
'inflation_annual_percent.csv'  
'life_expectancy_female.csv'  
'life_expectancy_male.csv'  
'life_expectancy_years.csv'  
'literacy_rate_adult_female_percent_of_females_ages_15_above.csv'  
'literacy_rate_adult_male_percent_of_males_ages_15_and_above.csv'  
'literacy_rate_adult_total_percent_of_people_ages_15_and_above.csv'  
'murder_per_100000_people.csv'  
'num_of_journalists_killed.csv'  
'population_total.csv'  
'ratio_of_girls_to_boys_in_primary_and_secondary_education_perc.csv'  
'total_gdp_us_inflation_adjusted.csv'  
'UNCTRY_CODES.csv'

##### Pivoted and Combined Format  
* header row has variable names
* Columns = index,country,Date,POPULATION,UNCTRY,ANNUAL_BIRTH_RATE_PER_1000,LIFE_EXP_YEARS,LIFE_EXP_YEARS_F,LIFE_EXP_YEARS_M,CHILD_MORTALITY,GDP_USD,INFLATION_PERCENT,EMPLOYMENT,GINI,AID_RECEIVED_PP,GIRLS_V_BOYS_EDU,ADULT_LIT_RATE,ADULT_LIT_RATE_F,ADULT_LIT_RATE_M,JOURNALISTS_KILLED,CELL_PHONE_PER_100,CORRUPTION_INDEX,DEMOCRACY_SCORE,HUMAN_DEV_SCORE,MURDER_PER_1000

#### [CIRI Human Rights Data Project](http://www.humanrightsdata.com/)

##### Format
Header row is:
CTRY,YEAR,CIRI,COW,POLITY,UNCTRY,UNREG,UNSUBREG,PHYSINT,DISAP,KILL,POLPRIS,TORT,OLD_EMPINX,NEW_EMPINX,ASSN,FORMOV,DOMMOV,OLD_MOVE,SPEECH,ELECSD,OLD_RELFRE,NEW_RELFRE,WORKER,WECON,WOPOL,WOSOC,INJUD

##### Variable Definitions  
See [CIRI_data_description.md](CIRI_data_description.md)


#### [Varieties of Democracy](https://www.v-dem.net/en/)
Varieties of Democracy (V-Dem) distinguishes between five high-level principles of democracy: electoral, liberal, participatory, deliberative, and egalitarian, and collects data to measure these principles.  Columns are defined in a separate publication:  
https://www.v-dem.net/en/reference/version-9-apr-2019/  

#### Country Codes  
United Nations Statistics Division, Country Codes  
https://unstats.un.org/unsd/methodology/m49/
Used as cross-data index for country identification
`M49_country_codes.txt` lists these codes  

#### Gapminder, CIRI, V-Dem Merged  
`gapminder_ciri_v-dem_merged.csv`  
Merged data of Gapminder, CIRI and V-Dem, approximately 60MB uncompressed.  Committed as a 1.3MB zip.  Columns data variables are as described in the source data sections.  

### Usage Notes  

##### Python Environment  
environment.yml contains [Conda environment](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html) file  
Usage:  
`$ conda env create -f environment.yml`  

##### Chrome Driver
[chromedriver](https://chromedriver.storage.googleapis.com/index.html?path=74.0.3729.6/) is necessary for webscraping in the Selenium notebook
