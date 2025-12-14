#!/bin/bash
# OrbitHub CLI Installation Script
# Usage: curl https://github.com/bogmanSDK/orbithub/releases/latest/download/install.sh -fsS | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO="bogmanSDK/orbithub"
INSTALL_DIR="$HOME/.orbithub"
BIN_DIR="$INSTALL_DIR/bin"
BINARY_NAME="orbithub"

# Helper functions
error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

info() {
    echo -e "${GREEN}$1${NC}"
}

warn() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

progress() {
    echo -e "${BLUE}$1${NC}"
}

# Detect platform
detect_platform() {
    local os=""
    local arch=""
    
    case "$(uname -s)" in
        Darwin*) os="darwin" ;;
        Linux*) os="linux" ;;
        CYGWIN*|MINGW*|MSYS*) os="windows" ;;
        *) error "Unsupported operating system: $(uname -s)" ;;
    esac
    
    case "$(uname -m)" in
        x86_64|amd64) arch="amd64" ;;
        arm64|aarch64) 
            # Use amd64 for ARM64 Macs (Rosetta 2 compatible)
            if [[ "$os" == "darwin" ]]; then
                arch="amd64"
            else
                arch="arm64"
            fi
            ;;
        *) error "Unsupported architecture: $(uname -m)" ;;
    esac
    
    # Return with hyphen for binary naming convention
    echo "${os}-${arch}"
}

# Get latest release version
get_latest_version() {
    progress "Fetching latest release information..." >&2
    local version
    local api_response
    local curl_exit_code
    
    # Try GitHub API with proper error handling
    api_response=$(curl -s --connect-timeout 10 --max-time 30 --fail "https://api.github.com/repos/${REPO}/releases/latest" 2>&1)
    curl_exit_code=$?
    
    if [ $curl_exit_code -eq 0 ] && [ -n "$api_response" ]; then
        version=$(echo "$api_response" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | head -1)
        
        if [ -n "$version" ]; then
            echo "$version"
            return 0
        fi
    fi
    
    # If GitHub API failed, try alternative approach with redirect
    progress "GitHub API failed (exit code: $curl_exit_code), trying redirect method..." >&2
    
    local redirect_response
    redirect_response=$(curl -s --connect-timeout 10 --max-time 30 --fail -I "https://github.com/${REPO}/releases/latest" 2>&1)
    curl_exit_code=$?
    
    if [ $curl_exit_code -eq 0 ] && [ -n "$redirect_response" ]; then
        version=$(echo "$redirect_response" | grep -i "location:" | sed -E 's/.*\/tag\/([^\/\r\n]+).*/\1/' | tr -d '\r\n')
        
        if [ -n "$version" ]; then
            echo "$version"
            return 0
        fi
    fi
    
    error "Failed to get latest version from GitHub API and redirect method.
    
Possible causes:
  - Network connectivity issues
  - GitHub API rate limiting
  - Repository access issues
  - curl version incompatibility

Debug information:
  - Last curl exit code: $curl_exit_code
  - API response: ${api_response:-'(empty)'}
  - Redirect response: ${redirect_response:-'(empty)'}
  
Please check your network connection and try again.
If the issue persists, you can manually download from:
https://github.com/${REPO}/releases/latest"
}

# Download file with progress
download_file() {
    local url="$1"
    local output="$2"
    local desc="$3"
    
    progress "Downloading $desc..."
    
    if command -v curl >/dev/null 2>&1; then
        curl -L --progress-bar "$url" -o "$output" || error "Failed to download $desc"
    elif command -v wget >/dev/null 2>&1; then
        wget --progress=bar "$url" -O "$output" || error "Failed to download $desc"
    else
        error "Neither curl nor wget is available. Please install one of them."
    fi
}

# Create installation directory
create_install_dir() {
    progress "Creating installation directory..."
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$BIN_DIR"
}

# Check Dart installation (optional - binary doesn't need Dart)
check_dart() {
    progress "Checking Dart installation..."
    
    if ! command -v dart >/dev/null 2>&1; then
        warn "Dart is not installed. OrbitHub binary works without Dart, but some features may require it."
        return 0
    fi
    
    info "Dart version: $(dart --version 2>&1 | head -n 1)"
}

