import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

class EncryptionService {
  // Generate a key for AES encryption
  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');

  // Create the AES encrypter
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  // Encrypt the given plain text
  static String encryptMessage(String plainText) {
    final iv = encrypt.IV.fromLength(16);  // Generate a random IV for each encryption
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    // Prepend IV to the encrypted message
    final encryptedWithIv = iv.base64 + encrypted.base64;
    return encryptedWithIv;
  }

  // Decrypt the given encrypted text
  static String decryptMessage(String encryptedText) {
    // Extract the IV from the first 16 bytes (base64 encoded)
    final iv = encrypt.IV.fromBase64(encryptedText.substring(0, 24)); // 16 bytes IV is 24 base64 characters
    final encrypted = encryptedText.substring(24); // The rest is the encrypted message
    final decrypted = _encrypter.decrypt64(encrypted, iv: iv);
    return decrypted;
  }
}
