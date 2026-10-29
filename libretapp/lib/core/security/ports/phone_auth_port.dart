class VerifiedPhoneIdentity {
  const VerifiedPhoneIdentity({required this.userId, required this.phone});
  final String userId;
  final String phone;
}

class PhoneAuthFailure implements Exception {
  const PhoneAuthFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

enum PhoneAccessIntent { createAccount, signIn }

abstract class PhoneAuthPort {
  bool get available;
  Future<void> requestCode(
    String phone, {
    PhoneAccessIntent intent = PhoneAccessIntent.createAccount,
  });
  Future<VerifiedPhoneIdentity> verifyCode(String phone, String code);
  Future<void> signOut();
}

class UnavailablePhoneAuth implements PhoneAuthPort {
  const UnavailablePhoneAuth();
  @override
  bool get available => false;
  @override
  Future<void> requestCode(
    String phone, {
    PhoneAccessIntent intent = PhoneAccessIntent.createAccount,
  }) async => throw const PhoneAuthFailure(
    'El acceso por teléfono todavía no está disponible. Puedes entrar como invitado.',
  );
  @override
  Future<VerifiedPhoneIdentity> verifyCode(String phone, String code) async =>
      throw const PhoneAuthFailure(
        'El acceso por teléfono no está disponible.',
      );
  @override
  Future<void> signOut() async {}
}

String normalizePhone(String dialCode, String number) {
  final digits = number.replaceAll(RegExp(r'[\s()\-]'), '');
  final prefix = dialCode.replaceAll('+', '').trim();
  final normalized = '+$prefix$digits';
  if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(normalized) ||
      (prefix == '52' && digits.length != 10)) {
    throw const PhoneAuthFailure(
      'Revisa el número. Para México escribe los 10 dígitos, sin +52.',
    );
  }
  return normalized;
}
