#!/bin/bash
set -e
echo "Building Android release APK..."
flutter pub get
flutter build apk --release -t lib/main.dart
echo "Release APK built at build/app/outputs/flutter-apk/app-release.apk"
