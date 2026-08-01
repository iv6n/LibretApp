/// features › directorio › animales › domain › services › default_care_rules — starter care calendar.
library;

import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';

/// The calendar a breeder starts with, so the feature is useful before anyone
/// configures anything.
///
/// Intervals are the common practice for tropical/subtropical cattle ranching,
/// which is the context this app is built for. They are meant to be edited:
/// every operation has its own vet plan, and a rule the breeder retires is
/// kept retired rather than restored on the next start.
abstract final class DefaultCareRules {
  /// Bumped when this list changes in a way that should reach herds that
  /// already ran the preload. The preload is gated on this value.
  static const int version = 1;

  static List<CareRule> all() => [
    ..._cattle(),
    ..._smallRuminants(),
    ..._generic(),
  ];

  static List<CareRule> _cattle() => const [
    CareRule(
      id: 'default-cattle-vaccination',
      name: 'Vacunación anual',
      type: CareType.vaccination,
      intervalDays: 365,
      leadTimeDays: 15,
      species: Species.cattle,
      minAgeMonths: 3,
    ),
    CareRule(
      id: 'default-cattle-deworming',
      name: 'Desparasitación',
      type: CareType.deworming,
      // Twice a year is the usual baseline; heavy-parasite areas go quarterly.
      intervalDays: 180,
      leadTimeDays: 10,
      species: Species.cattle,
      minAgeMonths: 2,
    ),
    CareRule(
      id: 'default-cattle-tick-bath',
      name: 'Baño garrapaticida',
      type: CareType.tickBath,
      intervalDays: 21,
      leadTimeDays: 3,
      species: Species.cattle,
      mandatory: false,
    ),
    CareRule(
      id: 'default-cattle-hoof',
      name: 'Revisión de casco',
      type: CareType.hoofCare,
      intervalDays: 180,
      species: Species.cattle,
      minAgeMonths: 12,
      mandatory: false,
    ),
  ];

  static List<CareRule> _smallRuminants() => const [
    CareRule(
      id: 'default-goat-deworming',
      name: 'Desparasitación',
      type: CareType.deworming,
      // Small ruminants carry a heavier parasite load than cattle.
      intervalDays: 120,
      leadTimeDays: 10,
      species: Species.goat,
      minAgeMonths: 2,
    ),
    CareRule(
      id: 'default-sheep-deworming',
      name: 'Desparasitación',
      type: CareType.deworming,
      intervalDays: 120,
      leadTimeDays: 10,
      species: Species.sheep,
      minAgeMonths: 2,
    ),
  ];

  /// Species-agnostic: applies to whatever the breeder keeps.
  static List<CareRule> _generic() => const [
    CareRule(
      id: 'default-vitamins',
      name: 'Vitaminas y minerales',
      type: CareType.supplement,
      intervalDays: 120,
      mandatory: false,
    ),
  ];
}
