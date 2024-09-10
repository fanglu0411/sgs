import 'dart:convert';
import 'dart:typed_data';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:encrypt/encrypt.dart';

class DioCacheCipher {
  final key = Key.fromUtf8('aZ6vI53B9yT3Xc4kRgH5LdF1U8iD0a53');

  //7F3pY9mGq5nDx2
  final iv = IV.fromBase64('N0YwcDltR3E1bkR4Mg==');

  late Encrypter encrypter;

  DioCacheCipher() {
    encrypter = Encrypter(AES(key, mode: AESMode.sic));
  }

  Future<List<int>> encrypt(List<int> bytes) {
    try {
      return Future.value(encrypter.encryptBytes(bytes, iv: iv).bytes);
    } catch (e) {
      print('encrypt');
      print(e);
      return Future.value(bytes);
    }
  }

  Future<List<int>> decrypt(List<int> bytes) {
    try {
      return Future.value(encrypter.decryptBytes(Encrypted(Uint8List.fromList(bytes)), iv: iv));
    } catch (e) {
      print(e);
      return Future.value(bytes);
    }
  }

  test() {
    final plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    print(decrypted);
    encrypter.decryptBytes(Encrypted(encrypted.bytes));
    print(encrypter.decryptBytes(encrypted));
  }
}
