import 'package:jaguar_jwt/jaguar_jwt.dart';

import '../hello_aqueduct.dart';

mixin TokenUtils {
  static bool isTokenValid(String token) {
    try {
      final jwtClaim = verifyJwtHS256Signature(token, Constants.JWT_KEY);
      return jwtClaim != null;
    } catch (e) {
      return false;
    }
  }

  static String generatToken([List<String> audience]) {
    final claimSet = JwtClaim(
      audience: audience,
      maxAge: const Duration(minutes: 5),
    );
    return issueJwtHS256(claimSet, Constants.JWT_KEY);
  }
}
