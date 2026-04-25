#!/bin/bash
# Bump iOS build number and Android versionCode
# Usage: ./scripts/bump_build.sh

set -e

# iOS — update CFBundleVersion in project.pbxproj
# TODO: update path once Xcode project is created
# IOS_PROJECT="ios/Hackathon/Hackathon.xcodeproj/project.pbxproj"

# Android — update versionCode in build.gradle.kts
# TODO: update path once Android project is created
# ANDROID_GRADLE="android/build.gradle.kts"

echo "bump_build.sh: update paths after Xcode/Gradle projects are created"
echo "Refer to DharmaGit/ios/scripts/update-version.sh for iOS pattern"
