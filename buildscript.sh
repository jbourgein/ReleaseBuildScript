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
ANDROID_PROJ_PROPS_FILE_CONTENTS="target=android-22\nandroid.library.reference.1=CordovaLib\nmanifestmerger.enabled=true\nandroid.library.reference.2=../../plugins/com.salesforce/src/android/libs/SalesforceSDK\nandroid.library.reference.3=../../plugins/com.salesforce/src/android/libs/SmartStore\nandroid.library.reference.4=../../plugins/com.salesforce/src/android/libs/SmartSync"
LOG_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" &&  pwd)/RM_build_$(date +%Y-%m-%d-%H%M).log

echo "\nBuilding RetailMotus"
echo "Log available here: $LOG_PATH\n"

echo "\tRunning Sencha build script: $SENCHA_BUILD_SCRIPT_PATH$SENCHA_BUILD_SCRIPT_NAME"
cd $SENCHA_BUILD_SCRIPT_PATH

sh $SENCHA_BUILD_SCRIPT_NAME d > $LOG_PATH

echo "\tBuild iOS archive using XCode Project: $XCODE_PROJECT_PATH"
cd $XCODE_PROJECT_PATH
xcodebuild -scheme RetailMotus -archivePath $XCODE_ARCHIVE_PATH -destination generic/platform=iOS clean archive  >> $LOG_PATH
if [[ $? == 0 ]]; then
    echo "\tCreating IPA here: $RELEASE_PATH"
    echo "\tUsing Provisioning Profile: $PROVISIONING_PROFILE"
    rm -r $RELEASE_PATH.ipa >> $LOG_PATH
    xcodebuild -exportArchive -exportFormat IPA -archivePath $XCODE_ARCHIVE_PATH.xcarchive -exportPath $RELEASE_PATH -exportProvisioningProfile "$PROVISIONING_PROFILE"  >> $LOG_PATH
    if [[ $? == 0 ]]; then
        echo "\t\033[32m iOS build succeeded! IPA location: $RELEASE_PATH.ipa \033[0m"
        rm -r $XCODE_ARCHIVE_PATH.xcarchive  >> $LOG_PATH
        export ANDROID_HOME=$ANDROID_HOME 

        echo "\tBuilding Android Project: $ANDROID_PROJECT_PATH"
        cd $ANDROID_PROJECT_PATH
        ant clean >> $LOG_PATH
        echo $ANDROID_PROJ_PROPS_FILE_CONTENTS > "$ANDROID_PROJECT_PATH/project.properties"
        ant release  >> $LOG_PATH
        if [[ $? == 0 ]]; then
            echo "\tSigning APK using Keystore: $ANDROID_KEYSTORE_LOCATION"
            echo "\tUsing key name: $ANDROID_KEY_NAME"
            jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $ANDROID_KEYSTORE_LOCATION $ANDROID_UNSIGNED_APK_PATH $ANDROID_KEY_NAME  >> $LOG_PATH
            if [[ $? == 0 ]]; then
                echo "\tAligning signed APK"
                rm -r $RELEASE_PATH.apk >> $LOG_PATH
                zipalign -v 4 $ANDROID_UNSIGNED_APK_PATH $RELEASE_PATH.apk >> $LOG_PATH
                if [[ $? == 0 ]]; then
                    echo "\t\033[32m Android build succeeded! APK location: $RELEASE_PATH.apk \033[0m"
                else
                    echo "\033[31m Android zipalign failed. \033[0m"
                fi
            else
                echo "\033[31m Android app signing failed.\033[31m"
            fi
        else
            echo "\033[31m Android build failed. Aborting Android build. iOS ipa should have succeeded.\033[0m"
        fi
    else
        echo "\033[31m Xcode ipa package failed. Aborting builds.\033[0m"
    fi
else
    echo "\033[31m Xcode archive failed. Aborting builds.\033[0m"
fi