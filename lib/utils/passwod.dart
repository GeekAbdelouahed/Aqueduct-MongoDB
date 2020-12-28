import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

mixin PasswordUtils {
  static bool isPasswordValid(
      String givenPassword, String salt, String hashedPassword) {
    final newHashedPassword = hashPassword(givenPassword, salt);
    return newHashedPassword == hashedPassword;
  }

  static String hashPassword(String password, String salt) {
    const codec = Utf8Codec();
    final key = codec.encode(password);
    final saltBytes = codec.encode(salt);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(saltBytes);
    return digest.toString();
  }

  static String getRandomSlat() {
    final rand = Random.secure();
    final saltBytes = List<int>.generate(32, (_) => rand.nextInt(256));
    final salt = base64.encode(saltBytes);
    return salt;
  }
}
