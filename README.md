## Usage

Firstly, configure the package template by changing the information in `./initialise/config.txt`. Then run the script as follows:

```
./create-npm-package $PACKAGE_NAME $PACKAGE_DESCRIPTION`
```

#### Github

Call the following to create the Github repository (requires [hub](https://github.com/github/hub)):

```
hub create $PACKAGE_NAME
git push -u origin master
```

#### npm

Call the following to publish the npm packages with bumped versions:

```
npm run publish:patch
npm run publish:minor
npm run publish:major
```

Initial publish is achieved by calling `npm run publish:public`
