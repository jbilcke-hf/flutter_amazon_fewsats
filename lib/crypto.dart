import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:ed25519_edwards/ed25519_edwards.dart';
import 'package:crypto/crypto.dart';

class KeyPair {
  final PrivateKey privateKey;
  final PublicKey publicKey;

  KeyPair(this.privateKey, this.publicKey);
}

/// Generate a new Ed25519 key pair
KeyPair generateKeys() {
  final random = Random.secure();
  final seed = Uint8List(32);
  for (int i = 0; i < 32; i++) {
    seed[i] = random.nextInt(256);
  }
  
  final privateKey = newKeyFromSeed(seed);
  final publicKey = public(privateKey);
  
  return KeyPair(privateKey, publicKey);
}

/// Create a key pair from a hex-encoded private key
KeyPair fromPkHex(String privHex) {
  final privBytes = _hexToBytes(privHex);
  final privateKey = newKeyFromSeed(privBytes);
  final publicKey = public(privateKey);
  
  return KeyPair(privateKey, publicKey);
}

/// Convert private key to hex string
String privKeyHex(PrivateKey privateKey) {
  return _bytesToHex(privateKey.bytes);
}

/// Convert public key to hex string
String pubKeyHex(PublicKey publicKey) {
  return _bytesToHex(publicKey.bytes);
}

/// Convert hex string to bytes
Uint8List _hexToBytes(String hex) {
  final result = Uint8List(hex.length ~/ 2);
  for (int i = 0; i < hex.length; i += 2) {
    result[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
  }
  return result;
}

/// Convert bytes to hex string
String _bytesToHex(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}