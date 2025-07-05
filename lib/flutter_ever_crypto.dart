import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// Error codes from the Rust FFI
enum FFIError {
  success(0),
  invalidInput(-1),
  encryptionError(-2),
  decryptionError(-3),
  keyError(-4),
  memoryError(-5);

  const FFIError(this.value);
  final int value;

  static FFIError fromValue(int value) {
    return FFIError.values.firstWhere((e) => e.value == value);
  }
}

// FFI result structures
final class FFIKeyResult extends Struct {
  external Pointer<Uint8> data;
  @Size()
  external int len;
  @Int32()
  external int error;
}

final class FFIDataResult extends Struct {
  external Pointer<Uint8> data;
  @Size()
  external int len;
  @Int32()
  external int error;
}

final class FFIKyberKeyPair extends Struct {
  external Pointer<Uint8> publicKey;
  @Size()
  external int publicKeyLen;
  external Pointer<Uint8> secretKey;
  @Size()
  external int secretKeyLen;
  @Int32()
  external int error;
}

final class FFIKyberEncapsulateResult extends Struct {
  external Pointer<Uint8> sharedSecret;
  @Size()
  external int sharedSecretLen;
  external Pointer<Uint8> ciphertext;
  @Size()
  external int ciphertextLen;
  @Int32()
  external int error;
}

// FFI function typedefs
typedef FFIKeyResultNative = FFIKeyResult Function();
typedef FFIKeyResultDart = FFIKeyResult Function();

typedef FFIEncryptNative = FFIDataResult Function(
  Pointer<Uint8> keyPtr,
  Size keyLen,
  Pointer<Uint8> noncePtr,
  Size nonceLen,
  Pointer<Uint8> plaintextPtr,
  Size plaintextLen,
  Pointer<Uint8> aadPtr,
  Size aadLen,
);
typedef FFIEncryptDart = FFIDataResult Function(
  Pointer<Uint8> keyPtr,
  int keyLen,
  Pointer<Uint8> noncePtr,
  int nonceLen,
  Pointer<Uint8> plaintextPtr,
  int plaintextLen,
  Pointer<Uint8> aadPtr,
  int aadLen,
);

typedef FFIKyberKeyPairNative = FFIKyberKeyPair Function();
typedef FFIKyberKeyPairDart = FFIKyberKeyPair Function();

typedef FFIKyberEncapsulateNative = FFIKyberEncapsulateResult Function(
  Pointer<Uint8> publicKeyPtr,
  Size publicKeyLen,
);
typedef FFIKyberEncapsulateDart = FFIKyberEncapsulateResult Function(
  Pointer<Uint8> publicKeyPtr,
  int publicKeyLen,
);

typedef FFIKyberDecapsulateNative = FFIDataResult Function(
  Pointer<Uint8> ciphertextPtr,
  Size ciphertextLen,
  Pointer<Uint8> secretKeyPtr,
  Size secretKeyLen,
);
typedef FFIKyberDecapsulateDart = FFIDataResult Function(
  Pointer<Uint8> ciphertextPtr,
  int ciphertextLen,
  Pointer<Uint8> secretKeyPtr,
  int secretKeyLen,
);

typedef FFIFreeBytesNative = Void Function(Pointer<Uint8> ptr, Size len);
typedef FFIFreeBytesDart = void Function(Pointer<Uint8> ptr, int len);

/// Exception thrown when Ever Crypto operations fail
class EverCryptoException implements Exception {
  final String message;
  final FFIError error;

  const EverCryptoException(this.message, this.error);

  @override
  String toString() => 'EverCryptoException: $message (${error.name})';
}

/// Main class for Ever Crypto operations
class EverCrypto {
  static DynamicLibrary? _dylib;

  // Function pointers
  static late FFIKeyResultDart _xchachaGenerateKey;
  static late FFIKeyResultDart _xchachaGenerateNonce;
  static late FFIEncryptDart _xchachaEncrypt;
  static late FFIEncryptDart _xchachaDecrypt;
  static late FFIKyberKeyPairDart _kyberGenerateKeypair;
  static late FFIKyberEncapsulateDart _kyberEncapsulate;
  static late FFIKyberDecapsulateDart _kyberDecapsulate;
  static late FFIFreeBytesDart _freeBytes;

