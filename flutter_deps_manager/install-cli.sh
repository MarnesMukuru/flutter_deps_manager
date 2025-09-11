#!/bin/bash

# Flutter Dependencies Upgrade CLI - Professional Installation Script
# Installs the CLI tool globally or copies to other projects

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_NAME="flutter-deps-upgrade"
VERSION="1.0.0"

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
${BOLD}Flutter Dependencies Upgrade CLI - Installation${NC}
Professional dependency upgrader with intelligent monorepo detection

${BOLD}USAGE:${NC}
    $0 [COMMAND] [OPTIONS]

${BOLD}COMMANDS:${NC}
    global                      Install globally (recommended)
    local [PATH]                Install to specific Flutter project
    uninstall                   Remove global installation
    update                      Update existing installation
    check                       Check installation status

${BOLD}OPTIONS:${NC}
    -h, --help                  Show this help message
    -v, --verbose               Verbose output
    --force                     Force installation (overwrite existing)
    --prefix PATH               Custom installation prefix (default: /usr/local)

${BOLD}EXAMPLES:${NC}
    $0 global                           # Install globally
    $0 local ~/my-flutter-app           # Install to specific project
    $0 global --prefix ~/.local         # Install to custom location
    $0 uninstall                        # Remove global installation
    $0 check                            # Check if installed

${BOLD}GLOBAL INSTALLATION:${NC}
    Installs to: /usr/local/bin/${CLI_NAME}
    Usage: ${CLI_NAME} analyze app
           ${CLI_NAME} upgrade --all

${BOLD}LOCAL INSTALLATION:${NC}
    Copies to: [PROJECT]/flutter-deps-upgrade/
    Usage: ./flutter-deps-upgrade/flutter-deps-upgrade analyze app

EOF
}

check_requirements() {
    # Check if flutter is installed
    if ! command -v flutter >/dev/null 2>&1; then
        print_error "Flutter is not installed or not in PATH"
        print_info "Please install Flutter first: https://flutter.dev/docs/get-started/install"
        exit 1
    fi
    
    # Check if required files exist
    local required_files=("flutter-deps-upgrade" "core-functions.sh")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
            print_error "Required file not found: $SCRIPT_DIR/$file"
            exit 1
        fi
    done
}

install_global() {
    local prefix="${1:-/usr/local}"
    local bin_dir="$prefix/bin"
    local lib_dir="$prefix/lib/${CLI_NAME}"
    local force="$2"
    
    print_header "🚀 Installing $CLI_NAME v$VERSION globally"
    
    # Check if already installed
    if [[ -f "$bin_dir/$CLI_NAME" ]] && [[ "$force" != "true" ]]; then
        print_warning "Already installed at: $bin_dir/$CLI_NAME"
        print_info "Use --force to overwrite, or run 'update' command"
        exit 1
    fi
    
    # Create directories
    print_info "Creating directories..."
    sudo mkdir -p "$bin_dir" "$lib_dir"
    
    # Copy core files
    print_info "Installing core files..."
    sudo cp "$SCRIPT_DIR/core-functions.sh" "$lib_dir/"
    
    # Create main executable with proper paths
    print_info "Creating executable..."
    cat > "/tmp/$CLI_NAME" << EOF
#!/bin/bash
# Flutter Dependencies Upgrade CLI Tool v$VERSION
# Installed from: $SCRIPT_DIR

SCRIPT_DIR="$lib_dir"
$(tail -n +3 "$SCRIPT_DIR/flutter-deps-upgrade")
EOF
    
    sudo mv "/tmp/$CLI_NAME" "$bin_dir/$CLI_NAME"
    sudo chmod +x "$bin_dir/$CLI_NAME"
    
    # Update PATH hint
    print_success "✅ Installed successfully!"
    print_info ""
    print_info "Installation location: $bin_dir/$CLI_NAME"
    print_info "Library files: $lib_dir/"
    print_info ""
    
    # Check if in PATH
    if ! echo "$PATH" | grep -q "$bin_dir"; then
        print_warning "⚠️  $bin_dir is not in your PATH"
        print_info "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        print_info "    export PATH=\"$bin_dir:\$PATH\""
        print_info ""
    fi
    
    # Test installation
    print_info "Testing installation..."
    if "$bin_dir/$CLI_NAME" --version >/dev/null 2>&1; then
        print_success "🎉 Installation verified!"
        print_info "Usage: $CLI_NAME --help"
    else
        print_error "Installation test failed"
        exit 1
    fi
}

