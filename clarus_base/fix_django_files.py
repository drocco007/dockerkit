# coding: utf-8

"""Copy Django resource files — templates, translation documents, etc. — from
where Pip>6.0 puts them to where Django 1.3 expects them.

http://stackoverflow.com/questions/30980682/djangos-locale-files-installed-in-weird-place

Modified from http://stackoverflow.com/a/34419022/5013125

"""


import os

from distutils.sysconfig import get_python_lib
from distutils.dir_util import copy_tree


def resolve_pip_data_files(fix_packages=('django',)):
    env_path = os.environ.get('VIRTUAL_ENV', None)
    site_packages = get_python_lib()

    if not env_path:
        return  # not in virtual env

    for package in fix_packages:
        package_data_dir = os.path.join(env_path, package)
        package_dir = os.path.join(site_packages, package)

        if os.path.exists(package_data_dir) and os.path.exists(package_dir):
            print 'Copy', package_data_dir, '->', package_dir
            copy_tree(package_data_dir, package_dir)


if __name__ == '__main__':
    resolve_pip_data_files()
