/// Validation for the optional weight stored on an animal profile.
///
/// A historical zero may remain unchanged while other animal fields are
/// edited. New weights must be positive and finite.
library;

class AnimalInitialWeightPolicy {
  const AnimalInitialWeightPolicy._();

  static bool allows({required double? proposed, required double? persisted}) {
    if (proposed == null) return true;
    if (!proposed.isFinite || proposed < 0) return false;
    if (proposed == 0) return persisted == 0;
    return true;
  }

  static const errorMessage = 'Ingresa un peso mayor que cero.';
}
