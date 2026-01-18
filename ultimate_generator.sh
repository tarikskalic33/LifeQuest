#!/bin/bash
# LifeQuest - Ultimate File Generator
# Creates ALL production files in proper structure
# Run this in your Life-Quest-Alpha directory

set -e

echo "🎮 LifeQuest - Ultimate File Generator"
echo "======================================"
echo ""
echo "This will create ALL files needed for production."
echo "Run this script in your Life-Quest-Alpha directory."
echo ""
read -p "Current directory: $(pwd) - Is this correct? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please cd to your Life-Quest-Alpha directory first."
    exit 1
fi

echo ""
echo "Creating directory structure..."

# Create all directories
mkdir -p docs
mkdir -p .github/ISSUE_TEMPLATE
mkdir -p .github/workflows
mkdir -p android/app/src/main/res/xml
mkdir -p assets/icon
mkdir -p assets/images

echo "✓ Directories created"
echo ""
echo "Generating all files..."

# ==========================================
# ROOT DIRECTORY FILES
# ==========================================

cat > README.md << 'EOF'
# LifeQuest - Gamified Life Coach App

<div align="center">
  <img src="https://img.shields.io/badge/Platform-Android-green.svg"/>
  <img src="https://img.shields.io/badge/Flutter-3.24.0-blue.svg"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg"/>
  <img src="https://img.shields.io/badge/Status-Production-brightgreen.svg"/>
</div>

<div align="center">
  <h3>🎮 Transform your daily habits into an epic RPG adventure</h3>
  <p>AI-powered gamified life coach turning self-improvement into quests</p>
  <br/>
  <a href="https://tarikskalic33.github.io/Life-Quest-Alpha/">🌐 Website</a> •
  <a href="#features">✨ Features</a> •
  <a href="#download">📱 Download</a>
</div>

## 🎮 Features

- **Dynamic Quest System** - Daily quests across 6 life categories
- **AI Mentor System** - 5 unique mentor personalities
- **Achievement System** - 17+ achievements to unlock
- **RPG Progression** - Level up and track stats
- **Streak Rewards** - Bonus XP for consistency

## 🚀 Getting Started

```bash
git clone https://github.com/tarikskalic33/Life-Quest-Alpha.git
cd Life-Quest-Alpha
flutter pub get
flutter run
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

<div align="center">
  <p>Made with ❤️ for personal growth</p>
  <p><strong>Transform your life, one quest at a time! 🎮✨</strong></p>
</div>
EOF

cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 LifeQuest

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

cat > CONTRIBUTING.md << 'EOF'
# Contributing to LifeQuest

Thank you for your interest in contributing!

## Getting Started

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Development Setup

```bash
git clone YOUR_FORK_URL
cd Life-Quest-Alpha
flutter pub get
flutter run
```

## Guidelines

- Follow Dart style guide
- Add tests for new features
- Update documentation
- Keep commits clean and descriptive

## Code of Conduct

Be respectful, inclusive, and constructive in all interactions.

For full guidelines, see our documentation.
EOF

cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to LifeQuest will be documented in this file.

## [1.0.0] - 2025-10-29

### Added
- Initial release with full feature set
- Dynamic quest system across 6 categories
- AI mentor with 5 unique personalities
- 17+ achievement system
- RPG progression and leveling
- Streak tracking and rewards
- Local data persistence
- Modern UI with animations

### Technical
- Built with Flutter 3.24.0
- Provider state management
- ProGuard optimization
- Security hardening
- Comprehensive documentation
EOF

cat > KEYSTORE_SETUP.md << 'EOF'
# Keystore Setup Guide

## Generate Keystore

```bash
cd android
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Enter a strong password and save it securely!

## Create key.properties

Create file: `android/key.properties`

```properties
storePassword=YOUR_PASSWORD_HERE
keyPassword=YOUR_PASSWORD_HERE
keyAlias=upload
storeFile=upload-keystore.jks
```

## CRITICAL: Backup!

⚠️ Without this keystore, you CANNOT update your app on Play Store!

Backup to:
- Cloud storage (Dropbox, Google Drive)
- External USB drive
- Password manager

## Add to .gitignore

Ensure these lines are in `.gitignore`:

```
*.jks
*.keystore
key.properties
```

Never commit your keystore to Git!
EOF

cat > .gitignore << 'EOF'
# Flutter/Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
*.lock

# Android
*.iml
*.class
*.log
.gradle/
local.properties
android/.gradle/
android/captures/
android/gradlew
android/gradlew.bat
android/local.properties
android/app/debug
android/app/profile
android/app/release

# Keystore files - NEVER COMMIT!
*.jks
*.keystore
key.properties
android/key.properties
android/upload-keystore.jks
android/app/upload-keystore.jks

