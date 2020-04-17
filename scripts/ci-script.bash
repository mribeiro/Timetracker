#!/bin/sh

sleep 30

echo 'starting script'

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


shortSha=${TRAVIS_GIT: -7}
version=${TRAVIS_TAG\\.}
mktversion="$TRAVIS_TAG ($shortSha)"

echo "Setting version info"
echo "BRANCH     =[$TRAVIS_BRANCH]"
echo "TAG        =[$TRAVIS_TAG]"
echo "SHA        =[$TRAVIS_COMMIT]"
echo "SHORTSHA   =[$shortSha]"
echo "VERSION    =[$version]"
echo "MKTVERSION =[$mktversion]"

if [ -n "$TRAVIS_TAG" ]; then
    echo "This is a tag and means new version. Set the version with agvtool"
    agvtool new-version $version
    agvtool new-marketing-version $mktversion
fi

echo 'creating archive'
xcodebuild archive -project Timetracker.xcodeproj -configuration Release -archivePath xcbuild/timetracker.xcarchive -scheme Timetracker

echo 'exporting archive'
xcodebuild -exportArchive -archivePath xcbuild/timetracker.xcarchive -exportPath xcbuild/output -project Timetracker.xcodeproj -configuration Release -exportOptionsPlist exportOptions.plist 

echo 'zipping app'
pushd xcbuild/output
zip -r Timetracker.$TRAVIS_TAG.zip Timetracker.app
popd
