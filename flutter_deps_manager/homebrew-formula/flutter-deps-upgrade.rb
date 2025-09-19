class FlutterDepsUpgrade < Formula
  desc "Intelligent Flutter dependency upgrader with automatic monorepo detection"
  homepage "https://github.com/marnesfourie/flutter_deps_manager_project"
  url "https://github.com/marnesfourie/flutter_deps_manager_project/releases/download/v1.1.8/flutter-deps-upgrade-1.1.7.tar.gz"
  sha256 ""  # This will need to be updated with the actual SHA256 from the release
  license "MIT"  # Update with your actual license
  version "1.1.8"
  
  depends_on "flutter" => :recommended
  uses_from_macos "curl"
  uses_from_macos "tar"
  
  def install
    # Install the main executable
    bin.install "flutter-deps-upgrade"
    
    # Install the core functions library
    libexec.install "core-functions.sh"
    
    # Update the executable to use the correct library path
    inreplace bin/"flutter-deps-upgrade", '${SCRIPT_DIR}/core-functions.sh', "#{libexec}/core-functions.sh"
    
    # Install documentation
    doc.install "README.md"
    doc.install "MANIFEST" if File.exist?("MANIFEST")
  end
  
  def post_install
    ohai "Flutter Dependencies Upgrade CLI installed successfully!"
    puts <<~EOS
      🚀 Usage:
        flutter-deps-upgrade --help                    # Show help
        flutter-deps-upgrade analyze app               # Preview upgrades
        flutter-deps-upgrade upgrade --all --validate  # Upgrade all projects
      
      📖 Documentation: #{homepage}#readme
      
      ⚠️  Note: Flutter SDK is required for this tool to function properly.
      Install Flutter: https://flutter.dev/docs/get-started/install
    EOS
  end
  
  test do
    # Test that the CLI can show version and help
    assert_match version.to_s, shell_output("#{bin}/flutter-deps-upgrade --version")
    assert_match "Flutter Dependencies Upgrade CLI", shell_output("#{bin}/flutter-deps-upgrade --help")
    
    # Test that the core functions file is accessible
    assert_predicate libexec/"core-functions.sh", :exist?
  end
end
