/// core › security › ports › auth_port — abstract authentication port.
library;

import 'package:libretapp/core/security/models/security_types.dart';

abstract class AuthPort {
  Future<AuthResult> signIn(AuthCredentials credentials);

  Future<AuthResult> signUp(AuthCredentials credentials);

  Future<void> signOut();

  Future<bool> isSessionValid();

  String? get currentUserId;
}
