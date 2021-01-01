import 'dart:math';

import 'package:jaguar_jwt/jaguar_jwt.dart';

import '../hello_aqueduct.dart';

abstract class TokenUtils {
  static bool isTokenValid(String token) {
    try {
      final jwtClaim = verifyJwtHS256Signature(token, Constants.JWT_KEY);

      final isExpired =
          jwtClaim != null && jwtClaim.expiry.isAfter(DateTime.now());

      return isExpired;
    } catch (e) {
      return false;
    }
  }

  static String generatToken(List<String> audience) {
    audience.add(_randomString(32));
    final claimSet = JwtClaim(
      audience: audience,
      jwtId: _randomString(32),
      maxAge: const Duration(days: 360),
    );
    return issueJwtHS256(claimSet, Constants.JWT_KEY);
  }

  static String _randomString(int length) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final rnd = Random(DateTime.now().millisecondsSinceEpoch);
    final buf = StringBuffer();
    for (var x = 0; x < length; x++) {
      buf.write(chars[rnd.nextInt(chars.length)]);
    }
    return buf.toString();
  }
}
