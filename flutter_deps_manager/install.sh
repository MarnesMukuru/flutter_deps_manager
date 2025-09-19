#!/bin/bash

# Flutter Dependencies Upgrade CLI - Smart Web Installer
# Automatically handles system-wide or user installation with PATH setup

set -euo pipefail

CLI_NAME="flutter-deps-upgrade"
VERSION="1.1.8"
GITHUB_REPO="MarnesMukuru/flutter_deps_manager"

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

# Detect installation mode and directory
detect_install_mode() {
    # Check if user specified custom directory
    if [[ -n "${FLUTTER_DEPS_INSTALL_DIR:-}" ]]; then
        echo "$FLUTTER_DEPS_INSTALL_DIR"
        return
    fi
    
    # Check if we can write to /usr/local (system-wide)
    if [[ -w "/usr/local" ]] || [[ "$EUID" -eq 0 ]]; then
        echo "/usr/local"
        return
    fi
    
    # Try to create /usr/local/bin if it doesn't exist (with sudo)
    if [[ ! -d "/usr/local/bin" ]]; then
        if command -v sudo >/dev/null 2>&1; then
            # Try to create directory silently
            if sudo mkdir -p /usr/local/bin /usr/local/lib 2>/dev/null; then
                echo "/usr/local"
                return
            fi
        fi
    fi
    
    # Check if we need sudo for /usr/local
    if [[ -d "/usr/local/bin" ]] && ! [[ -w "/usr/local/bin" ]] && command -v sudo >/dev/null 2>&1; then
        echo "/usr/local"
        return
    fi
    
    # Fall back to user directory
    echo "$HOME/.local"
}

# Setup PATH for user installations
setup_path() {
    local install_dir="$1"
    
    # Only needed for user installations
    if [[ "$install_dir" == "$HOME/.local" ]]; then
        local bin_dir="$install_dir/bin"
        
        # Check if already in PATH
        if [[ ":$PATH:" == *":$bin_dir:"* ]]; then
            print_info "✅ $bin_dir is already in PATH"
            return
        fi
        
        print_info "📝 Setting up PATH for user installation..."
        
        # Detect shell and add to appropriate config file
        local shell_config=""
        local shell_name=$(basename "$SHELL")
        
        case "$shell_name" in
            zsh)
                shell_config="$HOME/.zshrc"
                ;;
            bash)
                shell_config="$HOME/.bashrc"
                # On macOS, also try .bash_profile
                if [[ -f "$HOME/.bash_profile" ]] && [[ "$(uname)" == "Darwin" ]]; then
                    shell_config="$HOME/.bash_profile"
                fi
                ;;
            fish)
                # Fish uses a different syntax
                local fish_config="$HOME/.config/fish/config.fish"
                if [[ -f "$fish_config" ]]; then
                    if ! grep -q "$bin_dir" "$fish_config" 2>/dev/null; then
                        mkdir -p "$(dirname "$fish_config")"
                        echo "set -gx PATH $bin_dir \$PATH" >> "$fish_config"
                        print_success "✅ Added to $fish_config"
                    fi
                fi
                return
                ;;
            *)
                shell_config="$HOME/.profile"
                ;;
        esac
        
        # Add to shell config if not already present
        if [[ -n "$shell_config" ]]; then
            local path_line="export PATH=\"$bin_dir:\$PATH\""
            
            if [[ -f "$shell_config" ]] && grep -q "$bin_dir" "$shell_config" 2>/dev/null; then
                print_info "✅ PATH already configured in $shell_config"
            else
                echo "" >> "$shell_config"
                echo "# Added by flutter-deps-upgrade installer" >> "$shell_config"
                echo "$path_line" >> "$shell_config"
                print_success "✅ Added PATH to $shell_config"
                
                # Also set for current session
                export PATH="$bin_dir:$PATH"
                print_info "✅ PATH updated for current session"
            fi
        fi
    fi
}

# Verify installation
verify_installation() {
    local install_dir="$1"
    local cli_path="$install_dir/bin/$CLI_NAME"
    
    if [[ -f "$cli_path" ]] && [[ -x "$cli_path" ]]; then
        print_success "✅ Installation verified: $cli_path"
        
        # Test if command is accessible
        if command -v "$CLI_NAME" >/dev/null 2>&1; then
            print_success "✅ $CLI_NAME is accessible from PATH"
            print_info "Test it: $CLI_NAME --help"
        elif [[ "$install_dir" == "$HOME/.local" ]]; then
            print_warning "⚠️  Restart your terminal or run: source ~/.$(basename "$SHELL")rc"
            print_info "Then test: $CLI_NAME --help"
        fi
        return 0
    else
        print_error "❌ Installation verification failed"
        return 1
    fi
}

