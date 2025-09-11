# Homebrew Formula for Flutter Dependencies Upgrade CLI

This directory contains the Homebrew formula for installing the Flutter Dependencies Upgrade CLI on macOS.

## 🍺 For Users: Installing via Homebrew

### Option 1: Direct Formula Install
```bash
# Install directly from the formula URL
brew install https://raw.githubusercontent.com/marnesfourie/flutter_deps_manager_project/main/homebrew-formula/flutter-deps-upgrade.rb
```

### Option 2: Homebrew Tap (Recommended for Multiple Formulas)

First, create a separate repository for your Homebrew tap:

1. **Create a new repository** named `homebrew-flutter-tools` (or similar)
2. **Copy the formula** to that repository
3. **Install via tap**:

```bash
# Add your tap
brew tap marnesfourie/flutter-tools

# Install the CLI
brew install flutter-deps-upgrade

# Update when new versions are available
brew upgrade flutter-deps-upgrade
```

## 🔧 For Maintainers: Updating the Formula

### When releasing a new version:

1. **Update the version and URL** in the formula:
```ruby
version "1.1.0"
url "https://github.com/marnesfourie/flutter_deps_manager_project/releases/download/v1.1.0/flutter-deps-upgrade-1.1.0.tar.gz"
```

2. **Calculate and update the SHA256**:
```bash
# Download the release archive
curl -fsSL "https://github.com/marnesfourie/flutter_deps_manager_project/releases/download/v1.1.0/flutter-deps-upgrade-1.1.0.tar.gz" -o flutter-deps-upgrade-1.1.0.tar.gz

# Calculate SHA256
shasum -a 256 flutter-deps-upgrade-1.1.0.tar.gz

# Update the formula
sha256 "abc123...your-sha256-here"
```

3. **Test the formula locally**:
```bash
# Test installation
brew install --build-from-source ./flutter-deps-upgrade.rb

# Test functionality
flutter-deps-upgrade --version
flutter-deps-upgrade --help

# Uninstall test version
brew uninstall flutter-deps-upgrade
```

4. **Commit and push** the updated formula

### Setting up a Homebrew Tap Repository

1. **Create new repository**: `homebrew-flutter-tools`
2. **Repository structure**:
```
homebrew-flutter-tools/
├── Formula/
│   └── flutter-deps-upgrade.rb
└── README.md
```

3. **Move the formula**:
```bash
mkdir -p Formula
cp flutter-deps-upgrade.rb Formula/
```

4. **Update users can install via**:
```bash
brew tap marnesfourie/flutter-tools
brew install flutter-deps-upgrade
```

## 🧪 Testing the Formula

### Local Testing
```bash
# Audit the formula
brew audit --strict flutter-deps-upgrade.rb

# Test installation
brew install --build-from-source ./flutter-deps-upgrade.rb

# Test the CLI
flutter-deps-upgrade --version
flutter-deps-upgrade --help

# Test upgrade
brew reinstall flutter-deps-upgrade

# Test uninstall
brew uninstall flutter-deps-upgrade
```

### Formula Requirements Checklist
- [ ] Version matches latest release
- [ ] URL points to correct release archive
- [ ] SHA256 matches the actual archive
- [ ] Dependencies are correctly specified
- [ ] Installation paths are correct
- [ ] Tests pass (`brew test flutter-deps-upgrade`)
- [ ] Post-install message is helpful

## 📋 Homebrew Best Practices

1. **Follow naming conventions**: Use kebab-case for formula names
2. **Include dependencies**: Specify required and optional dependencies
3. **Add meaningful tests**: Test core functionality
4. **Provide helpful messages**: Include post-install instructions
5. **Keep formulas simple**: Avoid complex installation logic
6. **Use semantic versioning**: Follow semver for releases

## 🔗 Useful Links

- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Creating Homebrew Taps](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)
- [Formula Template](https://github.com/Homebrew/brew/blob/master/Library/Homebrew/formula_template.rb)
