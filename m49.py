"""Convert country codes according to UN Series M, No. 49 codes
https://unstats.un.org/unsd/methodology/m49/

2019 Colin Dietrich
"""


import pandas as pd


class M49:
    def __init__(self, code_file):
        self.code_file = code_file
        self.df = pd.read_csv(self.code_file, sep=' \t', engine='python')

        df_dict = self.df.to_dict(orient='list')
        self.area = df_dict['Country or Area']
        self.m49_code = df_dict['M49 code']
        self.iso_alpha3 = df_dict['ISO-alpha3 code']

    def check_area(self, area_name):
        return area_name in self.area

    def check_m49(self, m49_code):
        return m49_code in self.m49_code

    #  following methods could be calculated as dictionaries

    def area_to_m49(self, area_name):
        """Return UN Country or Area name for an M49 code

        Parameters
        ----------
        area_name : str, area/country name

        Returns
        -------
        int, m49 code for area/country
        """
        try:
            return self.df.loc[self.df['Country or Area'] == area_name, 'M49 code'].values[0]
        except IndexError:
            print('area in >>', area_name, area_name is None)

    def area_to_iso_alpha3(self, area_name):
        try:
            return self.df.loc[self.df['Country or Area'] == area_name, 'ISO-alpha3 code'].values[0]
        except IndexError:
            print('area_name >>', area_name)
            return ""

    def m49_to_iso_alpha3(self, m49_code):
        try:
            return self.df.loc[self.df['M49 code'] == int(m49_code), 'ISO-alpha3 code'].values[0]
        except IndexError:
            print(m49_code)
            return ""

    def m49_to_area(self, m49_code):
        """Return UN Country or Area name for an M49 code

        Parameters
        ----------
        m49_code : int, code for area/country

        Returns
        -------
        str : area/country name
        """
        try:
            return self.df.loc[self.df['M49 code'] == int(m49_code), 'Country or Area'].values[0]
        except IndexError:
            print(m49_code)
