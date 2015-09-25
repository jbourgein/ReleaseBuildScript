#Release Build Script
This is a Bash script to build signed iOS and Android versions of a Cordova app ready for release. To use, change the settings at the top of the file to point to the right places.

##Android Build Problems
Quite often Android throws errors when running the `ant release` command. Some common fixed are below:
 - Missing `build.xml` file - you need to update the Android project by running `android update project .` from the Android project root. Then you will need to change the project title in newly generated `build.xml`
 - If CordovaLib is missing `build.xml` file then run the above but from the `CordovaLib` directory. 
 - Cordova uses the `custom_rules.xml` file to change the path it looks for Cordova sources. If the directory `CordovaLib\ant-build` is missing then change the `custom_rules.xml` to reflect this (you can probably just delete the contents entirely).
 - Good workflow is trying all of the following
	 - remove `build.xml` from android project root
	 - run `ant clean`
	 - run `android update project .`
	 - cd to `CordovaLib`
	 - delete `build.xml`
	 - run `ant clean`
	 - run `android update project .`
	 - check `custom_rules.xml` is not pointing to `ant-build`
 - If nothing working - import into Eclipse and check all buildpath settings and try a build from there