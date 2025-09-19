# Simple Release Process

## How to Update Version

**Step 1**: Edit the version
```bash
echo "1.2.0" > VERSION
```

**Step 2**: Update all files automatically
```bash
./update-all-versions.sh
```

**Step 3**: Commit and tag
```bash
git add -A
git commit -m "Release v1.2.0"
git tag v1.2.0
git push origin main
git push origin v1.2.0
```

**Step 4**: Build packages (optional - for additional downloads)
```bash
./build.sh  # Only if you want .tar.gz/.zip packages
```

That's it! ✅

Users can now install with:
```bash
curl -fsSL https://github.com/MarnesMukuru/flutter_deps_manager/releases/download/v1.2.0/install.sh | bash
```

## What Gets Updated Automatically

- ✅ `flutter-deps-upgrade` (main CLI script)
- ✅ `install.sh` (installer script)
- ✅ `install-cli.sh` (CLI installer)
- ✅ `homebrew-formula/flutter-deps-upgrade.rb` (Homebrew formula)
- ✅ `README.md` (download links and version references)
- ✅ `homebrew-formula/README.md` (Homebrew documentation)

## Files Explained

- **`VERSION`** - Single source of truth (just the version number)
- **`update-all-versions.sh`** - Updates all files with the new version
- **`RELEASE.md`** - This file (usage instructions)

Simple and automatic! 🚀
