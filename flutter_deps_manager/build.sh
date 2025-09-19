#!/bin/bash

# Flutter Dependencies Upgrade CLI - Build Script
# Creates distributable packages for different platforms and installation methods

set -euo pipefail

# Build configuration
CLI_NAME="flutter-deps-upgrade"
VERSION=$(cat VERSION 2>/dev/null || echo "1.1.7")
BUILD_DIR="dist"
PACKAGE_DIR="packages"
ARCHIVE_DIR="archives"

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
${BOLD}Flutter Dependencies Upgrade CLI - Build Script${NC}
Creates distributable packages and installation scripts

${BOLD}USAGE:${NC}
    $0 [COMMAND] [OPTIONS]

${BOLD}COMMANDS:${NC}
    build                       Build all distribution packages (default)
    clean                       Clean build directory
    package [TYPE]              Build specific package type
    install-script              Generate web installer script
    checksums                   Generate checksums for all archives
    release                     Prepare release artifacts

${BOLD}PACKAGE TYPES:${NC}
    tarball                     Create tar.gz archives for Unix systems
    portable                    Create portable installation packages
    installer                   Create platform-specific installers

${BOLD}OPTIONS:${NC}
    -h, --help                  Show this help message
    -v, --version VERSION       Override version (default: $VERSION)
    -o, --output DIR           Output directory (default: $BUILD_DIR)
    --clean                     Clean before building

${BOLD}EXAMPLES:${NC}
    $0                          # Build everything
    $0 build --clean            # Clean build all packages
    $0 package tarball          # Build only tar.gz archives
    $0 install-script           # Generate web installer
    $0 release                  # Prepare GitHub release

EOF
}

# Version info
show_version_info() {
    print_info "Building version: $VERSION"
    print_info "Project: $CLI_NAME"
}

# Clean build directory
clean_build() {
    print_info "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
    print_success "✅ Build directory cleaned"
}

# Create build directory structure
setup_build_dir() {
    print_info "Setting up build directory structure..."
    
    mkdir -p "$BUILD_DIR/$PACKAGE_DIR"
    mkdir -p "$BUILD_DIR/$ARCHIVE_DIR"
    mkdir -p "$BUILD_DIR/installers"
    mkdir -p "$BUILD_DIR/scripts"
    
    print_success "✅ Build directory structure created"
}

# Copy and prepare source files
prepare_source() {
    local target_dir="$1"
    
    print_info "Preparing source files in $target_dir..."
    
    # Copy core CLI files
    cp flutter-deps-upgrade "$target_dir/"
    cp core-functions.sh "$target_dir/"
    cp install-cli.sh "$target_dir/"
    cp VERSION "$target_dir/"
    cp README.md "$target_dir/"
    
    # Make executable
    chmod +x "$target_dir/flutter-deps-upgrade"
    chmod +x "$target_dir/install-cli.sh"
    
    # Create version file
    echo "$VERSION" > "$target_dir/VERSION"
    
    # Create manifest
    cat > "$target_dir/MANIFEST" << EOF
flutter-deps-upgrade v$VERSION
Build date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Platform: Universal (Bash)
Files:
  - flutter-deps-upgrade    (Main CLI executable)
  - core-functions.sh       (Core functionality)
  - install-cli.sh          (Installation script)
  - README.md               (Documentation)
  - VERSION                 (Version information)
  - MANIFEST               (This file)
EOF
    
    print_success "✅ Source files prepared"
}

# Build tarball packages
build_tarball() {
    print_header "📦 Building Tarball Packages"
    
    local package_name="${CLI_NAME}-${VERSION}"
    local temp_dir=$(mktemp -d)
    local package_dir="$temp_dir/$package_name"
    local original_dir=$(pwd)
    
    mkdir -p "$package_dir"
    prepare_source "$package_dir"
    
    # Create tar.gz archive
    local tarball_name="${package_name}.tar.gz"
    print_info "Creating $tarball_name..."
    
    cd "$temp_dir"
    tar -czf "$tarball_name" "$package_name"
    
    # Move to build directory
    mv "$tarball_name" "$original_dir/$BUILD_DIR/$ARCHIVE_DIR/"
    
    # Create zip archive for Windows users
    local zip_name="${package_name}.zip"
    print_info "Creating $zip_name..."
    
    if command -v zip >/dev/null 2>&1; then
        zip -r "$zip_name" "$package_name" >/dev/null
        mv "$zip_name" "$original_dir/$BUILD_DIR/$ARCHIVE_DIR/"
        print_success "✅ Created $zip_name"
    else
        print_warning "⚠️  zip command not available, skipping .zip archive"
    fi
    
    # Cleanup
    cd "$original_dir"
    rm -rf "$temp_dir"
    
    print_success "✅ Tarball packages created"
    print_info "   📄 $BUILD_DIR/$ARCHIVE_DIR/$tarball_name"
    if [[ -f "$BUILD_DIR/$ARCHIVE_DIR/$zip_name" ]]; then
        print_info "   📄 $BUILD_DIR/$ARCHIVE_DIR/$zip_name"
    fi
}

