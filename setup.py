import os
import pypandoc
from setuptools import find_packages
from distutils.core import setup
from Cython.Build import cythonize


with open(os.path.join(os.path.dirname(__file__), 'cstruct/VERSION')) as f:
    version = f.read().strip()


setup(
    name='cstruct',
    version=version,
    ext_modules=cythonize([
        "cstruct/io/bytes_reader.pyx",
        "cstruct/io/bytes_writer.pyx",
    ]),
    packages=find_packages(exclude=["*.test", "*.test.*", "test.*", "test", "script", "private", "tests"]),
    install_requires=["Cython>=0.29.0"],
    include_package_data=True,
    url='https://www.github.com/SnowWalkerJ/cstruct',
    license='GNU',
    author='SnowWalkerJ',
    author_email='jike3212001@163.com',
    description='For fast binary serialization',
    long_decription=pypandoc.convert("README.md", "rst"),
    classifiers=[
        'Programming Language :: Python',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.6',

        'Operating System :: OS Independent',
        'Operating System :: POSIX',
        'Operating System :: MacOS',
        'Operating System :: Unix',

        'Topic :: Software Development :: Libraries :: Python Modules',
    ]
)
