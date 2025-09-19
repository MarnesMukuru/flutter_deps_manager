#!/bin/bash
# Simple version updater - updates ALL files with the version from VERSION file
set -e

# Read current version
if [[ ! -f "VERSION" ]]; then
    echo "❌ VERSION file not found"
    exit 1
fi

NEW_VERSION=$(cat VERSION | tr -d '\n\r ')
echo "🔄 Updating all files to version: $NEW_VERSION"

# Update all files that contain version numbers
echo "📝 Updating version references..."

# Main CLI script
sed -i.bak "s/VERSION=.*$/VERSION=\$(cat \"\${BASH_SOURCE[0]%\/*}\/VERSION\" 2>\/dev\/null || echo \"$NEW_VERSION\")/" flutter-deps-upgrade
echo "  ✅ flutter-deps-upgrade"

# Install scripts
sed -i.bak "s/VERSION=\"[^\"]*\"/VERSION=\"$NEW_VERSION\"/g" install.sh
sed -i.bak "s/VERSION=\"[^\"]*\"/VERSION=\"$NEW_VERSION\"/g" install-cli.sh
echo "  ✅ install scripts"

# Homebrew formula
sed -i.bak "s/version \"[^\"]*\"/version \"$NEW_VERSION\"/g" homebrew-formula/flutter-deps-upgrade.rb
sed -i.bak "s|/releases/download/v[^/]*/|/releases/download/v$NEW_VERSION/|g" homebrew-formula/flutter-deps-upgrade.rb
echo "  ✅ homebrew formula"

# README files
sed -i.bak "s|flutter-deps-upgrade-[0-9]*\.[0-9]*\.[0-9]*|flutter-deps-upgrade-$NEW_VERSION|g" README.md
sed -i.bak "s|/releases/download/v[^/]*/|/releases/download/v$NEW_VERSION/|g" README.md
sed -i.bak "s|/releases/tag/v[^)]*|/releases/tag/v$NEW_VERSION|g" README.md
echo "  ✅ README.md"

# Homebrew README
if [[ -f "homebrew-formula/README.md" ]]; then
    sed -i.bak "s/flutter-deps-upgrade-[0-9]*\.[0-9]*\.[0-9]*/flutter-deps-upgrade-$NEW_VERSION/g" homebrew-formula/README.md
    echo "  ✅ homebrew README"
fi

# Clean up backup files
find . -name "*.bak" -delete

echo "✅ All version references updated to $NEW_VERSION"
echo ""
echo "📋 Files updated:"
echo "  • flutter-deps-upgrade (dynamic version loading)"
echo "  • install.sh"
echo "  • install-cli.sh"
echo "  • homebrew-formula/flutter-deps-upgrade.rb"
echo "  • README.md"
echo "  • homebrew-formula/README.md"
echo ""
echo "🎯 Ready for commit!"
