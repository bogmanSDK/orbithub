#!/bin/bash
# Test validation script for theme implementation
# Run this script in a Flutter-enabled environment

echo "Theme Implementation Test Suite"
echo "================================"

cd "$(dirname "$0")/config-ui"

echo ""
echo "1. Getting Flutter dependencies..."
flutter pub get

echo ""
echo "2. Running theme-related unit tests..."
flutter test test/models/config_model_theme_test.dart
flutter test test/services/config_service_theme_test.dart
flutter test test/providers/theme_provider_test.dart
flutter test test/theme/app_theme_test.dart

echo ""
echo "3. Running all tests..."
flutter test

echo ""
echo "4. Analyzing code..."
flutter analyze

echo ""
echo "5. Building app (if possible)..."
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Building macOS app..."
  cd config-ui && flutter build macos
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  echo "Building Windows app..."
  cd config-ui && flutter build windows
else
  echo "Skipping build - no supported platform detected"
fi

echo ""
echo "================================"
echo "Theme implementation tests completed!"
