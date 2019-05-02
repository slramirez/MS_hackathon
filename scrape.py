"""Scrape sites for text based data"""


import os
import time
import requests
import pandas as pd

from bs4 import BeautifulSoup

import config


section_names = ['Africa', 'East Asia and the Pacific',
                 'Europe and Eurasia', 'Near East and North Africa',
                 'South Asia', 'Western Hemisphere']

def state_dept_indexes(year, verbose=False):
    """"Scrape section links from the US State Department yearly 
    Human Rights Reports
    
    See https://www.state.gov/j/drl/rls/hrrpt/
    
    Parameters
    ----------
    year : int, year to scrape section links for
    verbose : bool, print debug statements
    
    Returns
    -------
    keep_section_links : list of lists containing:
        [text, url] : text, link text
                    : url, link to section
    """

    url = 'https://www.state.gov/j/drl/rls/hrrpt/{}/index.htm'.format(year)
    if verbose:
        print("Scraping Data from: ", url)

    r = requests.get(url)
    text = r.text
    soup = BeautifulSoup(text, "html5lib")

    section_links = []
    ignore_sections = ['Appendices', 'Appendixes', 'Front',
                       'Material', 'Preface', 'Overview',
                       'Acknowledgements', 'Introduction']

    for link in soup.find('ul', {"class": "menu"}).find_all('a'):
        text = link.text
        url = link.get('href')
        if verbose:
            print("Found Link: ", text, url)
        section_links.append([text, url])

    keep_section_links = []
    for text, url in section_links:
        keep = True
        for i in ignore_sections:
            if verbose:
                print(i, '>>>', text, '>>>', i in text)
            if i in text:
                keep = False
        if keep:
            keep_section_links.append([text, url])

    return keep_section_links


def state_dept_sections(year, section_url,
                    base_url='https://www.state.gov', verbose=False,
                    delay=0.1):
    """"Scrape report links from the US State Department yearly 
    Human Rights Reports.  
    
    Note: delay is to not hammer the state.gov server.
    See: https://www.state.gov/j/drl/rls/hrrpt/
    
    Parameters
    ----------
    year : int, year to scrape section links for
    section_url : str, url of link to report section containing report
    base_url : str, base url of site, defaults to 'https://www.state.gov'
    verbose : bool, print debug statements
    
    Returns
    -------
    country_links : list of lists containing:
        [year, url] : str, year of report
                    : url, link to report
    """

    year = str(year)

    if verbose:
        print("Scraping Data from: ", section_url)
    time.sleep(delay)
    r = requests.get(section_url)
    text = r.text
    soup = BeautifulSoup(text, "html5lib")

    country_links = []

    for link in soup.find_all('a', {"target": "_self"}):
        text = link.text
        url = link.get('href')
        if verbose:
            print("Found Link: ", text, url)
        if url is not None:
            if year in url:
                country_links.append([year, text, base_url + url])

    return country_links


def state_dept_country(url):
    """"Scrape report text from the US State Department yearly 
    Human Rights Reports

    See: https://www.state.gov/j/drl/rls/hrrpt/

    Parameters
    ----------
    url : str, url of link to report section containing report text
    
    Returns
    -------
    str, text of report
    """

    r = requests.get(url)
    data = r.text
    soup = BeautifulSoup(data, "html5lib")
    return soup.find("div", {"id": "centerblock"}).text


def state_dept_dl(years=config.state_dept_years, verbose=False):
    """"Scrape report text from the US State Department yearly 
    Human Rights Reports.  This will take ~15 minutes.

    See: https://www.state.gov/j/drl/rls/hrrpt/

    Parameters
    ----------
    url : str, url of link to report section containing report text
    verbose : bool, print debug statements
    
    Returns
    -------
    str, text of report
    """

    all_links = []
    for year in years:
        section_urls = state_dept_indexes(year=year, verbose=verbose)
        for text, url in section_urls:
            if verbose:
                print(text, '>>>', url)
            all_links = all_links + state_dept_sections(year=year,
                                                        section_url=url,
                                                        verbose=verbose)

    df = pd.DataFrame(all_links, columns=['year', 'country', 'url'])
    df['text'] = df.url.apply(state_dept_country)


def state_dept_dl_to_csv(years=config.state_dept_years, verbose=False):
    """"Scrape report text from the US State Department yearly 
    Human Rights Reports.  This will take ~15 minutes.

    See: https://www.state.gov/j/drl/rls/hrrpt/

    Parameters
    ----------
    year : int, year to scrape section links for
    verbose : bool, print debug statements
    """

    _df = state_dept_dl(years=years, verbose=verbose)
    _df.to_csv(config.state_dept_data)


if __name__ == "__main__":

    if not os.path.isfile(config.state_dept_data):
        state_dept_dl_to_csv()