  /// Initialize the library by loading the native library
  static void init() {
    if (_dylib != null) return; // Already initialized

    try {
      _dylib = _loadLibrary();

      // Bind functions
      _xchachaGenerateKey = _dylib!
          .lookup<NativeFunction<FFIKeyResultNative>>('xchacha_generate_key')
          .asFunction();
      _xchachaGenerateNonce = _dylib!
          .lookup<NativeFunction<FFIKeyResultNative>>('xchacha_generate_nonce')
          .asFunction();
      _xchachaEncrypt = _dylib!
          .lookup<NativeFunction<FFIEncryptNative>>('xchacha_encrypt')
          .asFunction();
      _xchachaDecrypt = _dylib!
          .lookup<NativeFunction<FFIEncryptNative>>('xchacha_decrypt')
          .asFunction();
      _kyberGenerateKeypair = _dylib!
          .lookup<NativeFunction<FFIKyberKeyPairNative>>(
              'kyber_generate_keypair')
          .asFunction();
      _kyberEncapsulate = _dylib!
          .lookup<NativeFunction<FFIKyberEncapsulateNative>>(
              'kyber_encapsulate')
          .asFunction();
      _kyberDecapsulate = _dylib!
          .lookup<NativeFunction<FFIKyberDecapsulateNative>>(
              'kyber_decapsulate')
          .asFunction();
      _freeBytes = _dylib!
          .lookup<NativeFunction<FFIFreeBytesNative>>('free_bytes')
          .asFunction();
    } catch (e) {
      throw EverCryptoException(
        'Failed to initialize flutter_ever_crypto: ${e.toString()}',
        FFIError.memoryError,
      );
    }
  }

  static DynamicLibrary _loadLibrary() {
    const libName = 'flutter_ever_crypto';

    try {
      if (Platform.isIOS || Platform.isMacOS) {
        return DynamicLibrary.executable();
      } else if (Platform.isAndroid) {
        return DynamicLibrary.open('lib$libName.so');
      } else if (Platform.isLinux) {
        return DynamicLibrary.open('lib$libName.so');
      } else if (Platform.isWindows) {
        return DynamicLibrary.open('$libName.dll');
      } else {
        throw UnsupportedError(
          'Unsupported platform: ${Platform.operatingSystem}',
        );
      }
    } catch (e) {
      throw Exception(
        'Failed to load flutter_ever_crypto native library on ${Platform.operatingSystem}. '
        'Make sure the library is properly built and included in your app. '
        'Error: ${e.toString()}',
      );
    }
  }

  /// Copy data from Rust-allocated memory to Dart Uint8List
  static Uint8List _copyFromRustPointer(Pointer<Uint8> ptr, int len) {
    final result = Uint8List(len);
    for (int i = 0; i < len; i++) {
      result[i] = ptr[i];
    }
    return result;
  }

  /// Copy Dart Uint8List to FFI-allocated memory for passing to Rust
  static Pointer<Uint8> _copyToDartPointer(Uint8List data) {
    final ptr = calloc<Uint8>(data.length);
    for (int i = 0; i < data.length; i++) {
      ptr[i] = data[i];
    }
    return ptr;
  }

  /// Generate a random XChaCha20Poly1305 key (32 bytes)
  static Uint8List generateXChaChaKey() {
    init();
    final result = _xchachaGenerateKey();
    final error = FFIError.fromValue(result.error);

    if (error != FFIError.success) {
      throw EverCryptoException('Failed to generate XChaCha key', error);
    }

    final keyData = _copyFromRustPointer(result.data, result.len);
    _freeBytes(result.data, result.len);
    return keyData;
  }

  /// Generate a random XChaCha20Poly1305 nonce (24 bytes)
  static Uint8List generateXChaChaNonce() {
    init();
    final result = _xchachaGenerateNonce();
    final error = FFIError.fromValue(result.error);

    if (error != FFIError.success) {
      throw EverCryptoException('Failed to generate XChaCha nonce', error);
    }

    final nonceData = _copyFromRustPointer(result.data, result.len);
    _freeBytes(result.data, result.len);
    return nonceData;
  }

  /// Encrypt data with XChaCha20Poly1305
  static Uint8List xchachaEncrypt(
    Uint8List key,
    Uint8List nonce,
    Uint8List plaintext, {
    Uint8List? aad,
  }) {
    init();

    final keyPtr = _copyToDartPointer(key);
    final noncePtr = _copyToDartPointer(nonce);
    final plaintextPtr = _copyToDartPointer(plaintext);
    final aadPtr = aad != null ? _copyToDartPointer(aad) : nullptr;

    try {
      final result = _xchachaEncrypt(
        keyPtr,
        key.length,
        noncePtr,
        nonce.length,
        plaintextPtr,
        plaintext.length,
        aadPtr,
        aad?.length ?? 0,
      );

      final error = FFIError.fromValue(result.error);
      if (error != FFIError.success) {
        throw EverCryptoException('Failed to encrypt data', error);
      }

      final ciphertext = _copyFromRustPointer(result.data, result.len);
      _freeBytes(result.data, result.len);
      return ciphertext;
    } finally {
      calloc.free(keyPtr);
      calloc.free(noncePtr);
      calloc.free(plaintextPtr);
      if (aadPtr != nullptr) calloc.free(aadPtr);
    }
  }

