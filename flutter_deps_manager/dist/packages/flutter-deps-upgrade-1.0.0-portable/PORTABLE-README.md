# Flutter Dependencies Upgrade CLI - Portable Package

This is a portable installation package that contains all necessary files.

## Quick Installation

```bash
# Extract the package (if you haven't already)
tar -xzf flutter-deps-upgrade-1.0.0.tar.gz
cd flutter-deps-upgrade-1.0.0-portable

# Install globally
./install-portable.sh

# Or install to specific location
./install-portable.sh --prefix ~/.local
```

## Manual Installation

If you prefer manual installation:

```bash
# Copy to your preferred location
mkdir -p ~/.local/bin
cp flutter-deps-upgrade ~/.local/bin/
cp core-functions.sh ~/.local/lib/flutter-deps-upgrade/

# Make sure ~/.local/bin is in your PATH
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

```bash
flutter-deps-upgrade --help
flutter-deps-upgrade analyze app
flutter-deps-upgrade upgrade --all --validate
```

