# XYP12Reader
a framework for getting the p12 file information

## Usage

* Init with p12 path and password

	`let p12Reader = P12Reader(path: "some.p12", password: "123")`
	
* Call `getInfo()`
	
	`p12Reader.getInfo()`
	
* After calling `getInfo()`, we can get the codesignIdentity and sha1

	`p12Reader.codesignIdentity`
	`p12Reader.sha1`
	
* Use `description()` to print the strings above
	
	`p12Reader.description()`
