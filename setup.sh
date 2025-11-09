#!/bin/bash

# OrbitHub Setup Script
# This script helps you set up OrbitHub quickly

set -e

echo "🚀 OrbitHub Setup"
echo "=================="
echo ""

# Check if Dart is installed
if ! command -v dart &> /dev/null; then
    echo "❌ Dart is not installed"
    echo "   Install from: https://dart.dev/get-dart"
    exit 1
fi

echo "✅ Dart is installed: $(dart --version 2>&1 | head -1)"
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
dart pub get
echo ""

# Check if .env exists
if [ -f ".env" ]; then
    echo "✅ .env file already exists"
else
    echo "📝 Creating .env file from template..."
    if [ -f "orbithub.env" ]; then
        cp orbithub.env .env
        echo "✅ Created .env from orbithub.env template"
    else
        cat > .env << 'EOF'
# Jira Configuration (Required)
JIRA_BASE_PATH=https://your-company.atlassian.net
JIRA_EMAIL=your-email@company.com
JIRA_API_TOKEN=your_api_token_here

# Optional Settings
JIRA_SEARCH_MAX_RESULTS=100
JIRA_LOGGING_ENABLED=false
EOF
        echo "✅ Created .env file"
    fi
    echo ""
    echo "⚠️  IMPORTANT: Edit .env file with your actual Jira credentials!"
    echo ""
    echo "   1. Open .env file in your editor"
    echo "   2. Replace 'your-company' with your Jira domain"
    echo "   3. Replace 'your-email@company.com' with your Jira email"
    echo "   4. Get API token from: https://id.atlassian.com/manage-profile/security/api-tokens"
    echo "   5. Replace 'your_api_token_here' with your actual API token"
    echo ""
fi

# Ask if user wants to build native executable
echo ""
read -p "📦 Build native executable? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔨 Building native executable..."
    dart compile exe bin/orbit.dart -o orbit
    echo "✅ Built: ./orbit"
    echo ""
    echo "   Run: ./orbit ticket --get PROJ-123"
    
    read -p "📂 Install to /usr/local/bin? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo mv orbit /usr/local/bin/
        echo "✅ Installed to /usr/local/bin/orbit"
        echo "   Run from anywhere: orbit ticket --get PROJ-123"
    fi
else
    echo "ℹ️  Skipped building executable"
    echo "   Run with: dart run bin/orbit.dart ticket --get PROJ-123"
fi

echo ""
echo "✨ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Edit .env file with your Jira credentials"
echo "  2. Test: dart run bin/orbit.dart ticket --get PROJ-123"
echo "  3. Read QUICKSTART.md for more examples"
echo ""

