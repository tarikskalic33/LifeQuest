#!/bin/bash

# LifeQuest App Build Script
# This script automates the build process for different platforms

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    print_status "Flutter version:"
    flutter --version
}

# Function to clean and get dependencies
prepare_build() {
    print_status "Cleaning previous builds..."
    flutter clean
    
    print_status "Getting dependencies..."
    flutter pub get
    
    print_status "Running code analysis..."
    flutter analyze
    
    if [ $? -ne 0 ]; then
        print_error "Code analysis failed. Please fix the issues before building."
        exit 1
    fi
    
    print_success "Code analysis passed!"
}

# Function to run tests
run_tests() {
    print_status "Running tests..."
    flutter test
    
    if [ $? -ne 0 ]; then
        print_warning "Some tests failed, but continuing with build..."
    else
        print_success "All tests passed!"
    fi
}

# Function to build Android APK
build_android() {
    print_status "Building Android APK..."
    
    # Check if Android SDK is available
    if ! command -v android &> /dev/null && [ -z "$ANDROID_HOME" ]; then
        print_warning "Android SDK not found. Skipping Android build."
        return 1
    fi
    
    # Build debug APK
    print_status "Building debug APK..."
    flutter build apk --debug
    
    if [ $? -eq 0 ]; then
        print_success "Debug APK built successfully!"
        print_status "Location: build/app/outputs/flutter-apk/app-debug.apk"
    else
        print_error "Debug APK build failed!"
        return 1
    fi
    
    # Build release APK if keystore is available
    if [ -f "android/key.properties" ]; then
        print_status "Building release APK..."
        flutter build apk --release
        
        if [ $? -eq 0 ]; then
            print_success "Release APK built successfully!"
            print_status "Location: build/app/outputs/flutter-apk/app-release.apk"
        else
            print_error "Release APK build failed!"
            return 1
        fi
    else
        print_warning "No keystore found. Skipping release APK build."
        print_status "To build release APK, create android/key.properties file."
    fi
}

# Function to build iOS
build_ios() {
    print_status "Building iOS app..."
    
    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_warning "iOS builds are only supported on macOS. Skipping iOS build."
        return 1
    fi
    
    # Check if Xcode is installed
    if ! command -v xcodebuild &> /dev/null; then
        print_warning "Xcode not found. Skipping iOS build."
        return 1
    fi
    
    # Build iOS
    flutter build ios --debug --no-codesign
    
    if [ $? -eq 0 ]; then
        print_success "iOS build completed successfully!"
        print_status "Open ios/Runner.xcworkspace in Xcode to archive and distribute."
    else
        print_error "iOS build failed!"
        return 1
    fi
}

# Function to build web
build_web() {
    print_status "Building web app..."
    
    flutter build web --release
    
    if [ $? -eq 0 ]; then
        print_success "Web build completed successfully!"
        print_status "Location: build/web/"
        print_status "You can serve this directory with any web server."
    else
        print_error "Web build failed!"
        return 1
    fi
}

# Function to create build summary
create_summary() {
    print_status "Build Summary:"
    echo "=================================="
    
    if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
        echo "✅ Android Debug APK: build/app/outputs/flutter-apk/app-debug.apk"
    fi
    
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        echo "✅ Android Release APK: build/app/outputs/flutter-apk/app-release.apk"
    fi
    
    if [ -d "build/ios" ]; then
        echo "✅ iOS Build: build/ios/"
    fi
    
    if [ -d "build/web" ]; then
        echo "✅ Web Build: build/web/"
    fi
    
    echo "=================================="
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -a, --android     Build Android APK"
    echo "  -i, --ios         Build iOS app (macOS only)"
    echo "  -w, --web         Build web app"
    echo "  -A, --all         Build for all platforms"
    echo "  --no-test         Skip running tests"
    echo "  --no-clean        Skip cleaning before build"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --android              # Build Android APK only"
    echo "  $0 --all                  # Build for all platforms"
    echo "  $0 --android --no-test    # Build Android without running tests"
}

# Main script logic
main() {
    local build_android_flag=false
    local build_ios_flag=false
    local build_web_flag=false
    local run_tests_flag=true
    local clean_flag=true
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--android)
                build_android_flag=true
                shift
                ;;
            -i|--ios)
                build_ios_flag=true
                shift
                ;;
            -w|--web)
                build_web_flag=true
                shift
                ;;
            -A|--all)
                build_android_flag=true
                build_ios_flag=true
                build_web_flag=true
                shift
                ;;
            --no-test)
                run_tests_flag=false
                shift
                ;;
            --no-clean)
                clean_flag=false
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # If no specific platform is selected, show usage
    if [ "$build_android_flag" = false ] && [ "$build_ios_flag" = false ] && [ "$build_web_flag" = false ]; then
        print_error "No build target specified."
        show_usage
        exit 1
    fi
    
    print_status "Starting LifeQuest App build process..."
    
    # Check Flutter installation
    check_flutter
    
    # Prepare build environment
    if [ "$clean_flag" = true ]; then
        prepare_build
    fi
    
    # Run tests if requested
    if [ "$run_tests_flag" = true ]; then
        run_tests
    fi
    
    # Build for requested platforms
    if [ "$build_android_flag" = true ]; then
        build_android
    fi
    
    if [ "$build_ios_flag" = true ]; then
        build_ios
    fi
    
    if [ "$build_web_flag" = true ]; then
        build_web
    fi
    
    # Create build summary
    create_summary
    
    print_success "Build process completed!"
}

# Run main function with all arguments
main "$@"