# Build portable installation package
build_portable() {
    print_header "📱 Building Portable Package"
    
    local portable_name="${CLI_NAME}-${VERSION}-portable"
    local portable_dir="$BUILD_DIR/$PACKAGE_DIR/$portable_name"
    
    mkdir -p "$portable_dir"
    prepare_source "$portable_dir"
    
    # Create portable installer script
    cat > "$portable_dir/install-portable.sh" << 'EOF'
#!/bin/bash

# Flutter Dependencies Upgrade CLI - Portable Installer
# Installs the CLI from a portable package

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_NAME="flutter-deps-upgrade"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

print_info "🚀 Installing Flutter Dependencies Upgrade CLI (Portable)"
print_info "Source: $SCRIPT_DIR"

# Check if running from extracted package
if [[ ! -f "$SCRIPT_DIR/flutter-deps-upgrade" ]]; then
    print_warning "❌ This script must be run from the extracted package directory"
    exit 1
fi

# Use the bundled install script
if [[ -f "$SCRIPT_DIR/install-cli.sh" ]]; then
    print_info "📦 Using bundled installer..."
    "$SCRIPT_DIR/install-cli.sh" global "$@"
else
    print_warning "❌ Installation script not found in package"
    exit 1
fi
EOF
    
    chmod +x "$portable_dir/install-portable.sh"
    
    # Create README for portable package
    cat > "$portable_dir/PORTABLE-README.md" << EOF
# Flutter Dependencies Upgrade CLI - Portable Package

This is a portable installation package that contains all necessary files.

## Quick Installation

\`\`\`bash
# Extract the package (if you haven't already)
tar -xzf ${CLI_NAME}-${VERSION}.tar.gz
cd ${portable_name}

# Install globally
./install-portable.sh

# Or install to specific location
./install-portable.sh --prefix ~/.local
\`\`\`

## Manual Installation

If you prefer manual installation:

\`\`\`bash
# Copy to your preferred location
mkdir -p ~/.local/bin
cp flutter-deps-upgrade ~/.local/bin/
cp core-functions.sh ~/.local/lib/${CLI_NAME}/

# Make sure ~/.local/bin is in your PATH
export PATH="\$HOME/.local/bin:\$PATH"
\`\`\`

## Usage

\`\`\`bash
${CLI_NAME} --help
${CLI_NAME} analyze app
${CLI_NAME} upgrade --all --validate
\`\`\`

EOF
    
    print_success "✅ Portable package created at $portable_dir"
}

# Generate web installer script
# Generate web installer script - FIXED VERSION
generate_web_installer() {
    print_header "🌐 Copying Smart Web Installer Script"
    
    local installer_script="$BUILD_DIR/installers/install.sh"
    
    # Copy our smart installer instead of generating a basic one
    cp install.sh "$installer_script"
    
    # Update version in the copied installer
    sed -i "s/VERSION=\".*\"/VERSION=\"$VERSION\"/" "$installer_script"
    
    chmod +x "$installer_script"
    
    print_success "✅ Smart web installer copied and updated at $installer_script"
    print_info ""
    print_info "Users can install with:"
    print_info "  curl -fsSL https://github.com/MarnesMukuru/flutter_deps_manager/releases/download/v$VERSION/install.sh | bash"
    print_info "  or"  
    print_info "  wget -qO- https://github.com/MarnesMukuru/flutter_deps_manager/releases/download/v$VERSION/install.sh | bash"
}
# Generate checksums for all archives
generate_checksums() {
    print_header "🔐 Generating Checksums"
    
    local checksums_file="$BUILD_DIR/checksums.txt"
    
    # Find all archive files
    local archives=($(find "$BUILD_DIR/$ARCHIVE_DIR" -type f \( -name "*.tar.gz" -o -name "*.zip" \) 2>/dev/null || true))
    
    if [[ ${#archives[@]} -eq 0 ]]; then
        print_warning "No archives found for checksum generation"
        return 1
    fi
    
    # Generate checksums
    {
        echo "# Flutter Dependencies Upgrade CLI v$VERSION"
        echo "# SHA256 Checksums"
        echo "# Generated on $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
        echo ""
    } > "$checksums_file"
    
    for archive in "${archives[@]}"; do
        local filename=$(basename "$archive")
        local checksum
        
        if command -v sha256sum >/dev/null 2>&1; then
            checksum=$(sha256sum "$archive" | cut -d' ' -f1)
        elif command -v shasum >/dev/null 2>&1; then
            checksum=$(shasum -a 256 "$archive" | cut -d' ' -f1)
        else
            print_warning "No SHA256 tool available, skipping checksums"
            return 1
        fi
        
        echo "$checksum  $filename" >> "$checksums_file"
        print_info "📝 $filename: $checksum"
    done
    
    print_success "✅ Checksums saved to $checksums_file"
}

# Create GitHub release notes
create_release_notes() {
    local notes_file="$BUILD_DIR/RELEASE_NOTES.md"
    
    cat > "$notes_file" << EOF
# Flutter Dependencies Upgrade CLI v$VERSION

Intelligent Flutter dependency upgrader with automatic monorepo detection.

## 🚀 Quick Installation

### One-line Install (Recommended)
\`\`\`bash
curl -fsSL https://raw.githubusercontent.com/MarnesMukuru/flutter_deps_manager/main/flutter_deps_manager/install.sh | bash
\`\`\`

### Manual Download
Download the appropriate archive below, extract it, and run the installer:

\`\`\`bash
# Download and extract
tar -xzf flutter-deps-upgrade-$VERSION.tar.gz
cd flutter-deps-upgrade-$VERSION

# Install globally
./install-cli.sh global
\`\`\`

## 📦 Usage

\`\`\`bash
flutter-deps-upgrade analyze app                    # Preview upgrades
flutter-deps-upgrade upgrade --all --validate       # Upgrade all projects
flutter-deps-upgrade upgrade packages/core          # Upgrade specific project
\`\`\`

## 🔍 Features

- **Smart Detection**: Automatically detects monorepo vs standalone projects
- **Safe Upgrades**: Creates backups and validates builds
- **Professional Output**: Clear progress and comprehensive results
- **Build Validation**: Optional comprehensive build testing

## 📋 What's New in v$VERSION

- Professional CLI interface with comprehensive help
- Improved error handling and validation
- Enhanced build validation with detailed metrics
- Better support for various Flutter project structures

## 🔐 File Verification

Verify downloads using SHA256 checksums (see checksums.txt):

\`\`\`bash
# macOS/Linux
sha256sum -c checksums.txt

# Or check individual files
sha256sum flutter-deps-upgrade-$VERSION.tar.gz
\`\`\`

---

**Need help?** See the [README](https://github.com/MarnesMukuru/flutter_deps_manager#readme) or create an [issue](https://github.com/MarnesMukuru/flutter_deps_manager/issues).
EOF
    
    print_success "✅ Release notes created at $notes_file"
}

# Build everything
build_all() {
    print_header "🏗️  Building All Distribution Packages"
    
    setup_build_dir
    build_tarball
    build_portable
    generate_web_installer
    generate_checksums
    create_release_notes
    
    print_header "📊 Build Summary"
    
    local total_size=0
    echo ""
    print_info "📁 Build artifacts in $BUILD_DIR:"
    
    # Show directory structure
    if command -v tree >/dev/null 2>&1; then
        tree "$BUILD_DIR" | head -20
    else
        find "$BUILD_DIR" -type f -exec ls -lh {} \; | awk '{print "  "$9" ("$5")"}'
    fi
    
    # Calculate total size
    if command -v du >/dev/null 2>&1; then
        total_size=$(du -sh "$BUILD_DIR" | cut -f1)
        print_info "Total size: $total_size"
    fi
    
    echo ""
    print_success "🎉 All packages built successfully!"
    print_info ""
    print_info "Next steps:"
    print_info "1. Test the packages locally"
    print_info "2. Update GitHub repository URL in install.sh"
    print_info "3. Create GitHub release with these artifacts"
    print_info "4. Update README with new installation instructions"
}

# Main function
main() {
    local command="build"
    local package_type=""
    local custom_version=""
    local output_dir=""
    local should_clean=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--version)
                custom_version="$2"
                shift 2
                ;;
            -o|--output)
                output_dir="$2"
                shift 2
                ;;
            --clean)
                should_clean=true
                shift
                ;;
            clean|build|package|install-script|checksums|release)
                command="$1"
                shift
                ;;
            tarball|portable|installer)
                package_type="$1"
                shift
                ;;
            *)
                print_error "Unknown argument: $1"
                exit 1
                ;;
        esac
    done
    
    # Override version if specified
    if [[ -n "$custom_version" ]]; then
        VERSION="$custom_version"
    else
        show_version_info
    fi
    
    # Override output directory if specified
    if [[ -n "$output_dir" ]]; then
        BUILD_DIR="$output_dir"
    fi
    
    # Clean if requested
    if [[ "$should_clean" == "true" ]]; then
        clean_build
    fi
    
    # Execute command
    case "$command" in
        clean)
            clean_build
            ;;
        build)
            build_all
            ;;
        package)
            setup_build_dir
            case "$package_type" in
                tarball)
                    build_tarball
                    ;;
                portable)
                    build_portable
                    ;;
                installer)
                    generate_web_installer
                    ;;
                "")
                    build_tarball
                    build_portable
                    ;;
                *)
                    print_error "Unknown package type: $package_type"
                    exit 1
                    ;;
            esac
            ;;
        install-script)
            setup_build_dir
            generate_web_installer
            ;;
        checksums)
            generate_checksums
            ;;
        release)
            build_all
            ;;
        *)
            print_error "Unknown command: $command"
            exit 1
            ;;
    esac
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
