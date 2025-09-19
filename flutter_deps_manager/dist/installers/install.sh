#!/bin/bash

# Flutter Dependencies Upgrade CLI - Web Installer
# One-line installation script for GitHub releases

set -euo pipefail

CLI_NAME="flutter-deps-upgrade"
VERSION="1.1.7"
GITHUB_REPO="your-username/flutter-deps-manager-project"  # Update this!
INSTALL_DIR="${FLUTTER_DEPS_INSTALL_DIR:-/usr/local}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "${CYAN}${BOLD}$1${NC}"; }

main() {
    print_header "🚀 Installing $CLI_NAME v$VERSION"
    
    # Check requirements
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        print_error "Either curl or wget is required for installation"
        exit 1
    fi
    
    if ! command -v tar >/dev/null 2>&1; then
        print_error "tar is required for installation"
        exit 1
    fi
    
    # Detect platform
    local platform=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)
    local archive_name="${CLI_NAME}-${VERSION}.tar.gz"
    local download_url="https://github.com/$GITHUB_REPO/releases/download/v$VERSION/$archive_name"
    
    print_info "Platform: $platform $arch"
    print_info "Download URL: $download_url"
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    local archive_file="$temp_dir/$archive_name"
    
    # Download archive
    print_info "📥 Downloading $CLI_NAME v$VERSION..."
    if command -v curl >/dev/null 2>&1; then
        if ! curl -fsSL "$download_url" -o "$archive_file"; then
            print_error "Failed to download from GitHub releases"
            print_info "Make sure the release exists: https://github.com/$GITHUB_REPO/releases/tag/v$VERSION"
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -q "$download_url" -O "$archive_file"; then
            print_error "Failed to download from GitHub releases"
            exit 1
        fi
    fi
    
    # Extract archive
    print_info "📦 Extracting archive..."
    cd "$temp_dir"
    tar -xzf "$archive_file"
    
    # Find extracted directory
    local extracted_dir=$(find . -maxdepth 1 -type d -name "${CLI_NAME}-*" | head -1)
    if [[ -z "$extracted_dir" ]]; then
        print_error "Could not find extracted directory"
        exit 1
    fi
    
    # Install using bundled installer
    print_info "🔧 Installing using bundled installer..."
    cd "$extracted_dir"
    
    if [[ -f "install-cli.sh" ]]; then
        ./install-cli.sh global --prefix "$INSTALL_DIR"
    else
        print_error "Installation script not found in package"
        exit 1
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
    
    print_success "🎉 Installation completed!"
    print_info "Usage: $CLI_NAME --help"
}

main "$@"
