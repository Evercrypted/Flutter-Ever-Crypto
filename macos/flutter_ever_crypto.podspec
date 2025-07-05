#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_ever_crypto.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_ever_crypto'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Ever Crypto - XChaCha20Poly1305 and Kyber1024 post-quantum cryptography'
  s.description      = <<-DESC
A Flutter plugin that provides XChaCha20Poly1305 and Kyber1024 post-quantum cryptography through FFI bindings to the Rust ever-crypto library.
                       DESC
  s.homepage         = 'https://github.com/evercrypted/flutter-ever-crypto'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Evercrypted' => 'contact@evercrypted.com' }

  s.source           = { :path => '.' }

  # Build the Rust library
  s.script_phase = {
    :name => 'Build Rust Library',
    :script => <<-SCRIPT,
      set -e
      cd "${PODS_TARGET_SRCROOT}/.."
      
      # Build for macOS
      if [[ "${ARCHS}" == *"arm64"* ]]; then
        cargo build --release --target aarch64-apple-darwin
        TARGET_DIR="target/aarch64-apple-darwin/release"
      else
        cargo build --release --target x86_64-apple-darwin
        TARGET_DIR="target/x86_64-apple-darwin/release"
      fi
      
      # Copy the library to the expected location
      mkdir -p "${BUILT_PRODUCTS_DIR}"
      cp "${TARGET_DIR}/libflutter_ever_crypto.dylib" "${BUILT_PRODUCTS_DIR}/libflutter_ever_crypto.dylib"
SCRIPT
    :execution_position => :before_compile
  }

  # Link the dynamic library
  s.vendored_libraries = "libflutter_ever_crypto.dylib"

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_ever_crypto_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
