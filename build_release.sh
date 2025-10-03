#!/bin/bash

# Cake Shop Mobile App Build Script for Play Store

echo "🎂 Building Denzel's Cakes Mobile App for Play Store Release..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: Please run this script from the Flutter project root directory${NC}"
    exit 1
fi

# Function to print step headers
print_step() {
    echo -e "\n${YELLOW}==== $1 ====${NC}\n"
}

# Step 1: Clean previous builds
print_step "Cleaning previous builds"
flutter clean
flutter pub get

# Step 2: Check for keystore
print_step "Checking keystore configuration"
if [ ! -f "android/key.properties" ]; then
    echo -e "${RED}Error: android/key.properties not found!${NC}"
    echo "Please create your keystore first:"
    echo "keytool -genkey -v -keystore android/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cakeshop-key"
    exit 1
fi

if [ ! -f "android/key.jks" ]; then
    echo -e "${RED}Error: android/key.jks not found!${NC}"
    echo "Please create your keystore first:"
    echo "keytool -genkey -v -keystore android/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cakeshop-key"
    exit 1
fi

# Step 3: Run tests
print_step "Running tests"
flutter test

if [ $? -ne 0 ]; then
    echo -e "${RED}Tests failed! Please fix them before building for release.${NC}"
    exit 1
fi

# Step 4: Analyze code
print_step "Analyzing code"
flutter analyze

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}Warning: Code analysis found issues. Consider fixing them.${NC}"
fi

# Step 5: Build release APK
print_step "Building release APK"
flutter build apk --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ APK built successfully!${NC}"
    echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
else
    echo -e "${RED}❌ APK build failed!${NC}"
    exit 1
fi

# Step 6: Build App Bundle (recommended for Play Store)
print_step "Building App Bundle (AAB)"
flutter build appbundle --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ App Bundle built successfully!${NC}"
    echo "AAB location: build/app/outputs/bundle/release/app-release.aab"
else
    echo -e "${RED}❌ App Bundle build failed!${NC}"
    exit 1
fi

# Step 7: Build size analysis
print_step "Analyzing build size"
flutter build apk --analyze-size --release

print_step "Build Summary"
echo -e "${GREEN}✅ Release builds completed successfully!${NC}"
echo ""
echo "📱 APK: build/app/outputs/flutter-apk/app-release.apk"
echo "📦 AAB: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "1. Test the release APK on a physical device"
echo "2. Upload the AAB file to Google Play Console"
echo "3. Fill out store listing information"
echo "4. Set up content rating and pricing"
echo "5. Submit for review"

echo -e "\n🎉 Ready for Play Store submission!"
