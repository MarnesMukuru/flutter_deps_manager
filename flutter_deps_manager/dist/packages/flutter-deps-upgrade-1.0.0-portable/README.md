# Flutter Dependencies Upgrade CLI

**Intelligent Flutter dependency upgrader with automatic monorepo detection.**

## ⚡ Quick Start

### 🚀 One-Line Install (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/marnesfourie/flutter_deps_manager_project/main/flutter_deps_manager/install.sh | bash
```

**Alternative methods:**
```bash
# Using wget
wget -qO- https://raw.githubusercontent.com/marnesfourie/flutter_deps_manager_project/main/flutter_deps_manager/install.sh | bash

# Install to custom location
export FLUTTER_DEPS_INSTALL_DIR=~/.local
curl -fsSL https://raw.githubusercontent.com/marnesfourie/flutter_deps_manager_project/main/flutter_deps_manager/install.sh | bash

# Manual download and install
wget https://github.com/marnesfourie/flutter_deps_manager_project/releases/latest/download/flutter-deps-upgrade-1.0.0.tar.gz
tar -xzf flutter-deps-upgrade-1.0.0.tar.gz
cd flutter-deps-upgrade-1.0.0
./install-cli.sh global
```

### Use Anywhere
```bash
flutter-deps-upgrade upgrade my_app --validate    # Upgrade specific project with build validation
flutter-deps-upgrade upgrade --all                # Upgrade all projects
flutter-deps-upgrade analyze my_package           # Preview changes (dry-run)
flutter-deps-upgrade --help                       # See all options
```

**⚠️ Important for Monorepos:** 
- Run commands from your **project root directory** (where your main app's pubspec.yaml is located)
- The tool needs to access all path dependencies from this location
- Path dependencies like `../packages/core/` must be resolvable from where you run the command

## 🎯 What It Does

Upgrades your Flutter dependencies to the **latest compatible versions** that actually work together.

### Before:
```yaml
dependencies:
  logger: 1.4.0           # Old version
  get_it: ^7.7.0          # Outdated
  camera: any             # Unresolved
```

### After:
```yaml
dependencies:
  logger: ^2.6.1          # Latest compatible!
  get_it: ^8.2.0          # Latest compatible!
  camera: ^0.11.2         # Properly resolved!
```

## 🔍 Intelligent Detection

- **MONOREPO** (has path dependencies) → Upgrades all related packages together
- **STANDALONE** (no path dependencies) → Upgrades individually

You can target **any folder** with a `pubspec.yaml`:
- `flutter-deps-upgrade upgrade my_app` (main app folder)
- `flutter-deps-upgrade upgrade packages/core` (package folder)  
- `flutter-deps-upgrade upgrade .` (current directory)

## 💡 Key Features

✅ **Smart Validation** - Explains why "X packages have newer versions" warnings are safe to ignore  
✅ **Build Validation** - Runs actual builds and shows comprehensive results  
✅ **Safety First** - Automatic backups before changes  
✅ **Professional Output** - Clear progress and results  

## 🚀 Commands

```bash
# Basic usage - target any folder with pubspec.yaml
flutter-deps-upgrade upgrade my_app           # Upgrade specific folder + related packages
flutter-deps-upgrade upgrade packages/core    # Upgrade specific package folder
flutter-deps-upgrade upgrade .                # Upgrade current directory
flutter-deps-upgrade upgrade --all            # Upgrade all projects

# With comprehensive build validation
flutter-deps-upgrade upgrade my_app --validate # Runs flutter clean, build_runner, etc.

# Preview changes (no modifications)
flutter-deps-upgrade analyze my_app           # See what would be upgraded
flutter-deps-upgrade analyze packages/core    # Preview specific package

# Interactive mode
flutter-deps-upgrade upgrade                  # Choose from menu

# Help
flutter-deps-upgrade --help                   # See all options
```

**📂 Folder Targeting:** Replace `my_app` with your actual folder name (e.g., `app`, `client`, `mobile`, etc.)

## 🛡️ Safety

- Creates automatic backups: `pubspec.yaml.backup.timestamp`
- Dry-run mode to preview changes
- Automatic rollback if failures occur
- Skips git/path dependencies (preserves local packages)

## 📋 Example Output

```
🚀 Upgrading Dependencies
✅ Upgrade completed successfully!

📋 DETAILED BUILD VALIDATION RESULTS:
✅ Build Performance Summary:
  • Total build time: 33.7s
  • Generated 307 build outputs
  • Executed 4080 build actions
  • Code generation: 47 files created

⚠️  DETAILED WARNING ANALYSIS (Safe to ignore):
  • 38 packages have newer versions - CLI found the best compatible versions
  • Analyzer version mismatch - Expected and safe

💡 PROFESSIONAL ASSESSMENT:
  ✅ SUCCESSFUL UPGRADE: Your dependency upgrade completed successfully!
  ▶️  NEXT STEPS: Your project is ready for development and production use
```

## 🔧 Installation & Management

### System Requirements
- **Flutter SDK** (required for CLI to function)
- **Bash** shell (macOS/Linux/WSL)
- **curl** or **wget** (for installation)
- **tar** (for extracting packages)

### Installation Locations
- **Global install**: `/usr/local/bin` (default)
- **User install**: `~/.local/bin` (set `FLUTTER_DEPS_INSTALL_DIR=~/.local`)
- **Custom location**: Set `FLUTTER_DEPS_INSTALL_DIR=/your/path`

### Verify Installation
```bash
flutter-deps-upgrade --version
which flutter-deps-upgrade
```

### Update to Latest Version
```bash
# Re-run the installer - it will update automatically
curl -fsSL https://raw.githubusercontent.com/marnesfourie/flutter_deps_manager_project/main/flutter_deps_manager/install.sh | bash
```

### Uninstall
```bash
# Remove global installation
sudo rm -f /usr/local/bin/flutter-deps-upgrade
sudo rm -rf /usr/local/lib/flutter-deps-upgrade

# Or remove user installation
rm -f ~/.local/bin/flutter-deps-upgrade
rm -rf ~/.local/lib/flutter-deps-upgrade
```

## 🐛 Troubleshooting

### "command not found: flutter-deps-upgrade"
1. Check if it's installed: `ls -la /usr/local/bin/flutter-deps-upgrade`
2. Check your PATH: `echo $PATH`
3. Add to PATH if needed: `export PATH="/usr/local/bin:$PATH"`
4. Reload shell: `source ~/.bashrc` or `source ~/.zshrc`

### Permission Issues
```bash
# Install to user directory instead
export FLUTTER_DEPS_INSTALL_DIR=~/.local
curl -fsSL https://raw.githubusercontent.com/marnesfourie/flutter_deps_manager_project/main/flutter_deps_manager/install.sh | bash

# Then add to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

### Download Issues
- Check internet connection
- Try manual download from [GitHub releases](https://github.com/marnesfourie/flutter_deps_manager_project/releases)
- Use alternative download method (wget vs curl)

## 📦 GitHub Releases

Find all versions and download archives manually:
- **Releases**: [https://github.com/marnesfourie/flutter_deps_manager_project/releases](https://github.com/marnesfourie/flutter_deps_manager_project/releases)
- **Latest**: [Download tar.gz](https://github.com/marnesfourie/flutter_deps_manager_project/releases/latest/download/flutter-deps-upgrade-1.0.0.tar.gz)
- **Checksums**: Verify integrity with provided SHA256 checksums

---

**Simple, safe, and effective! 🚀**