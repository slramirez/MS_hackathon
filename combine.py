"""Combine CIRI data with State Department data
Duplicates method of combining data in
'Merge CIRI with State Dep.ipynb

Merges CIRI scores for years 1999 to 2015 with US State Department
yearly reports of Human Rights

TODO: remove notebook and check merge in this file
"""

import pandas as pd

import config


# CIRI data
ciri_fp = config.data_directory + config.ciri_data
df_ciri = pd.read_csv(ciri_fp)

# US State Department data
state_fp = config.data_directory + config.state_dept_data
state_coded_fp = config.data_directory + config.state_dept_un_coded_data
df_state = pd.read_csv(state_fp)
df_state = pd.read_csv(state_coded_fp)
print(state_fp)
print(state_coded_fp)

# State Department to Gapminder names
ref_fp = config.data_directory + config.un_country_code_data
df_ref = pd.read_csv(ref_fp)
df_ref = df_ref.drop(df_ref.columns[0], axis=1)
print(ref_fp)

# Read in GapMinder
codes_fp = config.data_directory + config.gapminder_un_country_code_data
df_codes = pd.read_csv(codes_fp)
print(codes_fp)

def compare(x, codes):
    # Countries in the GapMinder Data are not exactly the same as in the UN codes.
    # This function looks for the most parsimonious name link between ...
    # ... the GapMinder and UN data and return the UN codes.
    def compare(x, codes):
        ctry = {'size': 100, 'un': 0}
        for i in range(len(codes)):
            if x.lower() in codes.CTRY.iloc[i].lower():
                if len(codes.CTRY.iloc[i]) <= ctry['size']:
                    ctry['size'] = len(codes.CTRY.iloc[i])
                    ctry['un'] = codes.UNCTRY.iloc[i]
        return ctry


# Take the simplified state deptartment country names...
countries = df_ref.simple.unique()

un = []
# Loop through and find the GapMinder equivalent and UN number.
for i in countries:
    print(i)
    un.append(compare(i, df_codes)['un'])
codes = pd.DataFrame({'CTRY': countries, 'UNCTRY': un})

# Associate the UN numbers by simple country name in state dept. data.
# This has the side-effect of giving the same UN code to various spellings of countries.
st_dpt_un = pd.merge(df_ref, codes,
                     left_on='simple',
                     right_on='CTRY',
                     how='left').drop('simple', axis=1)

# Associate complex country name with the State Dept. to include the text data.
df_state_dep = pd.merge(df_state, st_dpt_un,
                        left_on='country',
                        right_on='country',
                        how='left').drop(['CTRY'], axis=1)
#original dropped 'country' as well, leaving it in to check its working

# Merge CIRI data with State Dept. data.
df_text_to_ciri = pd.merge(state_dep,ciri_df,
                           left_on=['UNCTRY','year'],
                           right_on=['unctry',"year"],
                           how = 'inner') #.drop('Country',axis=1)

# Write to file
#fp_out = config.data_directory +
df_text_to_ciri.to_csv('../data/Custom_State_Dep_Reports/CIRI_Text_1999_2015.csv')