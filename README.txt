LifeQuest - Demo project (preconfigured)

How to run locally (dev):
1. Install Flutter SDK: https://flutter.dev/docs/get-started/install
2. Unzip this project and cd into it.
3. Run:
   flutter pub get
   flutter run

Build Android APK (release):
1. Make sure you have Android SDK set up.
2. Run (on any OS):
   chmod +x build_android.sh
   ./build_android.sh
3. The release APK will be at: build/app/outputs/flutter-apk/app-release.apk

Build iOS IPA (requires macOS & Xcode):
1. Run on macOS with Xcode installed:
   chmod +x build_ios.sh
   ./build_ios.sh
2. You must have signing set in Xcode or an Apple developer account configured.
3. The IPA will be in build/ios/ipa/ if build succeeds.

Notes:
- This project is a demo. For production, set bundle IDs and signing in the native projects.
- If you want, I can also create GitHub Actions to build these automatically on push.