install_local() {
    local target_project="$1"
    local force="$2"
    
    if [[ ! -d "$target_project" ]]; then
        print_error "Target directory not found: $target_project"
        exit 1
    fi
    
    local install_dir="$target_project/flutter-deps-upgrade"
    
    print_header "📋 Installing $CLI_NAME to local project"
    print_info "Target: $target_project"
    
    # Check if it's a Flutter project
    if [[ ! -f "$target_project/pubspec.yaml" ]] && [[ ! -d "$target_project/packages" ]]; then
        print_warning "Target doesn't appear to be a Flutter project"
        print_info "Continuing anyway..."
    fi
    
    # Create directory
    if [[ -d "$install_dir" ]] && [[ "$force" != "true" ]]; then
        print_warning "Already installed at: $install_dir"
        print_info "Use --force to overwrite"
        exit 1
    fi
    
    mkdir -p "$install_dir"
    
    # Copy files
    print_info "Copying files..."
    cp "$SCRIPT_DIR/flutter-deps-upgrade" "$install_dir/"
    cp "$SCRIPT_DIR/core-functions.sh" "$install_dir/"
    cp "$SCRIPT_DIR/README.md" "$install_dir/" 2>/dev/null || true
    
    # Make executable
    chmod +x "$install_dir/flutter-deps-upgrade"
    
    print_success "✅ Installed successfully!"
    print_info ""
    print_info "Installation location: $install_dir"
    print_info ""
    print_info "Usage from project root:"
    print_info "    ./flutter-deps-upgrade/flutter-deps-upgrade --help"
    print_info "    ./flutter-deps-upgrade/flutter-deps-upgrade analyze app"
    print_info "    ./flutter-deps-upgrade/flutter-deps-upgrade upgrade --all"
}

uninstall_global() {
    local prefix="${1:-/usr/local}"
    local bin_dir="$prefix/bin"
    local lib_dir="$prefix/lib/${CLI_NAME}"
    
    print_header "🗑️  Uninstalling $CLI_NAME"
    
    if [[ ! -f "$bin_dir/$CLI_NAME" ]]; then
        print_warning "Not installed at: $bin_dir/$CLI_NAME"
        exit 1
    fi
    
    print_info "Removing files..."
    sudo rm -f "$bin_dir/$CLI_NAME"
    sudo rm -rf "$lib_dir"
    
    print_success "✅ Uninstalled successfully!"
}

check_installation() {
    print_header "🔍 Checking Installation Status"
    
    local found_global=false
    local found_local=false
    
    # Check global installation
    if command -v "$CLI_NAME" >/dev/null 2>&1; then
        local install_path=$(which "$CLI_NAME")
        print_success "✅ Global installation found: $install_path"
        
        # Check version
        local version=$("$CLI_NAME" version 2>/dev/null | head -1)
        print_info "   Version: $version"
        found_global=true
    fi
    
    # Check local installation
    if [[ -f "./flutter-deps-upgrade/flutter-deps-upgrade" ]]; then
        print_success "✅ Local installation found: ./flutter-deps-upgrade/"
        found_local=true
    fi
    
    if [[ "$found_global" == "false" ]] && [[ "$found_local" == "false" ]]; then
        print_warning "⚠️  No installations found"
        print_info "Run '$0 global' to install globally"
    fi
}

update_installation() {
    print_header "🔄 Updating $CLI_NAME"
    
    # Check if globally installed
    if command -v "$CLI_NAME" >/dev/null 2>&1; then
        local install_path=$(which "$CLI_NAME")
        print_info "Found global installation: $install_path"
        
        # Determine prefix from install path
        local prefix
        if [[ "$install_path" == */usr/local/bin/* ]]; then
            prefix="/usr/local"
        elif [[ "$install_path" == */.local/bin/* ]]; then
            prefix="$HOME/.local"
        else
            prefix="/usr/local"
        fi
        
        install_global "$prefix" "true"
    else
        print_error "No global installation found"
        print_info "Use '$0 global' to install"
        exit 1
    fi
}

main() {
    local command=""
    local target=""
    local prefix="/usr/local"
    local force="false"
    local verbose="false"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            global|local|uninstall|update|check)
                command="$1"
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--verbose)
                verbose="true"
                shift
                ;;
            --force)
                force="true"
                shift
                ;;
            --prefix)
                prefix="$2"
                shift 2
                ;;
            -*)
                print_error "Unknown option: $1"
                exit 1
                ;;
            *)
                if [[ -z "$target" ]]; then
                    target="$1"
                else
                    print_error "Too many arguments"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Show usage if no command
    if [[ -z "$command" ]]; then
        show_usage
        exit 0
    fi
    
    # Check requirements
    check_requirements
    
    # Execute command
    case "$command" in
        global)
            install_global "$prefix" "$force"
            ;;
        local)
            if [[ -z "$target" ]]; then
                target="$(pwd)"
            fi
            install_local "$target" "$force"
            ;;
        uninstall)
            uninstall_global "$prefix"
            ;;
        update)
            update_installation
            ;;
        check)
            check_installation
            ;;
        *)
            print_error "Unknown command: $command"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"