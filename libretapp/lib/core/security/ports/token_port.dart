import 'package:libretapp/core/security/models/security_types.dart';

abstract class TokenPort {
  Future<void> storeTokenBundle(TokenBundle bundle);

  Future<TokenBundle?> loadTokenBundle();

  Future<void> clearTokens();

  Future<bool> isAccessTokenExpired();
}
