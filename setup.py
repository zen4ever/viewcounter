from setuptools import setup, find_packages


setup(
    name='viewcounter',
    version="0.0.1",
    packages=find_packages(),
    py_modules=['viewcounter_lambda'],
    include_package_data=True,
    author_email="andrew@marpasoft.com",
    install_requires=[
    ],
)
