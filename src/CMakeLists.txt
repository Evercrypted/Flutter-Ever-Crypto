# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(flutter_ever_crypto_library VERSION 0.0.1 LANGUAGES C)

# Set the path to the parent directory (where Cargo.toml is located)
set(CRATE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/..")

# Determine the target architecture for Android
if(ANDROID)
    if(CMAKE_ANDROID_ARCH_ABI STREQUAL "arm64-v8a")
        set(RUST_TARGET "aarch64-linux-android")
    elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "armeabi-v7a")
        set(RUST_TARGET "armv7-linux-androideabi")
    elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "x86")
        set(RUST_TARGET "i686-linux-android")
    elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "x86_64")
        set(RUST_TARGET "x86_64-linux-android")
    else()
        message(FATAL_ERROR "Unsupported Android ABI: ${CMAKE_ANDROID_ARCH_ABI}")
    endif()
    
    set(RUST_LIB_PATH "${CRATE_DIR}/target/${RUST_TARGET}/release/libflutter_ever_crypto.so")
    set(CARGO_BUILD_TARGET "--target=${RUST_TARGET}")
else()
    # For other platforms, use the default target
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(RUST_LIB_PATH "${CRATE_DIR}/target/debug/libflutter_ever_crypto.so")
        set(CARGO_BUILD_PROFILE "")
    else()
        set(RUST_LIB_PATH "${CRATE_DIR}/target/release/libflutter_ever_crypto.so")
        set(CARGO_BUILD_PROFILE "--release")
    endif()
    set(CARGO_BUILD_TARGET "")
endif()

# Build the Rust library
add_custom_command(
    OUTPUT ${RUST_LIB_PATH}
    COMMAND cargo build ${CARGO_BUILD_PROFILE} ${CARGO_BUILD_TARGET}
    WORKING_DIRECTORY ${CRATE_DIR}
    COMMENT "Building Rust library"
    VERBATIM
)

# Create a custom target that depends on the Rust library
add_custom_target(rust_lib ALL DEPENDS ${RUST_LIB_PATH})

# Create an imported library target
add_library(flutter_ever_crypto SHARED IMPORTED GLOBAL)
add_dependencies(flutter_ever_crypto rust_lib)

# Set the imported library location
set_target_properties(flutter_ever_crypto PROPERTIES
    IMPORTED_LOCATION ${RUST_LIB_PATH}
)

if (ANDROID)
  # Support Android 15 16k page size
  set_target_properties(flutter_ever_crypto PROPERTIES
    IMPORTED_LINK_INTERFACE_LIBRARIES "-Wl,-z,max-page-size=16384"
  )
endif()
