#!/bin/bash

# Flutter Code Cleanup Script for Play Store Release

echo "🧹 Starting code cleanup for Play Store release..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "\n${BLUE}==== $1 ====${NC}\n"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: Please run this script from the Flutter project root directory${NC}"
    exit 1
fi

print_step "Step 1: Removing debug print statements"

# Remove print statements from production code
find lib -name "*.dart" -type f -exec sed -i 's/^[[:space:]]*print(/\/\/ print(/g' {} \;

echo -e "${GREEN}✅ Debug print statements commented out${NC}"

print_step "Step 2: Fixing deprecated withOpacity usage"

# Replace withOpacity with withValues
find lib -name "*.dart" -type f -exec sed -i 's/\.withOpacity(\([^)]*\))/\.withValues(alpha: \1)/g' {} \;

echo -e "${GREEN}✅ Fixed withOpacity deprecation warnings${NC}"

print_step "Step 3: Fixing WillPopScope deprecation"

# Replace WillPopScope with PopScope (this is a more complex replacement, so we'll do it manually for critical files)
echo -e "${YELLOW}Note: WillPopScope -> PopScope requires manual review. Check these files:${NC}"
grep -r "WillPopScope" lib/ || echo "No WillPopScope found"

print_step "Step 4: Running dart fix for automatic fixes"

# Use dart fix to automatically fix many linting issues
dart fix --apply

echo -e "${GREEN}✅ Applied automatic dart fixes${NC}"

print_step "Step 5: Formatting code"

# Format all Dart files
dart format lib/

echo -e "${GREEN}✅ Code formatted${NC}"

print_step "Step 6: Running analysis again"

# Run flutter analyze to see remaining issues
flutter analyze

echo -e "\n${YELLOW}📝 Manual fixes still needed:${NC}"
echo "1. Review WillPopScope -> PopScope changes"
echo "2. Check use_build_context_synchronously warnings"
echo "3. Remove unused imports"
echo "4. Add const constructors where suggested"

echo -e "\n🎉 Automated cleanup completed!"
echo -e "${GREEN}Most critical issues have been fixed automatically.${NC}"
echo -e "${YELLOW}Please review the remaining warnings and fix manually if needed.${NC}"