main() {
    print_header "🚀 Flutter Dependencies Upgrade CLI Installer"
    
    # Check requirements
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        print_error "Either curl or wget is required for installation"
        exit 1
    fi
    
    if ! command -v tar >/dev/null 2>&1; then
        print_error "tar is required for installation"
        exit 1
    fi
    
    # Detect best installation mode
    local install_dir
    install_dir=$(detect_install_mode)
    
    print_header "📍 Installation Plan"
    if [[ "$install_dir" == "/usr/local" ]]; then
        print_info "Mode: System-wide installation"
        print_info "Location: /usr/local/bin/$CLI_NAME"
        print_info "Access: Available to all users"
        if [[ ! -w "/usr/local/bin" ]] && [[ "$EUID" -ne 0 ]]; then
            print_warning "⚠️  Will prompt for administrator password"
        fi
    else
        print_info "Mode: User installation" 
        print_info "Location: $install_dir/bin/$CLI_NAME"
        print_info "Access: Available to current user only"
        print_info "PATH: Will be configured automatically"
    fi
    
    # Detect platform
    local platform=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)
    local archive_name="${CLI_NAME}-${VERSION}.tar.gz"
    local download_url="https://github.com/$GITHUB_REPO/releases/download/v$VERSION/$archive_name"
    
    print_info "Platform: $platform $arch"
    print_info "Version: $VERSION"
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    local archive_file="$temp_dir/$archive_name"
    
    # Download archive
    print_info "📥 Downloading..."
    if command -v curl >/dev/null 2>&1; then
        if ! curl -fsSL "$download_url" -o "$archive_file"; then
            print_error "Failed to download from GitHub releases"
            print_info "Check: https://github.com/$GITHUB_REPO/releases/tag/v$VERSION"
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -q "$download_url" -O "$archive_file"; then
            print_error "Failed to download from GitHub releases"
            exit 1
        fi
    fi
    
    # Extract archive
    print_info "📦 Extracting..."
    cd "$temp_dir"
    tar -xzf "$archive_file"
    
    # Find extracted directory
    local extracted_dir=$(find . -maxdepth 1 -type d -name "${CLI_NAME}-*" | head -1)
    if [[ -z "$extracted_dir" ]]; then
        print_error "Could not find extracted directory"
        exit 1
    fi
    
    # Install using bundled installer
    print_info "🔧 Installing to $install_dir..."
    cd "$extracted_dir"
    
    if [[ -f "install-cli.sh" ]]; then
        # Check if already installed and use update instead of global install
        local cli_path="$install_dir/bin/$CLI_NAME"
        local install_command="global"
        
        if [[ -f "$cli_path" ]]; then
            print_info "🔄 Existing installation detected - upgrading..."
            install_command="update"
        fi
        
        if [[ "$install_dir" == "/usr/local" ]] && [[ ! -w "/usr/local/bin" ]] && [[ "$EUID" -ne 0 ]]; then
            # Need sudo for system installation
            sudo ./install-cli.sh $install_command --prefix "$install_dir" "$@"
        else
            # Direct installation (user dir or already have permissions)
            ./install-cli.sh $install_command --prefix "$install_dir" "$@"
        fi
    else
        print_error "Installation script not found in package"
        exit 1
    fi
    
    # Setup PATH for user installations
    setup_path "$install_dir"
    
    # Cleanup
    rm -rf "$temp_dir"
    
    # Verify installation
    if verify_installation "$install_dir"; then
        print_header "🎉 Installation Completed Successfully!"
        print_info ""
        print_info "🚀 Quick Start:"
        print_info "  $CLI_NAME --help                    # Show all options"
        print_info "  $CLI_NAME analyze .                 # Preview upgrades"
        print_info "  $CLI_NAME upgrade . --validate      # Upgrade with validation"
        print_info ""
        print_info "📖 Documentation: https://github.com/$GITHUB_REPO#readme"
        print_info "🐛 Issues: https://github.com/$GITHUB_REPO/issues"
        
        if [[ "$install_dir" == "$HOME/.local" ]]; then
            print_info ""
            print_warning "💡 If command not found, restart your terminal!"
        fi
    else
        exit 1
    fi
}

main "$@"