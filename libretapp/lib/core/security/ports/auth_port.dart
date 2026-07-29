/// core › security › ports › auth_port — abstract authentication port.
library;

import 'package:libretapp/core/security/models/security_types.dart';

abstract class AuthPort {
  Future<AuthResult> signIn(AuthCredentials credentials);

  /// Creates a new account. Implementations that don't support self-service
  /// sign-up (e.g. the local stub) may return a failed [AuthResult].
  Future<AuthResult> signUp(AuthCredentials credentials);

  Future<void> signOut();

  Future<bool> isSessionValid();

  /// The signed-in user's id, or null when there's no active session.
  /// Used to scope cloud-backup rows to their owner.
  String? get currentUserId;
}
