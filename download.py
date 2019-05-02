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
    d_file : str, file name of archive to extract
    verbose : bool, print debug statements
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
    verbose : bool, print debug statements
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
    verbose : bool, print debug statements
    """
    download_data(d_url, d_directory, verbose)
    data_file = d_url.split("/")[-1]
    data_file_target = os.path.normpath(d_directory +
                                        os.path.sep +
                                        data_file)
    extract_files(data_file_target, d_directory, verbose)


def download_file_from_google_drive(file_id, destination):
    """Download a file from Google Drive
    Happily copied from:  
    https://stackoverflow.com/questions/38511444/python-download-files-from-google-drive-using-url
    """
    url = "https://docs.google.com/uc?export=download"

    session = requests.Session()

    response = session.get(url, params={'id': file_id}, stream=True)
    token = get_confirm_token(response)

    if token:
        params = {'id': file_id, 'confirm': token}
        response = session.get(url, params=params, stream=True)

    save_response_content(response, destination)


def get_confirm_token(response):
    for key, value in response.cookies.items():
        if key.startswith('download_warning'):
            return value

    return None


def save_response_content(response, destination):
    chunk_size = 32768

    with open(destination, "wb") as f:
        for chunk in response.iter_content(chunk_size):
            if chunk:  # filter out keep-alive new chunks
                f.write(chunk)


def required_data():
    """Download required data for project"""

    # V-dem was not used
    # download_data(config.v_dem_data, config.data_directory)

    # ciri data
    download_data(config.ciri_url,
                  config.data_directory,
                  d_file=config.ciri_data)

    # cirights_data
    download_data(config.cirights_url,
                  config.data_directory,
                  d_file=config.cirights_data)

    print('All downloads complete.')


if __name__ == "__main__":
    required_data()
