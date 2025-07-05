# Changelog

## 0.1.4

* **BREAKING**: Integrated CargoKit for proper cross-platform Rust builds
* Fixed Android build issues with proper NDK cross-compilation
* Resolved library conflicts between flutter_ever_crypto and rhttp
* Updated to use published ever-crypto 0.1.0 from crates.io
* Improved build system with automatic platform-specific compilation
* Added support for all Android architectures (arm64-v8a, armeabi-v7a, x86, x86_64)

## 0.1.3

* Fix FFI initialization error that caused "LateInitializationError" when using the plugin
* Improved error handling and messages for library loading failures
* Better debugging information when native library fails to load

## 0.1.2

* Initial release with XChaCha20Poly1305 and Kyber1024 support
* Cross-platform support for Android, iOS, Linux, macOS, and Windows
* FFI bindings to the Rust `ever-crypto` library
* Memory-safe operations with automatic cleanup
* Comprehensive error handling with `EverCryptoException`

## 0.1.1

* Initial development version

## 0.1.0

* Initial development version
