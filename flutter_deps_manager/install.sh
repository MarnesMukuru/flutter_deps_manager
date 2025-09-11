#!/bin/bash

# Flutter Dependencies Upgrade CLI - Web Installer
# One-line installation script for GitHub releases

set -euo pipefail

CLI_NAME="flutter-deps-upgrade"
VERSION="1.0.0"  # This will be updated by GitHub Actions
GITHUB_REPO="MarnesMukuru/flutter_deps_manager"
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

show_usage() {
    cat << EOF
${BOLD}Flutter Dependencies Upgrade CLI - Web Installer${NC}

${BOLD}USAGE:${NC}
    curl -fsSL https://raw.githubusercontent.com/$GITHUB_REPO/main/install.sh | bash
    wget -qO- https://raw.githubusercontent.com/$GITHUB_REPO/main/install.sh | bash

${BOLD}OPTIONS:${NC}
    Environment variables you can set:
    
    FLUTTER_DEPS_INSTALL_DIR    Installation directory (default: /usr/local)
                               Examples: ~/.local, /opt/flutter-deps
    
${BOLD}EXAMPLES:${NC}
    # Standard installation
    curl -fsSL https://raw.githubusercontent.com/$GITHUB_REPO/main/install.sh | bash
    
    # Install to custom location
    export FLUTTER_DEPS_INSTALL_DIR=~/.local
    curl -fsSL https://raw.githubusercontent.com/$GITHUB_REPO/main/install.sh | bash
    
    # Install with sudo (for system-wide installation)
    curl -fsSL https://raw.githubusercontent.com/$GITHUB_REPO/main/install.sh | sudo bash

EOF
}

main() {
    # Handle help flag
    for arg in "$@"; do
        case "$arg" in
            -h|--help)
                show_usage
                exit 0
                ;;
        esac
    done
    
    print_header "🚀 Installing $CLI_NAME v$VERSION"
    
    # Check requirements
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        print_error "Either curl or wget is required for installation"
        print_info "Please install one of them and try again:"
        print_info "  macOS: brew install curl"
        print_info "  Ubuntu/Debian: apt-get install curl"
        print_info "  CentOS/RHEL: yum install curl"
        exit 1
    fi
    
    if ! command -v tar >/dev/null 2>&1; then
        print_error "tar is required for installation"
        print_info "Please install tar and try again"
        exit 1
    fi
    
    if ! command -v flutter >/dev/null 2>&1; then
        print_warning "Flutter is not installed or not in PATH"
        print_info "Please install Flutter first: https://flutter.dev/docs/get-started/install"
        print_info "Installation will continue, but the CLI won't work without Flutter"
    fi
    
    # Detect platform
    local platform=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)
    local archive_name="${CLI_NAME}-${VERSION}.tar.gz"
    local download_url="https://github.com/$GITHUB_REPO/releases/download/v$VERSION/$archive_name"
    
    print_info "Platform: $platform $arch"
    print_info "Installing to: $INSTALL_DIR"
    print_info "Download URL: $download_url"
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    local archive_file="$temp_dir/$archive_name"
    
    # Download archive
    print_info "📥 Downloading $CLI_NAME v$VERSION..."
    if command -v curl >/dev/null 2>&1; then
        if ! curl -fsSL "$download_url" -o "$archive_file"; then
            print_error "Failed to download from GitHub releases"
            print_info "Please check:"
            print_info "1. Internet connection is working"
            print_info "2. Release exists: https://github.com/$GITHUB_REPO/releases/tag/v$VERSION"
            print_info "3. Try downloading manually and run the installer locally"
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -q "$download_url" -O "$archive_file"; then
            print_error "Failed to download from GitHub releases"
            exit 1
        fi
    fi
    
    # Verify download
    if [[ ! -f "$archive_file" ]] || [[ ! -s "$archive_file" ]]; then
        print_error "Downloaded file is empty or missing"
        exit 1
    fi
    
    print_success "✅ Download completed"
    
    # Extract archive
    print_info "📦 Extracting archive..."
    cd "$temp_dir"
    if ! tar -xzf "$archive_file"; then
        print_error "Failed to extract archive"
        exit 1
    fi
    
    # Find extracted directory
    local extracted_dir=$(find . -maxdepth 1 -type d -name "${CLI_NAME}-*" | head -1)
    if [[ -z "$extracted_dir" ]]; then
        print_error "Could not find extracted directory"
        print_info "Archive contents:"
        ls -la
        exit 1
    fi
    
    print_success "✅ Archive extracted to $extracted_dir"
    
    # Install using bundled installer
    print_info "🔧 Installing using bundled installer..."
    cd "$extracted_dir"
    
    if [[ -f "install-cli.sh" ]]; then
        print_info "Running: ./install-cli.sh global --prefix $INSTALL_DIR"
        
        # Check if we need sudo for installation
        if [[ ! -w "$INSTALL_DIR" ]] && [[ "$INSTALL_DIR" != "$HOME"* ]]; then
            if [[ "$EUID" -ne 0 ]]; then
                print_warning "Installation directory requires root access"
                print_info "You may be prompted for your password"
                sudo ./install-cli.sh global --prefix "$INSTALL_DIR" "$@"
            else
                ./install-cli.sh global --prefix "$INSTALL_DIR" "$@"
            fi
        else
            ./install-cli.sh global --prefix "$INSTALL_DIR" "$@"
        fi
    else
        print_error "Installation script not found in package"
        print_info "Package contents:"
        ls -la
        exit 1
    fi
    
    # Cleanup
    print_info "🧹 Cleaning up temporary files..."
    rm -rf "$temp_dir"
    
    # Verify installation
    local install_path="$INSTALL_DIR/bin/$CLI_NAME"
    if [[ -f "$install_path" ]]; then
        print_success "🎉 Installation completed successfully!"
        print_info ""
        print_info "📋 Installation Details:"
        print_info "  Version: $VERSION"
        print_info "  Location: $install_path"
        print_info "  Size: $(du -h "$install_path" | cut -f1)"
        print_info ""
        print_info "🚀 Usage:"
        print_info "  $CLI_NAME --help                    # Show help"
        print_info "  $CLI_NAME analyze app               # Preview upgrades" 
        print_info "  $CLI_NAME upgrade --all --validate  # Upgrade all projects"
        print_info ""
        
        # Check if CLI is in PATH
        if command -v "$CLI_NAME" >/dev/null 2>&1; then
            print_success "✅ $CLI_NAME is ready to use!"
            print_info "Test it: $CLI_NAME --version"
        else
            print_warning "⚠️  $CLI_NAME is not in your PATH"
            print_info "Add $INSTALL_DIR/bin to your PATH:"
            print_info "  echo 'export PATH=\"$INSTALL_DIR/bin:\$PATH\"' >> ~/.bashrc"
            print_info "  echo 'export PATH=\"$INSTALL_DIR/bin:\$PATH\"' >> ~/.zshrc"
            print_info "Then restart your terminal or run: source ~/.bashrc"
        fi
        
        print_info ""
        print_info "📖 Documentation: https://github.com/$GITHUB_REPO#readme"
        print_info "🐛 Issues: https://github.com/$GITHUB_REPO/issues"
        
    else
        print_error "❌ Installation verification failed"
        print_info "Expected location: $install_path"
        exit 1
    fi
}

main "$@"
