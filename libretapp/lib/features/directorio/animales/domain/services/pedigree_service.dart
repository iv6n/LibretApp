/// features › directorio › animales › domain › services › pedigree_service — pedigree navigation and relatedness checks.
library;

import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';

/// A node in an animal's ancestor tree.
///
/// [animal] is null when the parent is referenced by UUID but is not present
/// in the herd — the breeder recorded an outside sire, or the parent was
/// deleted. The node is still emitted so the gap is visible in the tree
/// instead of silently truncating the branch.
class PedigreeNode {
  const PedigreeNode({
    required this.uuid,
    required this.generation,
    this.animal,
    this.sire,
    this.dam,
  });

  final String uuid;

  /// Distance from the root animal: 1 = parents, 2 = grandparents.
  final int generation;

  final AnimalEntity? animal;
  final PedigreeNode? sire;
  final PedigreeNode? dam;

  bool get isKnown => animal != null;
}

/// How two candidate mates are related, if at all.
class RelatednessResult {
  const RelatednessResult({
    required this.isRelated,
    this.commonAncestorUuid,
    this.sireDistance,
    this.damDistance,
  });

  static const RelatednessResult unrelated = RelatednessResult(
    isRelated: false,
  );

  final bool isRelated;

  /// The closest shared ancestor found, if any.
  final String? commonAncestorUuid;

  /// Generations from each candidate up to [commonAncestorUuid]. A parent is
  /// 1, a grandparent 2. Lower numbers mean a tighter mating.
  final int? sireDistance;
  final int? damDistance;

  /// Sum of both distances. Full siblings score 2, half siblings 2 as well,
  /// and a sire mated to his own daughter scores 1 — the lower, the worse.
  int? get closeness {
    final sire = sireDistance;
    final dam = damDistance;
    if (sire == null || dam == null) return null;
    return sire + dam;
  }
}

/// Navigates parent/offspring links and flags consanguinity.
///
/// Every method is pure and takes the herd it should reason over, so the
/// pedigree can be computed in tests, in a bloc, or over a page of results
/// without touching Isar.
class PedigreeService {
  const PedigreeService();

  /// Default depth for relatedness checks: parents and grandparents. Three
  /// generations is where inbreeding coefficients stop being negligible for
  /// practical herd management.
  static const int defaultDepth = 3;

  /// Builds a lookup once so callers doing several queries don't pay for a
  /// linear scan each time.
  static Map<String, AnimalEntity> indexByUuid(Iterable<AnimalEntity> herd) {
    return {for (final animal in herd) animal.uuid: animal};
  }

  /// Ancestor tree rooted at [animal], walking up to [depth] generations.
  PedigreeNode ancestorsOf(
    AnimalEntity animal, {
    required Map<String, AnimalEntity> herd,
    int depth = defaultDepth,
  }) {
    return _buildNode(
      uuid: animal.uuid,
      animal: animal,
      herd: herd,
      generation: 0,
      maxDepth: depth,
      visited: <String>{},
    );
  }

  PedigreeNode _buildNode({
    required String uuid,
    required AnimalEntity? animal,
    required Map<String, AnimalEntity> herd,
    required int generation,
    required int maxDepth,
    required Set<String> visited,
  }) {
    // A cycle means corrupt parent links (an animal recorded as its own
    // ancestor). Stop rather than recursing forever.
    if (generation >= maxDepth || animal == null || !visited.add(uuid)) {
      return PedigreeNode(
        uuid: uuid,
        generation: generation,
        animal: animal,
      );
    }

    PedigreeNode? parentNode(String? parentUuid) {
      if (parentUuid == null || parentUuid.isEmpty) return null;
      return _buildNode(
        uuid: parentUuid,
        animal: herd[parentUuid],
        herd: herd,
        generation: generation + 1,
        maxDepth: maxDepth,
        visited: visited,
      );
    }

    return PedigreeNode(
      uuid: uuid,
      generation: generation,
      animal: animal,
      sire: parentNode(animal.sireUuid),
      dam: parentNode(animal.damUuid),
    );
  }

  /// Direct offspring of [uuid], newest first.
  List<AnimalEntity> offspringOf(
    String uuid, {
    required Iterable<AnimalEntity> herd,
  }) {
    final offspring =
        herd
            .where(
              (animal) => animal.sireUuid == uuid || animal.damUuid == uuid,
            )
            .toList()
          ..sort((a, b) => b.birthDate.compareTo(a.birthDate));
    return offspring;
  }

