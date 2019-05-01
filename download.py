"""Download files used in this project"""

import os
import requests
import tarfile
import zipfile

import config

def download_data(d_url, d_directory, verbose=False):
    """Download data to local directory

    Parameters
    ----------
    d_directory : str, path to directory to save file
    d_url : str, URL to download file
    """
    if verbose:
            print('Downloading data from %s...' % d_url)
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


def required_data():
    """Download required data for project"""

    download_data(config.v_dem_data, config.default_target)

    print('All downloads complete.')

if __name__ == "__main__":
    required_data()
