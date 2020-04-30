#!/bin/sh

sleep 30

echo 'starting script'

echo 'updating carthage dependencies'
carthage update --platform macOS

# DECIPHER DEVELOPMENT CERTIFICATES

echo 'deciphering dev certificate'
openssl enc -aes-256-cbc -base64 -pass pass:$SECURITY_PASSWORD -d -in scripts/certs/enc-development-cert.cer -out scripts/certs/development-cert.cer

echo 'deciphering dev key'
openssl enc -aes-256-cbc -base64 -pass pass:$SECURITY_PASSWORD -d -in scripts/certs/enc-development-key.p12 -out scripts/certs/development-key.p12


# Create custom keychain

# Create custom keychain

echo 'creating custom keychain'
security create-keychain -p $CUSTOM_KEYCHAIN_PASSWORD ios-build.keychain

# Make the ios-build.keychain default, so xcodebuild will use it
echo 'setting default keychain'
security default-keychain -s ios-build.keychain

# Unlock the keychain
echo 'unlocking keychain'
security unlock-keychain -p $CUSTOM_KEYCHAIN_PASSWORD ios-build.keychain

# Set keychain timeout to 1 hour for long builds
echo 'setting keychain timeout to 1h'
security set-keychain-settings -t 3600 -l ~/Library/Keychains/ios-build.keychain

echo 'importing apple certificate'
security import ./scripts/certs/AppleWWDRCA.cer -k ios-build.keychain -A
echo 'importing dev cert'
security import ./scripts/certs/development-cert.cer -k ios-build.keychain -P $SECURITY_PASSWORD -A
echo 'importing dev key'
security import ./scripts/certs/development-key.p12 -k ios-build.keychain -P $SECURITY_PASSWORD -A

# Fix for OS X Sierra that hungs in the codesign step
echo 'workaround for sierra'
security set-key-partition-list -S apple-tool:,apple: -s -k $CUSTOM_KEYCHAIN_PASSWORD ios-build.keychain > /dev/null

echo "Setting version info"
echo "BRANCH     =[$TRAVIS_BRANCH]"
echo "SHA        =[$TRAVIS_COMMIT]"

if [ -n "$TRAVIS_TAG" ]; then
    echo "This is a tag and means new version. Set the version with agvtool"
    
    shortSha=${TRAVIS_COMMIT: -7}
    version=${TRAVIS_TAG//.}
    mktversion="$TRAVIS_TAG"

    echo "TAG        =[$TRAVIS_TAG]"
    echo "VERSION    =[$version]"
    echo "MKTVERSION =[$mktversion]"
    echo "SHORTSHA   =[$shortSha]"
    
    agvtool new-version $version
    agvtool new-marketing-version "$mktversion"
    /usr/libexec/PlistBuddy -c "Set CFBundleVersion $mktversion" Timetracker/Info.plist

else
    echo "This is not a TAG, no need for setting version"

fi

echo 'creating archive'
xcodebuild archive -project Timetracker.xcodeproj -configuration Release -archivePath xcbuild/timetracker.xcarchive -scheme Timetracker

echo 'exporting archive'
xcodebuild -exportArchive -archivePath xcbuild/timetracker.xcarchive -exportPath xcbuild/output -project Timetracker.xcodeproj -configuration Release -exportOptionsPlist exportOptions.plist 

echo 'tarballing app'
pushd xcbuild/output
tar -czvf Timetracker.tar.gz Timetracker.app
popd
