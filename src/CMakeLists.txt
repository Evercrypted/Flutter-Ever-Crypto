# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(flutter_ever_crypto_library VERSION 0.0.1 LANGUAGES C)

# Use CargoKit to build the Rust library
set(CARGOKIT_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../cargokit")

# Include CargoKit cmake module
include("${CARGOKIT_ROOT}/cmake/cargokit.cmake")

# Build the Rust library using CargoKit
# This will create a flutter_ever_crypto_cargokit target and build the Rust library
# The Rust library will be used directly by Dart FFI, no C wrapper needed
apply_cargokit(flutter_ever_crypto "../rust" "flutter_ever_crypto" "xchacha_generate_key")