# iOS
*.mode1v3
*.mode2v3
*.moved-aside
*.pbxuser
*.perspectivev3
**/*sync/
.sconsign.dblite
.tags*
**/.vagrant/
**/DerivedData/
Icon?
**/Pods/
**/.symlinks/
profile
xcuserdata
**/.generated/
Flutter/App.framework
Flutter/Flutter.framework
Flutter/Flutter.podspec
Flutter/Generated.xcconfig
Flutter/ephemeral/
Flutter/app.flx
Flutter/app.zip
Flutter/flutter_assets/
Flutter/flutter_export_environment.sh
ServiceDefinitions.json
Runner/GeneratedPluginRegistrant.*

# IDE
.idea/
*.swp
*.swo
*~
.vscode/

# Deployment
deployment_*/
*.zip
*.tar.gz

# OS
.DS_Store
Thumbs.db
EOF

# ==========================================
# PUBSPEC.YAML (COMPLETE REPLACEMENT)
# ==========================================

cat > pubspec.yaml << 'EOF'
name: lifequest_app
description: A gamified life coach app that turns self-improvement into an RPG adventure.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  http: ^1.1.2
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  min_sdk_android: 21
  adaptive_icon_background: "#0B1021"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
  remove_alpha_ios: true

flutter:
  uses-material-design: true
  assets:
    - assets/icon/
    - assets/images/
EOF

# ==========================================
# ANDROID FILES
# ==========================================

