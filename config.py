"""Configuration variables"""


import os
current_directory = os.path.dirname(os.path.realpath(__file__))

data_directory = current_directory + os.path.sep + os.path.normpath("data") + os.path.sep

# US State Department Human Rights Data
state_dept_years = list(range(1999, 2019))
state_dept_data = "us_state_dept_hr_reports.csv"

# CIRI Human Rights Data Project
ciri_url = "https://www.dropbox.com/s/7tmbttddeiaap94/CIRI%20Data%201981_2011%202014.04.14.csv?dl=1"
ciri_data = "CIRI Data 1981_2011 2014.04.14.csv"

# CIRIGHTS Data Project
cirights_url = "https://www.dropbox.com/s/x2sct3bsy63zb31/ci_rights_data_project_dataset.csv?dl=1"
cirights_data = "ci_rights_data_project_dataset.csv"

# Variables of Democracy
v_dem_data = "https://www.dropbox.com/s/ixqjxqva959ulro/v_dem_data.zip?dl=1"

# Gapminder Data
gapminder_un_country_code_data = "UNCTRY_CODES_GapMinderNames.csv"

# UN Country Codes
un_country_code_data = "state_dept_country_names.csv"
