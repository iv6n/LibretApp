import 'perfil_model.dart';

/// Only the optional personal/ranch fields count as a supplied profile.
bool hasProfileDetails(Perfil profile) => [
  profile.nombre,
  profile.apellido,
  profile.email,
  profile.telefono,
  profile.finca,
  profile.upp,
  profile.direccion,
].any((value) => value.trim().isNotEmpty);

String? validateOptionalProfileEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty || RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
    return null;
  }
  return 'Revisa el correo o deja este campo vacío.';
}
