# Flutter Dependencies Upgrade CLI

**Intelligent Flutter dependency upgrader with automatic monorepo detection.**

## ⚡ Quick Start

### 🚀 One-Line Install (Smart Auto-Detection)
```bash
curl -fsSL https://github.com/MarnesMukuru/flutter_deps_manager/releases/download/v1.1.7/install.sh | bash
```

**The installer automatically:**
- ✅ **Detects permissions** and chooses the best installation mode
- ✅ **Auto-detects existing installations** - seamlessly upgrades without manual uninstall
- ✅ **Sets up PATH** automatically for user installations  
- ✅ **Handles sudo** prompts only when needed
- ✅ **Works immediately** after installation

**🔄 Works for both fresh install and upgrades:**
- Same command installs v1.1.7 fresh OR upgrades existing v1.1.6 → v1.1.7
- No need to uninstall first - the installer handles everything
- Preserves your current installation directory and PATH settings

### 📍 Installation Modes

#### 🌐 System-Wide Installation (Recommended)
- **When:** You have admin rights or can use `sudo`
- **Location:** `/usr/local/bin/flutter-deps-upgrade`
- **Access:** Available to all users immediately
- **Command:** Just run the installer (will prompt for password)

#### 👤 User Installation (No Admin Rights)
- **When:** No admin rights or prefer user-only install
- **Location:** `~/.local/bin/flutter-deps-upgrade`
- **Access:** Current user only
- **PATH:** Automatically added to your shell config
- **Command:** `FLUTTER_DEPS_INSTALL_DIR=~/.local curl -fsSL ... | bash`

### 🔄 Alternative Methods
```bash
# Force user installation (no sudo)
FLUTTER_DEPS_INSTALL_DIR=~/.local curl -fsSL https://github.com/MarnesMukuru/flutter_deps_manager/releases/download/v1.1.7/install.sh | bash

# Using wget
wget -qO- https://github.com/MarnesMukuru/flutter_deps_manager/releases/download/v1.1.7/install.sh | bash

# Manual download
wget https://github.com/MarnesMukuru/flutter_deps_manager/releases/latest/download/flutter-deps-upgrade-1.1.7.tar.gz
tar -xzf flutter-deps-upgrade-1.1.7.tar.gz && cd flutter-deps-upgrade-1.1.7
./install-cli.sh global  # System-wide
./install-cli.sh global --prefix ~/.local  # User-only
```

### Use Anywhere
```bash
flutter-deps-upgrade upgrade my_app --validate      # Upgrade specific project with build validation
flutter-deps-upgrade upgrade --all                  # Upgrade all projects
flutter-deps-upgrade upgrade my_app --keep-pinned   # Upgrade but preserve exact version pins
flutter-deps-upgrade upgrade my_app --cleanup-backups # Upgrade and auto-delete backup files
flutter-deps-upgrade analyze my_package             # Preview changes (dry-run)
flutter-deps-upgrade --help                         # See all options
```

