#!/bin/bash
set -e
echo "Building iOS archive (requires macOS & Xcode)..."
flutter pub get
flutter build ipa -t lib/main.dart --export-method ad-hoc
echo "IPA file (if signed) will be in build/ios/ipa/"
