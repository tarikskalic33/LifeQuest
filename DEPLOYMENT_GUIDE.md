# LifeQuest App - Deployment Guide

## Overview
This guide provides comprehensive instructions for deploying the LifeQuest app across different platforms.

## Prerequisites

### Development Environment
- Flutter SDK 3.35.5 or later
- Dart SDK (included with Flutter)
- Android Studio (for Android builds)
- Xcode (for iOS builds, macOS only)
- VS Code or Android Studio IDE

### Platform-Specific Requirements

#### Android Deployment
- Android SDK (API level 21 or higher)
- Java Development Kit (JDK) 8 or later
- Android device or emulator for testing

#### iOS Deployment
- macOS development machine
- Xcode 12.0 or later
- iOS device or simulator for testing
- Apple Developer Account (for App Store distribution)

#### Web Deployment
- Chrome browser for testing
- Web server for hosting (optional)

## Build Instructions

### Android APK Build

#### Debug Build
```bash
flutter build apk --debug
```

#### Release Build
```bash
flutter build apk --release
```

#### Split APK by Architecture (Recommended for Play Store)
```bash
flutter build apk --split-per-abi
```

### iOS Build

#### Debug Build
```bash
flutter build ios --debug
```

#### Release Build
```bash
flutter build ios --release
```

### Web Build
```bash
flutter build web
```

## Configuration

### App Signing (Android)

1. **Generate Keystore**
```bash
keytool -genkey -v -keystore ~/lifequest-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lifequest
```

2. **Create key.properties**
Create `android/key.properties`:
```
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=lifequest
storeFile=<path-to-keystore>/lifequest-key.jks
```

3. **Update build.gradle**
Add to `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### App Icons and Splash Screen

#### Update App Icons
1. Replace icons in:
   - `android/app/src/main/res/mipmap-*/ic_launcher.png`
   - `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

2. Use flutter_launcher_icons package:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
```

#### Update Splash Screen
Use flutter_native_splash package:
```yaml
dev_dependencies:
  flutter_native_splash: ^2.3.2

flutter_native_splash:
  color: "#0B1021"
  image: assets/splash/splash_logo.png
  android_12:
    image: assets/splash/splash_logo.png
    color: "#0B1021"
```

## App Store Deployment

### Google Play Store (Android)

1. **Prepare Release Build**
```bash
flutter build appbundle --release
```

2. **Upload to Play Console**
   - Create developer account
   - Upload AAB file
   - Complete store listing
   - Set up pricing and distribution

3. **Required Assets**
   - App icon (512x512 PNG)
   - Feature graphic (1024x500 PNG)
   - Screenshots (phone, tablet, TV)
   - Privacy policy URL

### Apple App Store (iOS)

1. **Prepare Release Build**
```bash
flutter build ios --release
```

2. **Archive in Xcode**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select "Any iOS Device" as target
   - Product → Archive
   - Upload to App Store Connect

3. **Required Assets**
   - App icon (1024x1024 PNG)
   - Screenshots for all device sizes
   - App preview videos (optional)
   - Privacy policy and terms of service

## Web Deployment

### Static Hosting
Deploy the `build/web` folder to:
- Firebase Hosting
- Netlify
- Vercel
- GitHub Pages
- AWS S3 + CloudFront

### Firebase Hosting Example
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
firebase deploy
```

## Environment Configuration

### Production Environment Variables
Create `.env.production`:
```
API_BASE_URL=https://api.lifequest.app
ANALYTICS_ID=your-analytics-id
SENTRY_DSN=your-sentry-dsn
```

### Development vs Production
Use flutter_dotenv for environment management:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env.production");
  runApp(LifeQuestApp());
}
```

## Performance Optimization

### Build Optimization
```bash
# Enable obfuscation and minification
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Tree shaking for web
flutter build web --release --tree-shake-icons
```

### Asset Optimization
- Compress images using tools like TinyPNG
- Use vector graphics (SVG) where possible
- Implement lazy loading for large assets

## Security Considerations

### Code Obfuscation
Enable obfuscation for release builds:
```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

### API Security
- Use HTTPS for all API calls
- Implement certificate pinning
- Validate all user inputs
- Use secure storage for sensitive data

### Data Protection
- Encrypt local storage
- Implement proper session management
- Follow GDPR/CCPA compliance requirements

## Monitoring and Analytics

### Crash Reporting
Integrate Sentry or Firebase Crashlytics:
```yaml
dependencies:
  sentry_flutter: ^7.9.0
```

### Analytics
Implement Firebase Analytics or similar:
```yaml
dependencies:
  firebase_analytics: ^10.4.5
```

### Performance Monitoring
Use Firebase Performance Monitoring:
```yaml
dependencies:
  firebase_performance: ^0.9.2+5
```

## Continuous Integration/Deployment

### GitHub Actions Example
Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy LifeQuest App

on:
  push:
    branches: [ main ]

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '11'
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.35.5'
    - run: flutter pub get
    - run: flutter test
    - run: flutter build apk --release
    - uses: actions/upload-artifact@v3
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

## Testing Before Deployment

### Pre-deployment Checklist
- [ ] All tests passing
- [ ] App icons updated
- [ ] Splash screen configured
- [ ] Privacy policy implemented
- [ ] Terms of service added
- [ ] Analytics configured
- [ ] Crash reporting enabled
- [ ] Performance optimized
- [ ] Security review completed
- [ ] Store assets prepared

### Device Testing
Test on multiple devices:
- Different screen sizes
- Various Android/iOS versions
- Different performance levels
- Network conditions (WiFi, cellular, offline)

## Post-Deployment

### Monitoring
- Monitor crash reports
- Track user analytics
- Review app store ratings
- Monitor performance metrics

### Updates
- Plan regular feature updates
- Monitor for security vulnerabilities
- Keep dependencies updated
- Respond to user feedback

## Support and Maintenance

### User Support
- Set up help documentation
- Create FAQ section
- Implement in-app feedback
- Monitor app store reviews

### Maintenance Schedule
- Weekly: Monitor analytics and crashes
- Monthly: Update dependencies
- Quarterly: Performance review and optimization
- Annually: Security audit and major updates

---

For additional support or questions about deployment, please refer to the Flutter documentation or contact the development team.