**⚠️ Important for Monorepos:** 
- Run commands from your **project root directory** (where your main app's pubspec.yaml is located)
- The tool needs to access all path dependencies from this location
- Path dependencies like `../packages/core/` must be resolvable from where you run the command

## 🎯 What It Does

Upgrades your Flutter dependencies to the **latest compatible versions** that actually work together.

### Normal Upgrade:
#### Before:
```yaml
dependencies:
  logger: 1.4.0           # Old version
  get_it: ^7.7.0          # Outdated
  camera: any             # Unresolved
```

#### After:
```yaml
dependencies:
  logger: ^2.6.1          # Latest compatible!
  get_it: ^8.2.0          # Latest compatible!
  camera: ^0.11.2         # Properly resolved!
```

### With `--keep-pinned` Flag:
#### Before:
```yaml
dependencies:
  logger: 1.4.0           # Exact version (pinned)
  get_it: ^7.7.0          # Caret constraint
  camera: any             # Unresolved
```

#### After:
```yaml
dependencies:
  logger: 1.4.0           # PRESERVED (exact version kept)
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
✅ **Backup Management** - Auto-cleanup backup files for git users (`--cleanup-backups`)  
✅ **Version Pinning** - Preserve exact versions while upgrading others (`--keep-pinned`)  
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

# Preserve exact version pins while upgrading others
flutter-deps-upgrade upgrade my_app --keep-pinned # Keep packages like "package: 1.2.3" pinned
flutter-deps-upgrade upgrade --all --keep-pinned  # Keep pinned versions across all projects

# Clean up backup files (perfect for git users)
flutter-deps-upgrade upgrade my_app --cleanup-backups # Auto-delete backup files after success
flutter-deps-upgrade upgrade --all --cleanup-backups  # Clean up backups across all projects

# Preview changes (no modifications)
flutter-deps-upgrade analyze my_app           # See what would be upgraded
flutter-deps-upgrade analyze packages/core    # Preview specific package
flutter-deps-upgrade analyze my_app --keep-pinned # Preview with pinned versions preserved

# Interactive mode
flutter-deps-upgrade upgrade                  # Choose from menu

# Combine flags
flutter-deps-upgrade upgrade my_app --keep-pinned --validate # Keep pins + full validation
flutter-deps-upgrade upgrade my_app --cleanup-backups --validate # Clean up backups + validation
flutter-deps-upgrade upgrade my_app --keep-pinned --cleanup-backups # Keep pins + clean backups

# Help
flutter-deps-upgrade --help                   # See all options
```

**📂 Folder Targeting:** Replace `my_app` with your actual folder name (e.g., `app`, `client`, `mobile`, etc.)

## 🛡️ Safety

- Creates automatic backups: `pubspec.yaml.backup.timestamp`
- Dry-run mode to preview changes
- Automatic rollback if failures occur
- Skips git/path dependencies (preserves local packages)

## 🗑️ Backup Management

The `--cleanup-backups` flag helps manage backup files created during upgrades:

### When to Use `--cleanup-backups`:
- **Git users** - Backup files are redundant when you have version control
- **Clean workspace** - Keep directories tidy after upgrades
- **CI/CD pipelines** - Avoid accumulating backup files in automated builds
- **Production deploys** - Clean up temporary files automatically

### How It Works:
```bash
# Without --cleanup-backups (default)
flutter-deps-upgrade upgrade my_app
# → Creates: pubspec.yaml.backup.1234567890
# → Asks: "Delete backup files after successful upgrade? [y/N]"

# With --cleanup-backups (automatic)  
flutter-deps-upgrade upgrade my_app --cleanup-backups
# → Creates backups → Upgrades → Auto-deletes backups ✅

# Quiet mode (no prompting)
flutter-deps-upgrade upgrade my_app --quiet
# → Never asks about cleanup (keeps backups safe)
```

### Safety Features:
- ✅ **Only cleans after successful upgrades** - backups preserved if upgrade fails
- ✅ **Interactive confirmation** - asks before cleanup (unless using `--cleanup-backups`)
- ✅ **Safe default** - keeps backups unless explicitly requested to clean
- ✅ **Rollback protection** - backups remain available during upgrade process

## 📌 Version Pinning Control

The `--keep-pinned` flag gives you precise control over which packages get upgraded:

### When to Use `--keep-pinned`:
- **Testing specific versions** - Keep a package at a known working version
- **Legacy compatibility** - Some packages must stay at exact versions
- **Gradual upgrades** - Upgrade most packages but keep critical ones stable
- **Production stability** - Upgrade dev dependencies but keep core ones pinned

### How It Works:
| Package Format | Without `--keep-pinned` | With `--keep-pinned` |
|---------------|------------------------|----------------------|
| `package: 1.2.3` | ➡️ `package: ^2.0.0` | ✅ `package: 1.2.3` (preserved) |
| `package: ^1.2.3` | ➡️ `package: ^2.0.0` | ➡️ `package: ^2.0.0` (upgraded) |
| `package: any` | ➡️ `package: ^2.0.0` | ➡️ `package: ^2.0.0` (upgraded) |

### Examples:
```bash
# Keep specific versions pinned, upgrade everything else
flutter-deps-upgrade upgrade my_app --keep-pinned

# Preview what would be preserved vs upgraded  
flutter-deps-upgrade analyze my_app --keep-pinned

# Use with validation to ensure pinned versions still work
flutter-deps-upgrade upgrade my_app --keep-pinned --validate
```

## 📋 Example Output

### Normal Upgrade:
```
🚀 Upgrading Dependencies
✅ Upgrade completed successfully!
  📝 Updated 23 packages

💡 PROFESSIONAL ASSESSMENT:
  ✅ SUCCESSFUL UPGRADE: Your dependency upgrade completed successfully!
  ▶️  NEXT STEPS: Your project is ready for development and production use
```

### With `--keep-pinned` Flag:
```
🚀 Upgrading Dependencies
📌 KEEP_PINNED mode: Preserving exact version pins
✅ Preserved 3 pinned version(s)
  📌 hive: 2.2.3 (preserved)
  📌 logger: 1.4.0 (preserved)
  📝 http: ^1.5.0 (upgraded)
  📝 uuid: ^4.5.1 (upgraded)

💡 PROFESSIONAL ASSESSMENT:
  ✅ SUCCESSFUL UPGRADE: Dependencies upgraded while preserving pinned versions!
  ▶️  NEXT STEPS: Your project is ready for development and production use
```

### With Interactive Backup Cleanup:
```
🚀 Upgrading Dependencies
✅ Upgrade completed successfully!
  📝 Updated 23 packages

💾 Backup files were created during the upgrade process.
   These are useful for rollback but may not be needed if you use git.

[QUESTION] Delete backup files after successful upgrade? [y/N]: y
🗑️  Removed backup: pubspec.yaml.backup.1234567890
🗑️  Removed backup: pubspec.yaml.backup.1234567891
✅ Cleaned up 2 backup file(s)

💡 PROFESSIONAL ASSESSMENT:
  ✅ SUCCESSFUL UPGRADE: Your dependency upgrade completed successfully!
  ▶️  NEXT STEPS: Your project is ready for development and production use
```

### With `--validate` Flag:
```
📋 DETAILED BUILD VALIDATION RESULTS:
✅ Build Performance Summary:
  • Total build time: 33.7s
  • Generated 307 build outputs
  • Executed 4080 build actions
  • Code generation: 47 files created

⚠️  DETAILED WARNING ANALYSIS (Safe to ignore):
  • 38 packages have newer versions - CLI found the best compatible versions
  • Analyzer version mismatch - Expected and safe
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
# Same command as initial install - automatically upgrades existing installation
curl -fsSL https://github.com/MarnesMukuru/flutter_deps_manager/releases/download/v1.1.7/install.sh | bash
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

**For System-Wide Installation:**
1. Check if installed: `ls -la /usr/local/bin/flutter-deps-upgrade`
2. If missing, reinstall: `curl -fsSL ... | bash`

**For User Installation:**
1. **Restart your terminal** (PATH was added automatically)
2. Or reload shell: `source ~/.zshrc` (or `~/.bashrc`)
3. Check installation: `ls -la ~/.local/bin/flutter-deps-upgrade`

### Still Having Issues?

```bash
# Check which installation mode was used
which flutter-deps-upgrade

# If system-wide install failed, force user install
FLUTTER_DEPS_INSTALL_DIR=~/.local curl -fsSL https://github.com/MarnesMukuru/flutter_deps_manager/releases/download/v1.1.7/install.sh | bash

# Manually add to PATH (if needed)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Download Issues
- Check internet connection
- Try manual download from [GitHub releases](https://github.com/MarnesMukuru/flutter_deps_manager/releases)
- Use alternative download method (wget vs curl)

## 📦 GitHub Releases

Find all versions and download archives manually:
- **Releases**: [https://github.com/MarnesMukuru/flutter_deps_manager/releases](https://github.com/MarnesMukuru/flutter_deps_manager/releases)
- **Latest**: [Download tar.gz](https://github.com/MarnesMukuru/flutter_deps_manager/releases/latest/download/flutter-deps-upgrade-1.1.7.tar.gz)
- **Checksums**: Verify integrity with provided SHA256 checksums

---

**Simple, safe, and effective! 🚀**