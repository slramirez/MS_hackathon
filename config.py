"""Configuration variables"""


import os


data_directory = os.path.normpath("data") + os.path.sep

state_dept_years = list(range(1999,2019))
state_dept_data = data_directory + "us_state_dept_hr_reports.csv"


v_dem_data = "https://www.dropbox.com/s/ixqjxqva959ulro/v_dem_data.zip?dl=1"
