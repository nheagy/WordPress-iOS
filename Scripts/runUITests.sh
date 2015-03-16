#!/bin/sh

#checking if xcpretty is available to use
command -v xcpretty >/dev/null
if [ $? -eq 1 ]; then
echo >&2 "xcpretty needed in order to format test results."
fi
#run tests using iPhone 6 simulator on iOS 8
xcodebuild test \
     -workspace WordPress.xcworkspace \
     -scheme UITests \
     -sdk iphonesimulator8.2 \
     -destination 'platform=iOS Simulator,name=iPhone 6' | xcpretty -c
