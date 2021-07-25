## Usage

Firstly, configure the package template by changing the information in `./initialise/config.txt`. Then run the script as follows:

```
./create-npm-package $PACKAGE_NAME $PACKAGE_DESCRIPTION`
```

Call the following to create the package repository (requires [hub](https://github.com/github/hub)):

```
hub create $PACKAGE_NAME
git push -u origin master
```
