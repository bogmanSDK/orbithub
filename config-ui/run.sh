#!/bin/bash
# Run OrbitHub Config UI Flutter App on macOS

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting OrbitHub Config UI...${NC}"

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install/macos"
    exit 1
fi

# Check Flutter doctor (quick check)
echo -e "${BLUE}📋 Checking Flutter setup...${NC}"
if ! flutter doctor --version &> /dev/null; then
    echo "❌ Flutter is not properly configured"
    exit 1
fi

# Get dependencies
echo -e "${BLUE}📦 Getting Flutter dependencies...${NC}"
flutter pub get

# Run the app
echo -e "${GREEN}🎯 Launching app on macOS...${NC}"
echo -e "${BLUE}   (This may take a minute on first run)${NC}"
flutter run -d macos

