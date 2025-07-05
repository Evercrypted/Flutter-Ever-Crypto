# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(flutter_ever_crypto_library VERSION 0.0.1 LANGUAGES C)

add_library(flutter_ever_crypto SHARED
  "flutter_ever_crypto.c"
)

set_target_properties(flutter_ever_crypto PROPERTIES
  PUBLIC_HEADER flutter_ever_crypto.h
  OUTPUT_NAME "flutter_ever_crypto"
)

target_compile_definitions(flutter_ever_crypto PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(flutter_ever_crypto PRIVATE "-Wl,-z,max-page-size=16384")
endif()
