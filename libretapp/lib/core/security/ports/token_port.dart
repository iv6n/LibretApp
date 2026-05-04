/// core › security › ports › token_port — abstract token storage port.
library;

import 'package:libretapp/core/security/models/security_types.dart';

/// Port (interface) for secure token persistence and retrieval.
abstract class TokenPort {
  Future<void> storeTokenBundle(TokenBundle bundle);

  Future<TokenBundle?> loadTokenBundle();

  Future<void> clearTokens();

  Future<bool> isAccessTokenExpired();
}