# Download OrbitHub binary and assets
download_orbithub() {
    local version="$1"
    local platform="$2"
    local binary_url="https://github.com/${REPO}/releases/download/${version}/orbithub-${platform}"
    local binary_path="$BIN_DIR/$BINARY_NAME"
    
    # For Windows, add .exe extension
    if [[ "$platform" == *"windows"* ]]; then
        binary_url="${binary_url}.exe"
        binary_path="${binary_path}.exe"
    fi
    
    # Download binary
    download_file "$binary_url" "$binary_path" "OrbitHub binary"
    
    # Make binary executable (not needed for Windows, but harmless)
    chmod +x "$binary_path" 2>/dev/null || true
    
    # Create symlink without extension for convenience
    if [[ ! "$platform" == *"windows"* ]]; then
        if [ ! -L "$BIN_DIR/$BINARY_NAME" ] && [ ! -f "$BIN_DIR/$BINARY_NAME" ]; then
            ln -s "$binary_path" "$BIN_DIR/$BINARY_NAME" 2>/dev/null || cp "$binary_path" "$BIN_DIR/$BINARY_NAME"
        fi
    fi
    
    # Download asset directories (lib/prompts and agents)
    # These are required for the binary to work correctly
    # Assets are installed to $INSTALL_DIR (parent of bin directory)
    progress "Downloading asset directories..."
    
    # Create asset directories in install directory (parent of bin)
    mkdir -p "$INSTALL_DIR/lib/prompts"
    mkdir -p "$INSTALL_DIR/agents"
    
    # Download prompts directory files
    local prompts_url="https://github.com/${REPO}/releases/download/${version}/lib-prompts.tar.gz"
    local prompts_tmp=$(mktemp)
    
    if curl -sL --fail "$prompts_url" -o "$prompts_tmp"; then
        tar -xzf "$prompts_tmp" -C "$INSTALL_DIR" || error "Failed to extract prompts directory"
        rm -f "$prompts_tmp"
        info "Downloaded prompts directory"
    else
        error "Failed to download prompts directory from $prompts_url"
    fi
    
    # Download agents directory files
    local agents_url="https://github.com/${REPO}/releases/download/${version}/agents.tar.gz"
    local agents_tmp=$(mktemp)
    
    if curl -sL --fail "$agents_url" -o "$agents_tmp"; then
        tar -xzf "$agents_tmp" -C "$INSTALL_DIR" || error "Failed to extract agents directory"
        rm -f "$agents_tmp"
        info "Downloaded agents directory"
    else
        error "Failed to download agents directory from $agents_url"
    fi
    
    # Verify assets were installed correctly
    if [ ! -d "$INSTALL_DIR/lib/prompts" ] || [ -z "$(ls -A $INSTALL_DIR/lib/prompts 2>/dev/null)" ]; then
        error "Prompts directory not found or empty at $INSTALL_DIR/lib/prompts"
    fi
    
    if [ ! -d "$INSTALL_DIR/agents" ] || [ -z "$(ls -A $INSTALL_DIR/agents 2>/dev/null)" ]; then
        error "Agents directory not found or empty at $INSTALL_DIR/agents"
    fi
    
    info "Asset directories verified successfully"
}

# Update shell configuration
update_shell_config() {
    progress "Updating shell configuration..."
    
    local shell_configs=()
    
    # Detect shell and add appropriate config files
    case "$SHELL" in
        */bash)
            [ -f "$HOME/.bashrc" ] && shell_configs+=("$HOME/.bashrc")
            [ -f "$HOME/.bash_profile" ] && shell_configs+=("$HOME/.bash_profile")
            ;;
        */zsh)
            [ -f "$HOME/.zshrc" ] && shell_configs+=("$HOME/.zshrc")
            ;;
        */fish)
            mkdir -p "$HOME/.config/fish/conf.d"
            shell_configs+=("$HOME/.config/fish/conf.d/orbithub.fish")
            ;;
    esac
    
    # Add generic profile files if they exist
    [ -f "$HOME/.profile" ] && shell_configs+=("$HOME/.profile")
    
    local path_export="export PATH=\"$BIN_DIR:\$PATH\""
    
    for config in "${shell_configs[@]}"; do
        if [ -f "$config" ] || [[ "$config" == *".fish" ]]; then
            # Check if PATH is already added
            if ! grep -q "$BIN_DIR" "$config" 2>/dev/null; then
                echo "" >> "$config"
                echo "# Added by OrbitHub installer" >> "$config"
                if [[ "$config" == *".fish" ]]; then
                    echo "set -gx PATH $BIN_DIR \$PATH" >> "$config"
                else
                    echo "$path_export" >> "$config"
                fi
                info "Updated $config"
            else
                warn "$BIN_DIR already in PATH in $config"
            fi
        fi
    done
}

# Verify installation
verify_installation() {
    progress "Verifying installation..."
    
    local binary_path="$BIN_DIR/$BINARY_NAME"
    
    # Check if binary exists
    if [ ! -f "$binary_path" ] && [ ! -L "$binary_path" ]; then
        # Try with .exe extension for Windows
        binary_path="${binary_path}.exe"
        if [ ! -f "$binary_path" ]; then
            error "Binary file not found at $BIN_DIR"
        fi
    fi
    
    # Test the installation
    if "$binary_path" --version >/dev/null 2>&1; then
        info "OrbitHub CLI installed successfully!"
    else
        warn "Installation completed but orbithub command test failed. You may need to restart your shell."
    fi
}

# Print post-installation instructions
print_instructions() {
    echo ""
    info "🎉 OrbitHub CLI installation completed!"
    echo ""
    echo "To get started:"
    echo "  1. Restart your shell or run: source ~/.zshrc (or ~/.bashrc)"
    echo "  2. Run: orbithub --version"
    echo "  3. Run: orbithub --help"
    echo ""
    echo "Set up your environment variables:"
    echo "  export JIRA_BASE_PATH=https://your-domain.atlassian.net"
    echo "  export JIRA_EMAIL=your-email@domain.com"
    echo "  export JIRA_API_TOKEN=your-jira-api-token"
    echo "  export AI_API_KEY=your-ai-api-key"
    echo "  export CURSOR_API_KEY=your-cursor-api-key"
    echo ""
    echo "For more information, visit: https://github.com/${REPO}"
}

# Main installation function
main() {
    info "🚀 Installing OrbitHub CLI..."
    
    # Detect platform
    local platform
    platform=$(detect_platform)
    info "Detected platform: $platform"
    
    # Get latest version
    local version
    version=$(get_latest_version)
    info "Latest version: $version"
    
    # Create directories
    create_install_dir
    
    # Check Dart (optional)
    check_dart
    
    # Download OrbitHub
    download_orbithub "$version" "$platform"
    
    # Update shell configuration
    update_shell_config
    
    # Verify installation
    verify_installation
    
    # Print instructions
    print_instructions
}

# Run main function
main "$@"

