#!/bin/sh

sleep 60

echo 'starting script'

# DECIPHER DEVELOPMENT CERTIFICATES

echo 'importing certificates'

openssl aes-256-cbc -k "$SECURITY_PASSWORD" -in scripts/certs/enc-development-cert.cer -d -a -out scripts/certs/development-cert.cer
openssl aes-256-cbc -k "$SECURITY_PASSWORD" -in scripts/certs/enc-development-key.p12 -d -a -out scripts/certs/development-key.p12

# Create custom keychain

# Create custom keychain
# security create-keychain -p $CUSTOM_KEYCHAIN_PASSWORD ios-build.keychain

# Make the ios-build.keychain default, so xcodebuild will use it
# security default-keychain -s ios-build.keychain

# Unlock the keychain
# security unlock-keychain -p $CUSTOM_KEYCHAIN_PASSWORD ios-build.keychain

# Set keychain timeout to 1 hour for long builds
security set-keychain-settings -t 3600 -l ~/Library/Keychains/ios-build.keychain

#security import ./scripts/certs/AppleWWDRCA.cer -k ios-build.keychain -A
#security import ./scripts/certs/enc-development-cert.cer -k ios-build.keychain -P $SECURITY_PASSWORD -A
#security import ./scripts/certs/enc-development-key.p12 -k ios-build.keychain -P $SECURITY_PASSWORD -A

# Fix for OS X Sierra that hungs in the codesign step
#security set-key-partition-list -S apple-tool:,apple: -s -k $SECURITY_PASSWORD ios-build.keychain > /dev/null

#xcodebuild archive -project Timetracker.xcodeproj -configuration Release -archivePath xcbuild/timetracker.xcarchive -scheme Timetracker

#xcodebuild -exportArchive -archivePath xcbuild/timetracker.xcarchive -exportPath xcbuild/output -project Timetracker.xcodeproj -configuration Release -exportOptionsPlist exportOptions.plist 


