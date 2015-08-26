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
if [[ $? == 0 ]]; then
	xcodebuild -exportArchive -exportFormat IPA -archivePath $XCODE_ARCHIVE_PATH.xcarchive -exportPath $RELEASE_PATH.ipa -exportProvisioningProfile "$PROVISIONING_PROFILE"
	if [[ $? == 0 ]]; then
		rm $XCODE_ARCHIVE_PATH.xcarchive
		export ANDROID_HOME=$ANDROID_HOME 

		cd $ANDROID_PROJECT_PATH

		ant release
		if [[ $? == 0 ]]; then
			jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $ANDROID_KEYSTORE_LOCATION $ANDROID_UNSIGNED_APK_PATH $ANDROID_KEY_NAME
			if [[ $? == 0 ]]; then
				zipalign -v 4 $ANDROID_UNSIGNED_APK_PATH $RELEASE_PATH.apk
				if [[ $? == 0 ]]; then
					echo "Android build succeeded!	 APK location: $RELEASE_PATH"
				else
					echo "Android zipalign failed."
				fi
			else
				echo "Android app signing failed."
			fi
		else
			echo "Android build failed. Aborting build. iOS ipa should have succeeded"
		fi
	else
		echo "Xcode ipa package failed. Aborting builds."
	fi
else
	echo "Xcode archive failed. Aborting builds"
fi