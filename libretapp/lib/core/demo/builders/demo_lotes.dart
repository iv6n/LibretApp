/// core › demo › builders › demo_lotes — batches (lotes) for the demo herd.
///
/// Lotes are created up front with an empty `animalUuids` (step 3 of the
/// install order, before any animal exists) and recomputed once the animal
/// roster is known (step 7), via [recomputeDemoLoteMembership].
library;

import 'package:libretapp/core/demo/demo_identity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

/// Slugs shared with `demo_animals.dart`, which stamps `AnimalEntity.batchUuid`
/// with `demoId('lote', <slug>)` for the animals it assigns to each batch.
/// Keeping the strings here (instead of duplicating them) is what keeps the
/// two builders from silently drifting apart.
const String loteVientresSlug = 'vientres-productivos';
const String loteVaquillasSlug = 'vaquillas-reemplazo';
const String loteBecerrasSlug = 'becerras';
const String loteEngordaSlug = 'desarrollo-engorda';
const String loteCaprinosSlug = 'caprinos';
const String loteOvinosSlug = 'ovinos';

const List<({String slug, String name, String description})> _demoLotes = [
  (
    slug: loteVientresSlug,
    name: 'Vientres productivos',
    description: 'Vacas en producción y ciclo reproductivo activo.',
  ),
  (
    slug: loteVaquillasSlug,
    name: 'Vaquillas de reemplazo',
    description: 'Hembras jóvenes destinadas a reemplazar vientres.',
  ),
  (
    slug: loteBecerrasSlug,
    name: 'Becerras',
    description: 'Crías en pre-destete / post-destete.',
  ),
  (
    slug: loteEngordaSlug,
    name: 'Desarrollo y engorda',
    description: 'Novillos y toretes en desarrollo para venta.',
  ),
  (
    slug: loteCaprinosSlug,
    name: 'Caprinos',
    description: 'Hato caprino del rancho.',
  ),
  (slug: loteOvinosSlug, name: 'Ovinos', description: 'Hato ovino del rancho.'),
];

/// Builds the ~6 demo lotes with an empty `animalUuids` — the roster is not
/// known yet at this point in the install order (step 3, before step 6).
List<LoteEntity> buildDemoLotes({required DateTime reference}) {
  return _demoLotes
      .map(
        (spec) => LoteEntity(
          uuid: demoId('lote', spec.slug),
          name: spec.name,
          description: spec.description,
          animalUuids: const [],
          createdAt: reference,
          active: true,
          lastUpdateDate: reference,
        ),
      )
      .toList(growable: false);
}

/// Recomputes each demo lote's `animalUuids` from the final animal roster
/// (step 7, after step 6 created every animal).
///
/// Only the `demo-*` portion of each lote's membership is replaced: any
/// non-demo uuid a real user added by hand to a demo lote survives, per the
/// idempotency rules for `LoteEntity.animalUuids` — this repository has no
/// concept of "delete and reinsert", `upsert` always replaces the row
/// wholesale, so preserving foreign membership has to happen here before the
/// `upsert` call, not in the repository.
Future<void> recomputeDemoLoteMembership(
  LotesRepository repository,
  List<AnimalEntity> animals,
) async {
  final bySlug = <String, List<String>>{};
  for (final animal in animals) {
    final batch = animal.batchUuid;
    if (batch == null) continue;
    bySlug.putIfAbsent(batch, () => []).add(animal.uuid);
  }

  for (final spec in _demoLotes) {
    final uuid = demoId('lote', spec.slug);
    final existing = await repository.getByUuid(uuid);
    if (existing == null) continue;

    final demoMembers = bySlug[uuid] ?? const <String>[];
    final preserved = existing.animalUuids.where((u) => !u.startsWith('demo-'));
    final merged = {...preserved, ...demoMembers}.toList(growable: false);

    await repository.upsert(existing.copyWith(animalUuids: merged));
  }
}
