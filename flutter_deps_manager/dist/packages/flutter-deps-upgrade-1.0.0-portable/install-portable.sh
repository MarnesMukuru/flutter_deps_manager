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
