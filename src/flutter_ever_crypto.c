// C stub file for flutter_ever_crypto
// This file provides a minimal C interface that links with the Rust library
// The actual implementations are in the Rust code

#include "flutter_ever_crypto.h"

// A very short-lived native function.
//
// For very short-lived functions, it is fine to call them on the main isolate.
// They will block the Dart execution while running the native function, so
// only do this for native functions which are guaranteed to be short-lived.
FFI_PLUGIN_EXPORT int sum(int a, int b) { return a + b; }

// A longer-lived native function, which occupies the thread calling it.
//
// Do not call these kind of native functions in the main isolate. They will
// block Dart execution. This will cause dropped frames in Flutter applications.
// Instead, call these native functions on a separate isolate.
FFI_PLUGIN_EXPORT int sum_long_running(int a, int b) {
  // Simulate work.
#if _WIN32
  Sleep(5000);
#else
  usleep(5000 * 1000);
#endif
  return a + b;
}

// This is a minimal C stub that allows the library to be loaded
// The actual FFI functions are implemented in Rust and will be linked in
void flutter_ever_crypto_init(void) {
    // This function is called when the library is loaded
    // The Rust FFI functions will be available through the dynamic library
}
