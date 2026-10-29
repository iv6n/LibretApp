library;

import '../animal_domain.dart';

class AnimalRecordValidation {
  const AnimalRecordValidation._();

  static DateTime day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static void operation(
    AnimalEntity animal,
    DateTime date, {
    bool editing = false,
  }) {
    if (!editing && !animal.status.isInActiveHerd) {
      throw StateError(
        'El animal salió del hato. Puedes corregir su historial.',
      );
    }
    if (day(date).isAfter(day(DateTime.now()))) {
      throw ArgumentError('La fecha del evento no puede estar en el futuro.');
    }
    if (animal.birthDatePrecision == BirthDatePrecision.exact &&
        day(date).isBefore(day(animal.birthDate))) {
      throw ArgumentError('El evento no puede ser anterior al nacimiento.');
    }
  }

  static void reproduction(ReproductionRecord record) {
    final service = record.serviceDate;
    if (record.kind == ReproductionRecordKind.service &&
        (service == null || record.serviceType == null)) {
      throw ArgumentError('Indica fecha y tipo de servicio.');
    }
    if (record.kind == ReproductionRecordKind.calving &&
        (service != null ||
            record.serviceType != null ||
            record.actualCalvingDate == null)) {
      throw ArgumentError(
        'El parto sin servicio conocido requiere fecha de parto y ningún servicio ficticio.',
      );
    }
    if (record.calvingEase != null &&
        (record.calvingEase! < 1 || record.calvingEase! > 5)) {
      throw ArgumentError('La dificultad del parto debe estar entre 1 y 5.');
    }
    for (final date in [
      service,
      record.pregnancyCheckDate,
      record.actualCalvingDate,
    ]) {
      if (date != null && day(date).isAfter(day(DateTime.now()))) {
        throw ArgumentError('La fecha del evento no puede estar en el futuro.');
      }
    }
    if (service != null) {
      for (final date in [
        record.pregnancyCheckDate,
        record.expectedCalvingDate,
        record.actualCalvingDate,
      ]) {
        if (date != null && day(date).isBefore(day(service))) {
          throw ArgumentError(
            'El diagnóstico o parto no puede ser anterior al servicio.',
          );
        }
      }
    }
    if (record.offspringUuids.toSet().length != record.offspringUuids.length) {
      throw ArgumentError('La cría ya está vinculada.');
    }
    if (record.offspringUuids.isNotEmpty &&
        (record.calvingOutcome == CalvingOutcome.abortion ||
            record.calvingOutcome == CalvingOutcome.stillbirth)) {
      throw ArgumentError(
        'Un aborto o nacimiento muerto no puede tener crías vivas vinculadas.',
      );
    }
  }

  static void health(HealthRecord record) {
    if (requiresProduct(record.type) && record.product.trim().isEmpty)
      throw ArgumentError('Indica el producto aplicado.');
    if (record.withdrawalDays != null && record.withdrawalDays! < 0)
      throw ArgumentError('Los días de retiro no pueden ser negativos.');
    if (record.nextDueDate != null &&
        day(record.nextDueDate!).isBefore(day(record.date)))
      throw ArgumentError(
        'La próxima aplicación no puede ser anterior al evento.',
      );
  }

  static bool requiresProduct(HealthRecordType type) => const {
    HealthRecordType.vaccine,
    HealthRecordType.deworming,
    HealthRecordType.tickBath,
    HealthRecordType.vitamins,
    HealthRecordType.treatment,
  }.contains(type);
}