  /// Siblings of [animal], split by how much parentage they share.
  ///
  /// Animals with no recorded parents are never siblings of anything: two
  /// unknown parents are not evidence of a shared one.
  ({List<AnimalEntity> full, List<AnimalEntity> half}) siblingsOf(
    AnimalEntity animal, {
    required Iterable<AnimalEntity> herd,
  }) {
    final sire = _normalize(animal.sireUuid);
    final dam = _normalize(animal.damUuid);
    if (sire == null && dam == null) {
      return (full: <AnimalEntity>[], half: <AnimalEntity>[]);
    }

    final full = <AnimalEntity>[];
    final half = <AnimalEntity>[];

    for (final candidate in herd) {
      if (candidate.uuid == animal.uuid) continue;
      final candidateSire = _normalize(candidate.sireUuid);
      final candidateDam = _normalize(candidate.damUuid);

      final sharesSire = sire != null && candidateSire == sire;
      final sharesDam = dam != null && candidateDam == dam;

      if (sharesSire && sharesDam) {
        full.add(candidate);
      } else if (sharesSire || sharesDam) {
        half.add(candidate);
      }
    }

    int byBirthDesc(AnimalEntity a, AnimalEntity b) =>
        b.birthDate.compareTo(a.birthDate);
    full.sort(byBirthDesc);
    half.sort(byBirthDesc);

    return (full: full, half: half);
  }

  /// Checks whether two candidate mates share an ancestor within [depth]
  /// generations. This is the check that keeps a breeder from mating a sire
  /// to his own daughter — the single most common avoidable mistake once a
  /// herd starts retaining its own replacements.
  RelatednessResult relatednessWarning({
    required String? sireUuid,
    required String? damUuid,
    required Map<String, AnimalEntity> herd,
    int depth = defaultDepth,
  }) {
    final sire = _normalize(sireUuid);
    final dam = _normalize(damUuid);
    if (sire == null || dam == null) return RelatednessResult.unrelated;

    // Direct parent/offspring mating is the tightest possible case.
    if (herd[dam]?.sireUuid == sire) {
      return RelatednessResult(
        isRelated: true,
        commonAncestorUuid: sire,
        sireDistance: 0,
        damDistance: 1,
      );
    }
    if (herd[sire]?.damUuid == dam) {
      return RelatednessResult(
        isRelated: true,
        commonAncestorUuid: dam,
        sireDistance: 1,
        damDistance: 0,
      );
    }

    final sireAncestors = _ancestorDistances(sire, herd: herd, maxDepth: depth);
    final damAncestors = _ancestorDistances(dam, herd: herd, maxDepth: depth);

    String? closestUuid;
    int? closestSum;
    int? closestSire;
    int? closestDam;

    for (final entry in sireAncestors.entries) {
      final damDistance = damAncestors[entry.key];
      if (damDistance == null) continue;
      final sum = entry.value + damDistance;
      if (closestSum == null || sum < closestSum) {
        closestSum = sum;
        closestUuid = entry.key;
        closestSire = entry.value;
        closestDam = damDistance;
      }
    }

    if (closestUuid == null) return RelatednessResult.unrelated;

    return RelatednessResult(
      isRelated: true,
      commonAncestorUuid: closestUuid,
      sireDistance: closestSire,
      damDistance: closestDam,
    );
  }

  /// Every ancestor of [uuid] mapped to its generation distance, nearest wins
  /// when an animal appears twice (line breeding already in the pedigree).
  Map<String, int> _ancestorDistances(
    String uuid, {
    required Map<String, AnimalEntity> herd,
    required int maxDepth,
  }) {
    final distances = <String, int>{};
    final queue = <(String, int)>[(uuid, 0)];

    while (queue.isNotEmpty) {
      final (currentUuid, distance) = queue.removeAt(0);
      if (distance >= maxDepth) continue;

      final current = herd[currentUuid];
      if (current == null) continue;

      for (final parentUuid in [current.sireUuid, current.damUuid]) {
        final parent = _normalize(parentUuid);
        if (parent == null) continue;
        final next = distance + 1;
        final existing = distances[parent];
        if (existing != null && existing <= next) continue;
        distances[parent] = next;
        queue.add((parent, next));
      }
    }

    return distances;
  }

  /// Candidate parents for [species], filtered by [sex] and excluding the
  /// animal itself plus its own descendants — an animal can never be its own
  /// ancestor, and offering that choice is how corrupt links get created.
  List<AnimalEntity> candidateParents({
    required Iterable<AnimalEntity> herd,
    required Sex sex,
    AnimalEntity? excluding,
  }) {
    final blocked = <String>{};
    if (excluding != null) {
      blocked
        ..add(excluding.uuid)
        ..addAll(_descendantUuids(excluding.uuid, herd: herd));
    }

    return herd
        .where(
          (animal) =>
              animal.sex == sex &&
              !blocked.contains(animal.uuid) &&
              (excluding == null || animal.species == excluding.species),
        )
        .toList()
      ..sort((a, b) => a.earTagNumber.compareTo(b.earTagNumber));
  }

  Set<String> _descendantUuids(
    String uuid, {
    required Iterable<AnimalEntity> herd,
  }) {
    final descendants = <String>{};
    final frontier = <String>[uuid];

    while (frontier.isNotEmpty) {
      final current = frontier.removeLast();
      for (final animal in herd) {
        if (animal.sireUuid != current && animal.damUuid != current) continue;
        if (descendants.add(animal.uuid)) {
          frontier.add(animal.uuid);
        }
      }
    }

    return descendants;
  }

  static String? _normalize(String? uuid) {
    if (uuid == null) return null;
    final trimmed = uuid.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
