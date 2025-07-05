# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(flutter_ever_crypto_library VERSION 0.0.1 LANGUAGES C)

# Use CargoKit to build the Rust library
set(CARGOKIT_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../cargokit")
set(RUST_CRATE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../rust")

# Include CargoKit cmake module
include("${CARGOKIT_ROOT}/cmake/cargokit.cmake")

# Build the Rust library using CargoKit
apply_cargokit(flutter_ever_crypto "${RUST_CRATE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}")

# Create the library target
add_library(flutter_ever_crypto SHARED
  "flutter_ever_crypto.c"
)

# Link the Rust library
target_link_libraries(flutter_ever_crypto flutter_ever_crypto_rust)

set_target_properties(flutter_ever_crypto PROPERTIES
  PUBLIC_HEADER flutter_ever_crypto.h
  OUTPUT_NAME "flutter_ever_crypto"
)

target_compile_definitions(flutter_ever_crypto PUBLIC DART_SHARED_LIB)
