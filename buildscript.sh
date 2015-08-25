#!/bin/sh
SENCHA_BUILD_SCRIPT_PATH=/path/only/to/build/script/
SENCHA_BUILD_SCRIPT_NAME=<build_name>
XCODE_PROJECT_PATH=/path/to/xcode/project/folder/
XCODE_ARCHIVE_PATH=/where/to/save/xcarchive
RELEASE_PATH=/where/to/save/apk/and/ipa
PROVISIONING_PROFILE="Provisioning Profile Name"
ANDROID_HOME=/path/to/android/sdk
ANDROID_PROJECT_PATH=/path/to/android/project/folder
ANDROID_KEYSTORE_LOCATION=/path/to/keystore/location
ANDROID_UNSIGNED_APK_PATH=path/to/where/unsigned/apks/go/usually/android/project/folder/bin/AppName-release-unsigned.apk
ANDROID_KEY_NAME=<nameofkey>

cd $SENCHA_BUILD_SCRIPT_PATH

sh $SENCHA_BUILD_SCRIPT_NAME d
	
cd $XCODE_PROJECT_PATH

xcodebuild -scheme RetailMotus -archivePath $XCODE_ARCHIVE_PATH -destination generic/platform=iOS clean archive

xcodebuild -exportArchive -exportFormat IPA -archivePath $XCODE_ARCHIVE_PATH.xcarchive -exportPath $RELEASE_PATH.ipa -exportProvisioningProfile \"$PROVISIONING_PROFILE\"

export ANDROID_HOME=$ANDROID_HOME 

cd $ANDROID_PROJECT_PATH

ant release

jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $ANDROID_KEYSTORE_LOCATION $ANDROID_UNSIGNED_APK_PATH $ANDROID_KEY_NAME

zipalign -v 4 $ANDROID_UNSIGNED_APK_PATH $RELEASE_PATH.apk