#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_ever_crypto.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_ever_crypto'
  s.version          = '0.1.0'
  s.summary          = 'Flutter plugin for Ever Crypto - XChaCha20Poly1305 and Kyber1024 post-quantum cryptography'
  s.description      = <<-DESC
A Flutter plugin that provides XChaCha20Poly1305 and Kyber1024 post-quantum cryptography through FFI bindings to the Rust ever-crypto library.
                       DESC
  s.homepage         = 'https://github.com/evercrypted/flutter-ever-crypto'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Evercrypted' => 'contact@evercrypted.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.14'

  # CargoKit integration
  s.script_phase = {
    :name => 'Build Rust library',
    :script => 'sh "$PODS_TARGET_SRCROOT/../cargokit/build_pod.sh" ../rust flutter_ever_crypto',
    :execution_position => :before_compile,
    :input_files => ['${BUILT_PRODUCTS_DIR}/cargokit_phony'],
    :output_files => ["${BUILT_PRODUCTS_DIR}/libflutter_ever_crypto.a"],
  }
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_LDFLAGS' => '-force_load ${BUILT_PRODUCTS_DIR}/libflutter_ever_crypto.a',
  }
  s.swift_version = '5.0'
end
