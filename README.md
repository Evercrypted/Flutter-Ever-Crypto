# flutter_ever_crypto

A Flutter plugin that provides XChaCha20Poly1305 and Kyber1024 post-quantum cryptography through FFI bindings to the Rust `ever-crypto` library.

## Features

- **XChaCha20Poly1305**: Authenticated encryption with extended nonce
- **Kyber1024**: Post-quantum key encapsulation mechanism
- **Cross-platform**: Supports Android, iOS, Linux, macOS, and Windows
- **High performance**: Native Rust implementation with FFI bindings
- **Memory safe**: Proper memory management with automatic cleanup

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_ever_crypto: ^0.1.2
```

## Usage

### XChaCha20Poly1305 Encryption/Decryption

```dart
import 'package:flutter_ever_crypto/flutter_ever_crypto.dart';

// Generate a random key and nonce
final key = EverCrypto.generateXChaChaKey();
final nonce = EverCrypto.generateXChaChaNonce();

// Encrypt data
final plaintext = Uint8List.fromList(utf8.encode('Hello, World!'));
final ciphertext = EverCrypto.xchachaEncrypt(key, nonce, plaintext);

// Decrypt data
final decrypted = EverCrypto.xchachaDecrypt(key, nonce, ciphertext);
final decryptedText = utf8.decode(decrypted);
print(decryptedText); // Output: Hello, World!
```

### Kyber1024 Key Exchange

```dart
import 'package:flutter_ever_crypto/flutter_ever_crypto.dart';

// Generate a key pair
final keyPair = EverCrypto.generateKyberKeyPair();

// Encapsulate a shared secret (Alice's side)
final encapsulateResult = EverCrypto.kyberEncapsulate(keyPair.publicKey);

// Decapsulate the shared secret (Bob's side)
final decapsulatedSecret = EverCrypto.kyberDecapsulate(
  encapsulateResult.ciphertext, 
  keyPair.secretKey
);

// Both sides now have the same shared secret
print(encapsulateResult.sharedSecret.toString() == decapsulatedSecret.toString()); // true
```

## API Reference

### EverCrypto Class

#### XChaCha20Poly1305 Methods

- `Uint8List generateXChaChaKey()`: Generate a random 32-byte key
- `Uint8List generateXChaChaNonce()`: Generate a random 24-byte nonce
- `Uint8List xchachaEncrypt(Uint8List key, Uint8List nonce, Uint8List plaintext, {Uint8List? aad})`: Encrypt data
- `Uint8List xchachaDecrypt(Uint8List key, Uint8List nonce, Uint8List ciphertext, {Uint8List? aad})`: Decrypt data

#### Kyber1024 Methods

- `KyberKeyPair generateKyberKeyPair()`: Generate a new key pair
- `KyberEncapsulateResult kyberEncapsulate(Uint8List publicKey)`: Encapsulate a shared secret
- `Uint8List kyberDecapsulate(Uint8List ciphertext, Uint8List secretKey)`: Decapsulate a shared secret

### Data Structures

- `KyberKeyPair`: Contains public and secret keys
- `KyberEncapsulateResult`: Contains shared secret and ciphertext

## Error Handling

The plugin throws `EverCryptoException` when operations fail:

```dart
try {
  final key = EverCrypto.generateXChaChaKey();
  // ... use the key
} on EverCryptoException catch (e) {
  print('Crypto operation failed: ${e.message}');
}
```

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ Linux
- ✅ macOS
- ✅ Windows

## Dependencies

This plugin depends on the Rust `ever-crypto` library which provides:

- `chacha20poly1305`: XChaCha20Poly1305 implementation
- `pqcrypto-kyber`: Kyber1024 implementation
- `zeroize`: Secure memory zeroing

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
