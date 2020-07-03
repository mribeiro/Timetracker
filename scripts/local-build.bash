#!/bin/sh

echo 'starting script'

echo 'updating carthage dependencies'
carthage update --platform macOS

echo "Setting version info"

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


echo 'creating archive'
xcodebuild archive -project Timetracker.xcodeproj -configuration Release -archivePath xcbuild/timetracker.xcarchive -scheme Timetracker

echo 'exporting archive'
xcodebuild -exportArchive -archivePath xcbuild/timetracker.xcarchive -exportPath xcbuild/output -project Timetracker.xcodeproj -configuration Release -exportOptionsPlist exportOptions.plist 

echo 'tarballing app'
pushd xcbuild/output
tar -czvf Timetracker.tar.gz Timetracker.app
popd
