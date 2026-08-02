/// core › demo › builders › demo_movements — location history for a couple
/// of representative demo animals.
///
/// `MovementRecordRepository` stamps `AnimalEntity.currentLocationId`
/// unconditionally from whichever movement was added last (no date
/// comparison) — so each animal here gets exactly one movement, and its
/// `toLocation` matches the `currentLocationId` already authored on that
/// animal in `demo_animals.dart`, with `fromLocation` matching its
/// `initialLocationId`. Most demo animals intentionally have zero movement
/// records: their current location was simply authored directly, which is
/// the common case for a real herd too.
library;

import 'package:libretapp/core/demo/builders/demo_animals.dart';
import 'package:libretapp/core/demo/builders/demo_locations.dart';
import 'package:libretapp/core/demo/demo_dates.dart';
import 'package:libretapp/core/demo/demo_identity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';

class DemoMovementEntry {
  const DemoMovementEntry({required this.animalSlug, required this.record});
  final String animalSlug;
  final MovementRecord record;
}

List<DemoMovementEntry> buildDemoMovementRecords({
  required DateTime reference,
}) {
  String loc(String slug) => demoId('location', slug);

  return [
    DemoMovementEntry(
      animalSlug: aniBlanquitaSlug,
      record: MovementRecord(
        fromLocation: loc(locPotreroBecerrasSlug),
        toLocation: loc(locPotreroSurSlug),
        date: daysBefore(reference, 60),
        reason: MovementReason.paddockRotation,
        movedBy: 'Capataz (DEMO)',
        notes: 'Traslado tras destete. Registro de demostración.',
      ),
    ),
    DemoMovementEntry(
      animalSlug: aniNovillo1Slug,
      record: MovementRecord(
        fromLocation: loc(locMonteSlug),
        toLocation: loc(locCorralPrincipalSlug),
        date: daysBefore(reference, 30),
        reason: MovementReason.feeding,
        movedBy: 'Capataz (DEMO)',
        notes: 'Ingreso a corral de engorda. Registro de demostración.',
      ),
    ),
  ];
}
