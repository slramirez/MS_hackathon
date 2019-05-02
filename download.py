"""Download files used in this project"""

import os
import requests
import tarfile
import zipfile

import config

def download_data(d_url, d_directory, d_file=None, verbose=False):
    """Download data to local directory

    Parameters
    ----------
    d_directory : str, path to directory to save file
    d_url : str, URL to download file
    """
    if verbose:
            print('Downloading data from %s...' % d_url)
    if d_file is None:
        d_file = d_url.split("/")[-1]
        if "?" in d_file:
            d_file = d_file.split("?")[0]
    d_file_target = os.path.normpath(d_directory + os.path.sep + d_file)
    if not os.path.exists(d_file_target):
        res = requests.get(d_url)
        with open(d_file_target, "wb") as f:
            f.write(res.content)
        if verbose:
            print('Data is located in %s' % d_directory)
    else:
        print('Download file already exists in {}'.format(d_directory))


def extract_files(d_file, d_directory=".", verbose=False):
    """Extract tar or tar.gz archive files

    Parameters
    ----------
    d_file : str, file name of archive to extract
    d_directory : str, path to directory to save file
    """
    if d_file.endswith("tar.gz") or d_file.endswith("tgz"):
        tar = tarfile.open(d_file, "r:gz")
        tar.extractall(path=d_directory)
        tar.close()
    elif d_file.endswith("tar") or d_file.endswith("tarfile"):
        tar = tarfile.open(d_file, "r:")
        tar.extractall(path=d_directory)
        tar.close()
    elif d_file.endswith("zip"):
        zip_ref = zipfile.ZipFile(d_file, 'r')
        zip_ref.extractall(d_directory)
        zip_ref.close()
    if verbose:
        print("Files extracted successfully to {}".format(d_directory))


def download_extract(d_url, d_directory, verbose=False):
    """Download and extract zip file data from a URL
    
    Parameters
    ----------
    d_url : str, file name of archive to extract
    d_directory : str, path to directory to save file
    """
    download_data(d_url, d_directory, verbose)
    data_file = d_url.split("/")[-1]
    data_file_target = os.path.normpath(d_directory +
                                             os.path.sep +
                                             data_file)
    extract_files(data_file_target, d_directory, verbose)

def download_file_from_google_drive(id, destination):
    """Download a file from Google Drive
    Happily copied from:  
    https://stackoverflow.com/questions/38511444/python-download-files-from-google-drive-using-url
    """
    URL = "https://docs.google.com/uc?export=download"

    session = requests.Session()

    response = session.get(URL, params = { 'id' : id }, stream = True)
    token = get_confirm_token(response)

    if token:
        params = { 'id' : id, 'confirm' : token }
        response = session.get(URL, params = params, stream = True)

    save_response_content(response, destination)

def get_confirm_token(response):
    for key, value in response.cookies.items():
        if key.startswith('download_warning'):
            return value

    return None

def save_response_content(response, destination):
    CHUNK_SIZE = 32768

    with open(destination, "wb") as f:
        for chunk in response.iter_content(CHUNK_SIZE):
            if chunk: # filter out keep-alive new chunks
                f.write(chunk)


#def ciri_2011_2018(d_directory):
#    file_id = ""
#    download_file_from_google_drive(file_id, d_directory)
#    [click here](https: // drive.google.com / file / d / 1
#    q0imjixfsqDyGLCBzVWvJBzOuy4onkyb / view?usp = sharing)


def required_data():
    """Download required data for project"""

    # V-dem was not used
    #download_data(config.v_dem_data, config.data_directory)

    #download_data(config.ciri_data, config.data_directory,
    #              d_file='CIRI_Data_1981_2011.csv')

    #ciri_2011_2018_share_link =
    # https://drive.google.com/file/d/1q0imjixfsqDyGLCBzVWvJBzOuy4onkyb/view?usp=sharing
    ciri_2011_2018_file_id = "1q0imjixfsqDyGLCBzVWvJBzOuy4onkyb"
    download_file_from_google_drive(ciri_2011_2018_file_id,
        config.data_directory + "ci_rights_data_project_dataset.xlsx")

    print('All downloads complete.')

if __name__ == "__main__":
    required_data()