cat > android/app/build.gradle << 'EOF'
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0.0'
}

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace "com.tarikskalic.lifequest"
    compileSdk 34
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.tarikskalic.lifequest"
        minSdk 21
        targetSdk 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true
        resValue "string", "app_name", "LifeQuest"
    }

    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
                storePassword keystoreProperties['storePassword']
            }
        }
    }

    buildTypes {
        release {
            signingConfig keystorePropertiesFile.exists() ? signingConfigs.release : signingConfigs.debug
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    buildFeatures {
        buildConfig true
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation 'androidx.multidex:multidex:2.0.1'
}
EOF

cat > android/app/proguard-rules.pro << 'EOF'
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }

# Your models
-keep class com.tarikskalic.lifequest.** { *; }

# Keep line numbers
-keepattributes SourceFile,LineNumberTable

# Remove logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}
EOF

cat > android/app/src/main/AndroidManifest.xml << 'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    
    <application
        android:label="LifeQuest"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:allowBackup="false"
        android:fullBackupContent="false"
        android:usesCleartextTraffic="false"
        android:networkSecurityConfig="@xml/network_security_config">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize"
            android:screenOrientation="portrait">
            
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
EOF

cat > android/app/src/main/res/xml/network_security_config.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
EOF

# ==========================================
# GITHUB TEMPLATES
# ==========================================

cat > .github/ISSUE_TEMPLATE/bug_report.md << 'EOF'
---
name: Bug Report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
---

## Bug Description
Describe the bug clearly.

## To Reproduce
Steps:
1. Go to '...'
2. Click on '...'
3. See error

## Expected Behavior
What should happen.

## Environment
- Device: [e.g. Pixel 6]
- OS: [e.g. Android 13]
- App Version: [e.g. 1.0.0]

## Screenshots
If applicable.
EOF

cat > .github/ISSUE_TEMPLATE/feature_request.md << 'EOF'
---
name: Feature Request
about: Suggest an idea
title: '[FEATURE] '
labels: enhancement
---

## Feature Description
Describe the feature.

## Problem it Solves
What problem does this address?

## Proposed Solution
How should it work?

## Additional Context
Any other information.
EOF

cat > .github/pull_request_template.md << 'EOF'
## Description
Describe your changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation

## Testing
- [ ] Tests pass
- [ ] Tested on Android

## Checklist
- [ ] Code follows style guide
- [ ] Documentation updated
- [ ] All tests passing
EOF

# ==========================================
# WEBSITE FILES
# ==========================================

cat > docs/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LifeQuest - Transform Your Life</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #0B1021, #1a1f3a);
            color: #E6E9FF;
        }
        .container { max-width: 1200px; margin: 0 auto; padding: 40px 20px; }
        h1 {
            text-align: center;
            font-size: 3em;
            margin: 40px 0 20px;
            background: linear-gradient(135deg, #7C5CFF, #00E0A4);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .tagline {
            text-align: center;
            font-size: 1.3em;
            color: #8B92B8;
            margin-bottom: 40px;
        }
        .cta {
            text-align: center;
            margin: 40px 0;
        }
        .btn {
            display: inline-block;
            padding: 15px 40px;
            background: linear-gradient(135deg, #7C5CFF, #9D7FFF);
            color: white;
            text-decoration: none;
            border-radius: 10px;
            margin: 10px;
            font-weight: 600;
        }
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 30px;
            margin-top: 60px;
        }
        .feature {
            background: rgba(255, 255, 255, 0.05);
            padding: 30px;
            border-radius: 15px;
            border: 1px solid rgba(124, 92, 255, 0.2);
        }
        .feature h3 { color: #00E0A4; margin-bottom: 10px; }
        .feature p { color: #C4CFFF; line-height: 1.6; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎮 LifeQuest</h1>
        <p class="tagline">Transform Your Life Into An RPG Adventure</p>
        
        <div class="cta">
            <a href="#" class="btn">Coming Soon to Google Play</a>
            <a href="https://github.com/tarikskalic33/Life-Quest-Alpha" class="btn">View on GitHub</a>
        </div>
        
        <div class="features">
            <div class="feature">
                <h3>⚔️ Dynamic Quests</h3>
                <p>Complete daily quests across 6 life categories and earn XP for your achievements.</p>
            </div>
            <div class="feature">
                <h3>🤖 AI Mentors</h3>
                <p>Choose from 5 mentor personalities providing personalized guidance.</p>
            </div>
            <div class="feature">
                <h3>🏆 Achievements</h3>
                <p>Unlock 17+ achievements and earn prestigious titles as you progress.</p>
            </div>
            <div class="feature">
                <h3>📈 Level Up</h3>
                <p>Track your growth with RPG-style stats and progression systems.</p>
            </div>
        </div>
    </div>
</body>
</html>
HTMLEOF

cat > docs/privacy-policy.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LifeQuest - Privacy Policy</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 40px 20px;
            line-height: 1.8;
            background: #0B1021;
            color: #E6E9FF;
        }
        h1 { color: #7C5CFF; margin-bottom: 10px; }
        h2 { color: #00E0A4; margin-top: 30px; }
        p { margin-bottom: 15px; }
        a { color: #7C5CFF; }
    </style>
</head>
<body>
    <h1>Privacy Policy for LifeQuest</h1>
    <p><strong>Last Updated: October 29, 2025</strong></p>
    
    <h2>Introduction</h2>
    <p>LifeQuest respects your privacy. All data is stored locally on your device.</p>
    
    <h2>Data Collection</h2>
    <p>We collect only what you input: quests, achievements, stats, and mentor interactions. All data remains on your device.</p>
    
    <h2>Data Storage</h2>
    <p>All data is stored locally using secure storage mechanisms. No data is transmitted to external servers.</p>
    
    <h2>Data Sharing</h2>
    <p>We do not sell, rent, or share your data with third parties.</p>
    
    <h2>Your Rights</h2>
    <p>You can delete all data by uninstalling the app or using in-app delete features.</p>
    
    <h2>Contact</h2>
    <p>Questions? Contact us via <a href="https://github.com/tarikskalic33/Life-Quest-Alpha/issues">GitHub Issues</a></p>
    
    <p style="margin-top: 40px;"><a href="index.html">← Back to Home</a></p>
</body>
</html>
HTMLEOF

# ==========================================
# SCRIPTS
# ==========================================

cat > deploy.sh << 'SCRIPTEOF'
#!/bin/bash
set -e

echo "🚀 Building LifeQuest for production..."

flutter clean
flutter pub get
flutter analyze
flutter build apk --release
flutter build appbundle --release

echo "✅ Build complete!"
echo "APK: build/app/outputs/flutter-apk/app-release.apk"
echo "AAB: build/app/outputs/bundle/release/app-release.aab"
SCRIPTEOF

chmod +x deploy.sh

# ==========================================
# COMPLETION
# ==========================================

echo ""
echo "=========================================="
echo "✅ ALL FILES GENERATED SUCCESSFULLY!"
echo "=========================================="
echo ""
echo "📁 Files Created:"
echo "  ✓ README.md"
echo "  ✓ LICENSE"
echo "  ✓ CONTRIBUTING.md"
echo "  ✓ CHANGELOG.md"
echo "  ✓ KEYSTORE_SETUP.md"
echo "  ✓ .gitignore (updated)"
echo "  ✓ pubspec.yaml (replaced)"
echo "  ✓ android/app/build.gradle (replaced)"
echo "  ✓ android/app/proguard-rules.pro"
echo "  ✓ android/app/src/main/AndroidManifest.xml (replaced)"
echo "  ✓ android/app/src/main/res/xml/network_security_config.xml"
echo "  ✓ .github/ISSUE_TEMPLATE/bug_report.md"
echo "  ✓ .github/ISSUE_TEMPLATE/feature_request.md"
echo "  ✓ .github/pull_request_template.md"
echo "  ✓ docs/index.html"
echo "  ✓ docs/privacy-policy.html"
echo "  ✓ deploy.sh"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Create app icon:"
echo "   - Design 1024x1024px icon"
echo "   - Save to: assets/icon/app_icon.png"
echo ""
echo "2. Generate icons:"
echo "   flutter pub get"
echo "   flutter pub run flutter_launcher_icons"
echo ""
echo "3. Generate keystore (see KEYSTORE_SETUP.md):"
echo "   cd android"
echo "   keytool -genkey -v -keystore upload-keystore.jks \\"
echo "     -keyalg RSA -keysize 2048 -validity 10000 -alias upload"
echo ""
echo "4. Build for production:"
echo "   ./deploy.sh"
echo ""
echo "5. Enable GitHub Pages:"
echo "   Settings → Pages → Source: main → Folder: /docs"
echo ""
echo "🎉 Your app is now production-ready!"
echo ""
echo "To create a ZIP of your project:"
echo "  cd .."
echo "  zip -r lifequest-complete.zip Life-Quest-Alpha -x '*/build/*' '*/.*'"
echo ""