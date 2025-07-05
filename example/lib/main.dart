import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_ever_crypto/flutter_ever_crypto.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // Test XChaCha20Poly1305 encryption/decryption
      final key = EverCrypto.generateXChaChaKey();
      final nonce = EverCrypto.generateXChaChaNonce();
      final plaintext = Uint8List.fromList(utf8.encode('Hello, World!'));

      // Encrypt the data
      final ciphertext = EverCrypto.xchachaEncrypt(key, nonce, plaintext);

      // Decrypt the data
      final decrypted = EverCrypto.xchachaDecrypt(key, nonce, ciphertext);

      final decryptedText = utf8.decode(decrypted);

      if (decryptedText == 'Hello, World!') {
        result = 'XChaCha20Poly1305 test: ✅ PASSED\n';
        result += 'Key length: ${key.length} bytes\n';
        result += 'Nonce length: ${nonce.length} bytes\n';
        result += 'Original: Hello, World!\n';
        result += 'Decrypted: $decryptedText\n';
      } else {
        result = 'XChaCha20Poly1305 test: ❌ FAILED';
      }

      // Test Kyber1024 key exchange
      final keyPair = EverCrypto.generateKyberKeyPair();
      final encapsulateResult = EverCrypto.kyberEncapsulate(keyPair.publicKey);
      final decapsulatedSecret = EverCrypto.kyberDecapsulate(
        encapsulateResult.ciphertext,
        keyPair.secretKey,
      );

      if (encapsulateResult.sharedSecret.toString() ==
          decapsulatedSecret.toString()) {
        result += '\nKyber1024 test: ✅ PASSED\n';
        result += 'Public key length: ${keyPair.publicKey.length} bytes\n';
        result += 'Secret key length: ${keyPair.secretKey.length} bytes\n';
        result +=
            'Shared secret length: ${encapsulateResult.sharedSecret.length} bytes\n';
        result +=
            'Secrets match: ${encapsulateResult.sharedSecret.toString() == decapsulatedSecret.toString()}';
      } else {
        result += '\nKyber1024 test: ❌ FAILED';
      }
    } on PlatformException catch (e) {
      result = 'Failed to run crypto tests: ${e.message}';
    } catch (e) {
      result = 'Failed to run crypto tests: $e';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Ever Crypto Example')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Crypto Library Test Results:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _result,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