  /// Decrypt data with XChaCha20Poly1305
  static Uint8List xchachaDecrypt(
    Uint8List key,
    Uint8List nonce,
    Uint8List ciphertext, {
    Uint8List? aad,
  }) {
    init();

    final keyPtr = _copyToDartPointer(key);
    final noncePtr = _copyToDartPointer(nonce);
    final ciphertextPtr = _copyToDartPointer(ciphertext);
    final aadPtr = aad != null ? _copyToDartPointer(aad) : nullptr;

    try {
      final result = _xchachaDecrypt(
        keyPtr,
        key.length,
        noncePtr,
        nonce.length,
        ciphertextPtr,
        ciphertext.length,
        aadPtr,
        aad?.length ?? 0,
      );

      final error = FFIError.fromValue(result.error);
      if (error != FFIError.success) {
        throw EverCryptoException('Failed to decrypt data', error);
      }

      final plaintext = _copyFromRustPointer(result.data, result.len);
      _freeBytes(result.data, result.len);
      return plaintext;
    } finally {
      calloc.free(keyPtr);
      calloc.free(noncePtr);
      calloc.free(ciphertextPtr);
      if (aadPtr != nullptr) calloc.free(aadPtr);
    }
  }

  /// Generate a Kyber1024 key pair
  static KyberKeyPair generateKyberKeyPair() {
    init();
    final result = _kyberGenerateKeypair();
    final error = FFIError.fromValue(result.error);

    if (error != FFIError.success) {
      throw EverCryptoException('Failed to generate Kyber key pair', error);
    }

    final publicKey = _copyFromRustPointer(
      result.publicKey,
      result.publicKeyLen,
    );
    final secretKey = _copyFromRustPointer(
      result.secretKey,
      result.secretKeyLen,
    );

    _freeBytes(result.publicKey, result.publicKeyLen);
    _freeBytes(result.secretKey, result.secretKeyLen);

    return KyberKeyPair(publicKey: publicKey, secretKey: secretKey);
  }

  /// Encapsulate a shared secret with Kyber1024
  static KyberEncapsulateResult kyberEncapsulate(Uint8List publicKey) {
    init();

    final publicKeyPtr = _copyToDartPointer(publicKey);

    try {
      final result = _kyberEncapsulate(publicKeyPtr, publicKey.length);
      final error = FFIError.fromValue(result.error);

      if (error != FFIError.success) {
        throw EverCryptoException('Failed to encapsulate with Kyber', error);
      }

      final sharedSecret = _copyFromRustPointer(
        result.sharedSecret,
        result.sharedSecretLen,
      );
      final ciphertext = _copyFromRustPointer(
        result.ciphertext,
        result.ciphertextLen,
      );

      _freeBytes(result.sharedSecret, result.sharedSecretLen);
      _freeBytes(result.ciphertext, result.ciphertextLen);

      return KyberEncapsulateResult(
        sharedSecret: sharedSecret,
        ciphertext: ciphertext,
      );
    } finally {
      calloc.free(publicKeyPtr);
    }
  }

  /// Decapsulate a shared secret with Kyber1024
  static Uint8List kyberDecapsulate(Uint8List ciphertext, Uint8List secretKey) {
    init();

    final ciphertextPtr = _copyToDartPointer(ciphertext);
    final secretKeyPtr = _copyToDartPointer(secretKey);

    try {
      final result = _kyberDecapsulate(
        ciphertextPtr,
        ciphertext.length,
        secretKeyPtr,
        secretKey.length,
      );

      final error = FFIError.fromValue(result.error);
      if (error != FFIError.success) {
        throw EverCryptoException('Failed to decapsulate with Kyber', error);
      }

      final sharedSecret = _copyFromRustPointer(result.data, result.len);
      _freeBytes(result.data, result.len);
      return sharedSecret;
    } finally {
      calloc.free(ciphertextPtr);
      calloc.free(secretKeyPtr);
    }
  }
}

/// Kyber1024 key pair
class KyberKeyPair {
  final Uint8List publicKey;
  final Uint8List secretKey;

  const KyberKeyPair({required this.publicKey, required this.secretKey});
}

/// Result of Kyber1024 encapsulation
class KyberEncapsulateResult {
  final Uint8List sharedSecret;
  final Uint8List ciphertext;

  const KyberEncapsulateResult({
    required this.sharedSecret,
    required this.ciphertext,
  });
}
