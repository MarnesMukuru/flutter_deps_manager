# Flutter Dependencies Upgrade CLI v1.0.0

Intelligent Flutter dependency upgrader with automatic monorepo detection.

## 🚀 Quick Installation

### One-line Install (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/your-username/flutter-deps-manager-project/main/install.sh | bash
```

### Manual Download
Download the appropriate archive below, extract it, and run the installer:

```bash
# Download and extract
tar -xzf flutter-deps-upgrade-1.0.0.tar.gz
cd flutter-deps-upgrade-1.0.0

# Install globally
./install-cli.sh global
```

## 📦 Usage

```bash
flutter-deps-upgrade analyze app                    # Preview upgrades
flutter-deps-upgrade upgrade --all --validate       # Upgrade all projects
flutter-deps-upgrade upgrade packages/core          # Upgrade specific project
```

## 🔍 Features

- **Smart Detection**: Automatically detects monorepo vs standalone projects
- **Safe Upgrades**: Creates backups and validates builds
- **Professional Output**: Clear progress and comprehensive results
- **Build Validation**: Optional comprehensive build testing

## 📋 What's New in v1.0.0

- Professional CLI interface with comprehensive help
- Improved error handling and validation
- Enhanced build validation with detailed metrics
- Better support for various Flutter project structures

## 🔐 File Verification

Verify downloads using SHA256 checksums (see checksums.txt):

```bash
# macOS/Linux
sha256sum -c checksums.txt

# Or check individual files
sha256sum flutter-deps-upgrade-1.0.0.tar.gz
```

---

**Need help?** See the [README](https://github.com/your-username/flutter-deps-manager-project#readme) or create an [issue](https://github.com/your-username/flutter-deps-manager-project/issues).
