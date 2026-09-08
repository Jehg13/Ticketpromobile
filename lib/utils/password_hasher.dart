import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;

class PasswordHasher {
  const PasswordHasher._();

  static String md5(String password) {
    return md5Digest(password);
  }

  static String md5Digest(String password) {
    return md5DigestBytes(utf8.encode(password));
  }

  static String md5DigestBytes(List<int> bytes) {
    return crypto.md5.convert(bytes).toString();
  }
}
