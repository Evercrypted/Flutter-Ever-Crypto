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
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Build the Rust library
  s.script_phase = {
    :name => 'Build Rust Library',
    :script => <<-SCRIPT,
      set -e
      cd "${PODS_TARGET_SRCROOT}/.."
      
      # Build for iOS device (arm64)
      if [[ "${PLATFORM_NAME}" == "iphoneos" ]]; then
        cargo build --release --target aarch64-apple-ios
        TARGET_DIR="target/aarch64-apple-ios/release"
      # Build for iOS simulator
      elif [[ "${PLATFORM_NAME}" == "iphonesimulator" ]]; then
        if [[ "${ARCHS}" == *"arm64"* ]]; then
          cargo build --release --target aarch64-apple-ios-sim
          TARGET_DIR="target/aarch64-apple-ios-sim/release"
        else
          cargo build --release --target x86_64-apple-ios
          TARGET_DIR="target/x86_64-apple-ios/release"
        fi
      else
        echo "Unknown platform: ${PLATFORM_NAME}"
        exit 1
      fi
      
      # Copy the library to the expected location
      mkdir -p "${BUILT_PRODUCTS_DIR}"
      cp "${TARGET_DIR}/libflutter_ever_crypto.a" "${BUILT_PRODUCTS_DIR}/libflutter_ever_crypto.a"
SCRIPT
    :execution_position => :before_compile
  }

  # Link the static library
  s.vendored_libraries = "libflutter_ever_crypto.a"

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
