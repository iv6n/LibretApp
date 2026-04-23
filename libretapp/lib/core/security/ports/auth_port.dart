import 'package:libretapp/core/security/models/security_types.dart';

abstract class AuthPort {
  Future<AuthResult> signIn(AuthCredentials credentials);

  Future<void> signOut();

  Future<bool> isSessionValid();
}
