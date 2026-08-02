/// core › demo › builders › demo_animals — the 40-animal demo herd.
///
/// Every animal's `ageMonths`/`lifeStage`/`category` is derived from its
/// `birthDate` through the same [AnimalLifecycleCalculator] /
/// [AnimalTaxonomy] the rest of the app uses, so a demo animal is internally
/// consistent the same way a real one is — never hand-picked out of step
/// with its birth date.
library;

import 'package:libretapp/core/demo/builders/demo_locations.dart';
import 'package:libretapp/core/demo/builders/demo_lotes.dart';
import 'package:libretapp/core/demo/demo_dates.dart';
import 'package:libretapp/core/demo/demo_identity.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_lifecycle_calculator.dart';

// Slugs shared with the other builders (weights, health, reproduction,
// movements, commercial, costs, milking, agenda) so they can point a record
// at the right animal via `demoId('animal', <slug>)` without importing this
// file's private spec table.
const String aniPrietaSlug = 'prieta';
const String aniWeraSlug = 'wera';
const String aniNancySlug = 'nancy';
const String aniAlazanaSlug = 'alazana';
const String aniCuernitosSlug = 'cuernitos';
const String aniGordaSlug = 'gorda';
const String aniPelonaSlug = 'pelona';
const String aniSasoSlug = 'saso'; // internal stud (bull)
const String aniPintaSlug = 'pinta';
const String aniMiguelitaSlug = 'miguelita';
const String aniBlanquitaSlug = 'blanquita';
const String aniPrietitaSlug = 'prietita'; // in cuarentena, under observation
const String aniWakaSlug = 'waka';
const String aniBecerraNancySlug = 'becerra-de-nancy'; // linked calf
const String aniBecerra2Slug = 'becerra-2';
const String aniBecerra3Slug = 'becerra-3';
const String aniBecerra4Slug = 'becerra-4'; // no definitive ear tag
const String aniNovillo1Slug = 'novillo-1';
const String aniNovillo2Slug = 'novillo-2';
const String aniNovillo3Slug = 'novillo-3';
const String aniNovillo4Slug = 'novillo-4';
const String aniVendidaSlug = 'vaca-vendida';
const String aniMuertaSlug = 'vaca-muerta';
const String aniArchivadaSlug = 'vaca-archivada';

const String aniCabra1Slug = 'cabra-1';
const String aniCabra2Slug = 'cabra-2';
const String aniCabra3Slug = 'cabra-3';
const String aniCabritoSlug = 'cabrito-1';

const String aniOveja1Slug = 'oveja-1';
const String aniOveja2Slug = 'oveja-2';
const String aniCarneroSlug = 'carnero-1';

const String aniYeguaSlug = 'yegua-1';
const String aniCaballoSlug = 'caballo-1';

const String aniCerda1Slug = 'cerda-1';
const String aniLechonSlug = 'lechon-1';

const String aniGallina1Slug = 'gallina-1';
const String aniGallina2Slug = 'gallina-2';
const String aniGallina3Slug = 'gallina-3';
const String aniGalloSlug = 'gallo-1';

const String aniPerroSlug = 'perro-1';

/// Text-only external sire — no [AnimalEntity] backs it, per the scenario
/// requiring at least one stud expressed only as identification text.
const String externalSireIdentifier =
    'Semental externo "Rayo" (folio EXT-DEMO-002, monta prestada)';

class _Spec {
  const _Spec({
    required this.slug,
    required this.earTag,
    this.name,
    required this.species,
    required this.sex,
    required this.breed,
    this.crossBreed,
    required this.birthMonthsAgo,
    this.batchSlug,
    this.locationSlug,
    this.initialLocationSlug,
    this.sireSlug,
    this.damSlug,
    this.status = AnimalStatus.active,
    this.healthStatus = HealthStatus.good,
    this.vaccinated = true,
    this.dewormed = true,
    this.hasVitamins = false,
    this.hasChronicIssues = false,
    this.underObservation = false,
    this.requiresAttention = false,
    this.riskLevel = RiskLevel.none,
    this.reproductiveStatus = ReproductiveStatus.unknown,
    this.productionPurpose = ProductionPurpose.undefined,
    this.productionStage = ProductionStage.unknown,
    this.productionSystem = ProductionSystem.extensive,
    this.bodyConditionScore,
    this.weight,
    this.originType = OriginType.own,
    this.notes,
    this.coatColor,
    this.purchasePrice,
  });

  final String slug;
  final String earTag;
  final String? name;
  final Species species;
  final Sex sex;
  final String breed;
  final String? crossBreed;
  final int birthMonthsAgo;
  final String? batchSlug;
  final String? locationSlug;
  final String? initialLocationSlug;
  final String? sireSlug;
  final String? damSlug;
  final AnimalStatus status;
  final HealthStatus healthStatus;
  final bool vaccinated;
  final bool dewormed;
  final bool hasVitamins;
  final bool hasChronicIssues;
  final bool underObservation;
  final bool requiresAttention;
  final RiskLevel riskLevel;
  final ReproductiveStatus reproductiveStatus;
  final ProductionPurpose productionPurpose;
  final ProductionStage productionStage;
  final ProductionSystem productionSystem;
  final int? bodyConditionScore;
  final double? weight;
  final OriginType originType;
  final String? notes;
  final String? coatColor;
  final double? purchasePrice;
}

final List<_Spec> _specs = [
  // ── Vientres productivos (7 vacas, lote vientres-productivos) ──────────
  _Spec(
    slug: aniPrietaSlug,
    earTag: 'MZQ-0001',
    name: 'Prieta',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Brahman',
    crossBreed: 'Brahman x Angus',
    birthMonthsAgo: 56,
    batchSlug: loteVientresSlug,
    locationSlug: locPotreroNorteSlug,
    reproductiveStatus: ReproductiveStatus.pregnant,
    productionPurpose: ProductionPurpose.dual,
    productionStage: ProductionStage.reproductive,
    bodyConditionScore: 4,
    coatColor: 'Negro',
    notes: 'Vientre base del hato. Registro de demostración.',
  ),
  _Spec(
    slug: aniWeraSlug,
    earTag: 'MZQ-0002',
    name: 'Wera',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Charolais',
    birthMonthsAgo: 64,
    batchSlug: loteVientresSlug,
    locationSlug: locPotreroNorteSlug,
    reproductiveStatus: ReproductiveStatus.pregnant,
    productionPurpose: ProductionPurpose.dual,
    productionStage: ProductionStage.reproductive,
    bodyConditionScore: 3,
    coatColor: 'Blanco crema',
  ),
  _Spec(
    slug: aniNancySlug,
    earTag: 'MZQ-0003',
    name: 'Nancy',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Cebu',
    birthMonthsAgo: 60,
    batchSlug: loteVientresSlug,
    locationSlug: locPotreroNorteSlug,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.dual,
    productionStage: ProductionStage.reproductive,
    bodyConditionScore: 3,
    coatColor: 'Gris',
    notes: 'Madre de una becerra activa en el hato. Registro de demostración.',
  ),
  _Spec(
    slug: aniAlazanaSlug,
    earTag: 'MZQ-0004',
    name: 'Alazana',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Simmental',
    birthMonthsAgo: 52,
    batchSlug: loteVientresSlug,
    locationSlug: locPotreroNorteSlug,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.dual,
    productionStage: ProductionStage.reproductive,
    bodyConditionScore: 3,
    coatColor: 'Rojizo',
    notes:
        'Diagnóstico de gestación reciente negativo. Registro de demostración.',
  ),
  _Spec(
    slug: aniCuernitosSlug,
    earTag: 'MZQ-0005',
    name: 'Cuernitos',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Criollo',
    birthMonthsAgo: 70,
    batchSlug: loteVientresSlug,
    locationSlug: locPotreroNorteSlug,
    reproductiveStatus: ReproductiveStatus.lactating,
    productionPurpose: ProductionPurpose.dairy,
    productionStage: ProductionStage.lactating,
    bodyConditionScore: 3,
    coatColor: 'Pinto',
    notes:
        'Parió con éxito; su cría sigue en el hato. Registro de demostración.',
  ),
  _Spec(
    slug: aniGordaSlug,
    earTag: 'MZQ-0006',
    name: 'Gorda',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Criollo',
    birthMonthsAgo: 66,
    batchSlug: loteVientresSlug,
    locationSlug: locPotreroNorteSlug,
    reproductiveStatus: ReproductiveStatus.dry,
    productionPurpose: ProductionPurpose.dual,
    productionStage: ProductionStage.idle,
    bodyConditionScore: 4,
  ),
  _Spec(
    slug: aniPelonaSlug,
    earTag: 'MZQ-0007',
    name: 'Pelona',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Cebu',
    birthMonthsAgo: 48,
    batchSlug: loteVientresSlug,
    locationSlug: locPotreroNorteSlug,
    vaccinated: false, // su vacunación está vencida (ver demo_health.dart)
    reproductiveStatus: ReproductiveStatus.virgin,
    productionPurpose: ProductionPurpose.dual,
    productionStage: ProductionStage.growth,
    bodyConditionScore: 3,
  ),

  // ── Semental interno ─────────────────────────────────────────────────
  _Spec(
    slug: aniSasoSlug,
    earTag: 'MZQ-0008',
    name: 'Saso',
    species: Species.cattle,
    sex: Sex.male,
    breed: 'Brahman',
    birthMonthsAgo: 58,
    locationSlug: locPotreroSurSlug,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.breeding,
    productionStage: ProductionStage.reproductive,
    bodyConditionScore: 4,
    coatColor: 'Gris claro',
    notes: 'Semental interno del hato. Registro de demostración.',
  ),

  // ── Vaquillas de reemplazo (5) ──────────────────────────────────────
  _Spec(
    slug: aniPintaSlug,
    earTag: 'MZQ-0009',
    name: 'Pinta',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Simmental',
    birthMonthsAgo: 20,
    batchSlug: loteVaquillasSlug,
    locationSlug: locPotreroSurSlug,
    hasVitamins: true,
    reproductiveStatus: ReproductiveStatus.virgin,
    productionPurpose: ProductionPurpose.breeding,
    productionStage: ProductionStage.growth,
    bodyConditionScore: 3,
    coatColor: 'Pinto',
    sireSlug: aniSasoSlug,
    damSlug: aniGordaSlug,
  ),
  _Spec(
    slug: aniMiguelitaSlug,
    earTag: 'MZQ-0010',
    name: 'Miguelita',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Cebu',
    birthMonthsAgo: 18,
    batchSlug: loteVaquillasSlug,
    locationSlug: locPotreroSurSlug,
    reproductiveStatus: ReproductiveStatus.virgin,
    productionPurpose: ProductionPurpose.breeding,
    productionStage: ProductionStage.growth,
    bodyConditionScore: 3,
    sireSlug: aniSasoSlug,
    damSlug: aniPelonaSlug,
  ),
  _Spec(
    slug: aniBlanquitaSlug,
    earTag: 'MZQ-0011',
    name: 'Blanquita',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Charolais',
    birthMonthsAgo: 16,
    batchSlug: loteVaquillasSlug,
    locationSlug: locPotreroSurSlug,
    initialLocationSlug: locPotreroBecerrasSlug,
    reproductiveStatus: ReproductiveStatus.virgin,
    productionPurpose: ProductionPurpose.breeding,
    productionStage: ProductionStage.growth,
    bodyConditionScore: 3,
    coatColor: 'Blanco',
  ),
  _Spec(
    slug: aniWakaSlug,
    earTag: 'MZQ-0012',
    name: 'Waka',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Criollo',
    birthMonthsAgo: 22,
    batchSlug: loteVaquillasSlug,
    locationSlug: locPotreroSurSlug,
    reproductiveStatus: ReproductiveStatus.virgin,
    productionPurpose: ProductionPurpose.breeding,
    productionStage: ProductionStage.growth,
    bodyConditionScore: 3,
  ),
  _Spec(
    slug: aniPrietitaSlug,
    earTag: 'MZQ-0013',
    name: 'Prietita',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Brahman',
    birthMonthsAgo: 14,
    batchSlug: loteVaquillasSlug,
    locationSlug: locCuarentenaSlug,
    initialLocationSlug: locCuarentenaSlug,
    originType: OriginType.purchased,
    purchasePrice: 9500,
    healthStatus: HealthStatus.fair,
    underObservation: true,
    riskLevel: RiskLevel.medium,
    reproductiveStatus: ReproductiveStatus.virgin,
    productionPurpose: ProductionPurpose.breeding,
    productionStage: ProductionStage.growth,
    bodyConditionScore: 2,
    notes:
        'Compra reciente en cuarentena, bajo observación. Registro de demostración.',
  ),

  // ── Becerras (4) ─────────────────────────────────────────────────────
  _Spec(
    slug: aniBecerraNancySlug,
    earTag: 'MZQ-0014',
    name: 'Becerra de Nancy',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Cebu',
    crossBreed: 'Cebu x Brahman',
    birthMonthsAgo: 6,
    batchSlug: loteBecerrasSlug,
    locationSlug: locPotreroBecerrasSlug,
    sireSlug: aniSasoSlug,
    damSlug: aniNancySlug,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.breeding,
    productionStage: ProductionStage.preWeaning,
    bodyConditionScore: 3,
  ),
  _Spec(
    slug: aniBecerra2Slug,
    earTag: 'MZQ-0015',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Charolais',
    birthMonthsAgo: 4,
    batchSlug: loteBecerrasSlug,
    locationSlug: locPotreroBecerrasSlug,
    sireSlug: aniSasoSlug,
    damSlug: aniCuernitosSlug,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.breeding,
    productionStage: ProductionStage.preWeaning,
    bodyConditionScore: 3,
  ),
  _Spec(
    slug: aniBecerra3Slug,
    earTag: 'MZQ-0016',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Simmental',
    birthMonthsAgo: 9,
    batchSlug: loteBecerrasSlug,
    locationSlug: locPotreroBecerrasSlug,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.breeding,
    productionStage: ProductionStage.postWeaning,
    bodyConditionScore: 3,
    healthStatus: HealthStatus.poor,
    requiresAttention: true,
    riskLevel: RiskLevel.high,
    hasChronicIssues: true,
    notes:
        'Requiere atención: bajo peso para su edad. Registro de demostración.',
  ),
  _Spec(
    slug: aniBecerra4Slug,
    earTag: '', // sin arete definitivo, a propósito
    name: 'Sin arete',
    species: Species.cattle,
    sex: Sex.male,
    breed: 'Criollo',
    birthMonthsAgo: 2,
    batchSlug: loteBecerrasSlug,
    locationSlug: locPotreroBecerrasSlug,
    vaccinated: false, // demasiado joven para el esquema aún
    dewormed: false,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.undefined,
    productionStage: ProductionStage.preWeaning,
    bodyConditionScore: 3,
    notes: 'Cría reciente, pendiente de aretar. Registro de demostración.',
  ),

  // ── Desarrollo y engorda (4 novillos/toretes) ───────────────────────
  _Spec(
    slug: aniNovillo1Slug,
    earTag: 'MZQ-0017',
    species: Species.cattle,
    sex: Sex.male,
    breed: 'Cebu',
    birthMonthsAgo: 18,
    batchSlug: loteEngordaSlug,
    locationSlug: locCorralPrincipalSlug,
    initialLocationSlug: locMonteSlug,
    reproductiveStatus: ReproductiveStatus.neutered,
    productionPurpose: ProductionPurpose.meat,
    productionStage: ProductionStage.finishing,
    productionSystem: ProductionSystem.feedlot,
    bodyConditionScore: 4,
  ),
  _Spec(
    slug: aniNovillo2Slug,
    earTag: 'MZQ-0018',
    species: Species.cattle,
    sex: Sex.male,
    breed: 'Charolais',
    birthMonthsAgo: 15,
    batchSlug: loteEngordaSlug,
    locationSlug: locCorralPrincipalSlug,
    reproductiveStatus: ReproductiveStatus.neutered,
    productionPurpose: ProductionPurpose.meat,
    productionStage: ProductionStage.finishing,
    productionSystem: ProductionSystem.feedlot,
    bodyConditionScore: 3,
  ),
  _Spec(
    slug: aniNovillo3Slug,
    earTag: 'MZQ-0019',
    species: Species.cattle,
    sex: Sex.male,
    breed: 'Simmental',
    birthMonthsAgo: 13,
    batchSlug: loteEngordaSlug,
    locationSlug: locMonteSlug,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.meat,
    productionStage: ProductionStage.growth,
    bodyConditionScore: 3,
  ),
  _Spec(
    slug: aniNovillo4Slug,
    earTag: 'MZQ-0020',
    species: Species.cattle,
    sex: Sex.male,
    breed: 'Criollo',
    birthMonthsAgo: 12,
    batchSlug: loteEngordaSlug,
    locationSlug: locMonteSlug,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.meat,
    productionStage: ProductionStage.growth,
    bodyConditionScore: 3,
  ),

  // ── Históricos (fuera del hato activo) ──────────────────────────────
  _Spec(
    slug: aniVendidaSlug,
    earTag: 'MZQ-0021',
    name: 'Consentida',
    species: Species.cattle,
    sex: Sex.male,
    breed: 'Cebu',
    birthMonthsAgo: 11,
    locationSlug: locPotreroNorteSlug,
    status: AnimalStatus.sold,
    reproductiveStatus: ReproductiveStatus.retired,
    productionPurpose: ProductionPurpose.meat,
    productionStage: ProductionStage.idle,
    // Weight at the time of sale, not the age-based estimate: an inactive
    // animal keeps ageing on paper (ageMonths is derived from birthDate),
    // but it stopped actually growing the day it left the herd.
    weight: 180,
    notes:
        'Becerro vendido en el semestre en curso. Conserva historial y '
        'finanzas. Registro de demostración.',
  ),
  _Spec(
    slug: aniMuertaSlug,
    earTag: 'MZQ-0022',
    name: 'Canela',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Criollo',
    birthMonthsAgo: 72,
    locationSlug: locCorralPrincipalSlug,
    status: AnimalStatus.dead,
    reproductiveStatus: ReproductiveStatus.retired,
    productionPurpose: ProductionPurpose.dual,
    productionStage: ProductionStage.idle,
    weight: 410,
    notes:
        'Baja por muerte. Conserva historial y genealogía. '
        'Registro de demostración.',
  ),
  _Spec(
    slug: aniArchivadaSlug,
    earTag: 'MZQ-0023',
    name: 'Manchada',
    species: Species.cattle,
    sex: Sex.female,
    breed: 'Simmental',
    birthMonthsAgo: 80,
    locationSlug: locPotreroSurSlug,
    status: AnimalStatus.archived,
    reproductiveStatus: ReproductiveStatus.retired,
    productionPurpose: ProductionPurpose.dual,
    productionStage: ProductionStage.idle,
    weight: 465,
    notes:
        'Archivada del hato activo (no vendida ni muerta). '
        'Registro de demostración.',
  ),

  // ── Caprinos (4 activos) ─────────────────────────────────────────────
  _Spec(
    slug: aniCabra1Slug,
    earTag: 'MZQ-0024',
    species: Species.goat,
    sex: Sex.female,
    breed: 'Boer',
    birthMonthsAgo: 30,
    batchSlug: loteCaprinosSlug,
    locationSlug: locCorralMenoresSlug,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.meat,
    productionStage: ProductionStage.reproductive,
    bodyConditionScore: 3,
  ),
  _Spec(
    slug: aniCabra2Slug,
    earTag: 'MZQ-0025',
    species: Species.goat,
    sex: Sex.female,
    breed: 'Nubia',
    birthMonthsAgo: 24,
    batchSlug: loteCaprinosSlug,
    locationSlug: locCorralMenoresSlug,
    reproductiveStatus: ReproductiveStatus.lactating,
    productionPurpose: ProductionPurpose.dairy,
    productionStage: ProductionStage.lactating,
    bodyConditionScore: 3,
  ),
  _Spec(
    slug: aniCabra3Slug,
    earTag: 'MZQ-0026',
    species: Species.goat,
    sex: Sex.male,
    breed: 'Boer',
    birthMonthsAgo: 26,
    batchSlug: loteCaprinosSlug,
    locationSlug: locCorralMenoresSlug,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.breeding,
    productionStage: ProductionStage.reproductive,
    bodyConditionScore: 4,
  ),
  _Spec(
    slug: aniCabritoSlug,
    earTag: 'MZQ-0027',
    species: Species.goat,
    sex: Sex.female,
    breed: 'Boer',
    crossBreed: 'Boer x Nubia',
    birthMonthsAgo: 4,
    batchSlug: loteCaprinosSlug,
    locationSlug: locCorralMenoresSlug,
    sireSlug: aniCabra3Slug,
    damSlug: aniCabra1Slug,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.meat,
    productionStage: ProductionStage.preWeaning,
    bodyConditionScore: 3,
  ),

  // ── Ovinos (3 activos) ───────────────────────────────────────────────
  _Spec(
    slug: aniOveja1Slug,
    earTag: 'MZQ-0028',
    species: Species.sheep,
    sex: Sex.female,
    breed: 'Katahdin',
    birthMonthsAgo: 28,
    batchSlug: loteOvinosSlug,
    locationSlug: locCorralMenoresSlug,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.meat,
    productionStage: ProductionStage.reproductive,
    bodyConditionScore: 3,
  ),
  _Spec(
    slug: aniOveja2Slug,
    earTag: 'MZQ-0029',
    species: Species.sheep,
    sex: Sex.female,
    breed: 'Dorper',
    birthMonthsAgo: 20,
    batchSlug: loteOvinosSlug,
    locationSlug: locCorralMenoresSlug,
    reproductiveStatus: ReproductiveStatus.virgin,
    productionPurpose: ProductionPurpose.meat,
    productionStage: ProductionStage.growth,
    bodyConditionScore: 3,
  ),
  _Spec(
    slug: aniCarneroSlug,
    earTag: 'MZQ-0030',
    species: Species.sheep,
    sex: Sex.male,
    breed: 'Dorper',
    birthMonthsAgo: 24,
    batchSlug: loteOvinosSlug,
    locationSlug: locCorralMenoresSlug,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.breeding,
    productionStage: ProductionStage.reproductive,
    bodyConditionScore: 4,
  ),

  // ── Equinos (2 activos, sin lote) ────────────────────────────────────
  _Spec(
    slug: aniYeguaSlug,
    earTag: 'MZQ-0031',
    name: 'Estrella',
    species: Species.equine,
    sex: Sex.female,
    breed: 'Cuarto de Milla',
    birthMonthsAgo: 96,
    locationSlug: locEstabloSlug,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.work,
    productionStage: ProductionStage.idle,
    bodyConditionScore: 4,
  ),
  _Spec(
    slug: aniCaballoSlug,
    earTag: 'MZQ-0032',
    name: 'Relámpago',
    species: Species.equine,
    sex: Sex.male,
    breed: 'Azteca',
    birthMonthsAgo: 84,
    locationSlug: locEstabloSlug,
    reproductiveStatus: ReproductiveStatus.neutered,
    productionPurpose: ProductionPurpose.work,
    productionStage: ProductionStage.idle,
    bodyConditionScore: 4,
  ),

  // ── Porcinos (2 activos, sin lote) ───────────────────────────────────
  _Spec(
    slug: aniCerda1Slug,
    earTag: 'MZQ-0033',
    species: Species.pig,
    sex: Sex.female,
    breed: 'Yorkshire',
    birthMonthsAgo: 14,
    locationSlug: locCorralPrincipalSlug,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.meat,
    productionStage: ProductionStage.reproductive,
    productionSystem: ProductionSystem.intensive,
    bodyConditionScore: 4,
  ),
  _Spec(
    slug: aniLechonSlug,
    earTag: 'MZQ-0034',
    species: Species.pig,
    sex: Sex.male,
    breed: 'Yorkshire',
    crossBreed: 'Yorkshire x Landrace',
    birthMonthsAgo: 3,
    locationSlug: locCorralPrincipalSlug,
    damSlug: aniCerda1Slug,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.meat,
    productionStage: ProductionStage.preWeaning,
    productionSystem: ProductionSystem.intensive,
    bodyConditionScore: 3,
  ),

  // ── Aves (4 activas, sin lote) ───────────────────────────────────────
  _Spec(
    slug: aniGallina1Slug,
    earTag: 'MZQ-0035',
    species: Species.poultry,
    sex: Sex.female,
    breed: 'Rhode Island Red',
    birthMonthsAgo: 10,
    locationSlug: locCorralAvesSlug,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.eggs,
    productionStage: ProductionStage.reproductive,
    productionSystem: ProductionSystem.intensive,
  ),
  _Spec(
    slug: aniGallina2Slug,
    earTag: 'MZQ-0036',
    species: Species.poultry,
    sex: Sex.female,
    breed: 'Plymouth Rock',
    birthMonthsAgo: 8,
    locationSlug: locCorralAvesSlug,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.eggs,
    productionStage: ProductionStage.reproductive,
    productionSystem: ProductionSystem.intensive,
  ),
  _Spec(
    slug: aniGallina3Slug,
    earTag: 'MZQ-0037',
    species: Species.poultry,
    sex: Sex.female,
    breed: 'Rhode Island Red',
    birthMonthsAgo: 6,
    locationSlug: locCorralAvesSlug,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.eggs,
    productionStage: ProductionStage.reproductive,
    productionSystem: ProductionSystem.intensive,
  ),
  _Spec(
    slug: aniGalloSlug,
    earTag: 'MZQ-0038',
    species: Species.poultry,
    sex: Sex.male,
    breed: 'Rhode Island Red',
    birthMonthsAgo: 9,
    locationSlug: locCorralAvesSlug,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.breeding,
    productionStage: ProductionStage.reproductive,
    productionSystem: ProductionSystem.intensive,
  ),

  // ── Perro de trabajo (1 activo, sin lote) ────────────────────────────
  _Spec(
    slug: aniPerroSlug,
    earTag: 'MZQ-0039',
    name: 'Capitán',
    species: Species.canine,
    sex: Sex.male,
    breed: 'Pastor Australiano',
    birthMonthsAgo: 36,
    locationSlug: locCorralPrincipalSlug,
    reproductiveStatus: ReproductiveStatus.neutered,
    productionPurpose: ProductionPurpose.work,
    productionStage: ProductionStage.idle,
    productionSystem: ProductionSystem.unknown,
    bodyConditionScore: 4,
    notes: 'Perro de trabajo para manejo de ganado. Registro de demostración.',
  ),
];

/// Builds the 40 demo animals: 24 cattle (21 active + sold + dead +
/// archived) + 4 goats + 3 sheep + 2 equines + 2 pigs + 4 poultry + 1 dog.
///
/// The external stud is deliberately text-only (see
/// [externalSireIdentifier] in `demo_reproduction.dart`) — it does not back
/// a 40th [AnimalEntity].
List<AnimalEntity> buildDemoAnimals({required DateTime reference}) {
  assert(_specs.length == 40, 'La demo debe tener exactamente 40 animales.');

  final byUuid = <String, String>{
    for (final spec in _specs) spec.slug: demoId('animal', spec.slug),
  };

  return _specs
      .map((spec) {
        final birthDate = monthsBefore(reference, spec.birthMonthsAgo);
        final lifecycle = AnimalLifecycleCalculator.calculate(
          birthDate: birthDate,
          species: spec.species,
          sex: spec.sex,
          now: reference,
        );
        final neutered = spec.reproductiveStatus == ReproductiveStatus.neutered;
        var category = AnimalTaxonomy.defaultCategory(
          species: spec.species,
          sex: spec.sex,
          ageMonths: lifecycle.ageMonths,
          neutered: neutered,
        );
        // AnimalTaxonomy.defaultCategory's generic (non-cattle) branch always
        // picks the first non-"other" option regardless of sex, which for an
        // adult equine is always `work` — and `resolveLifeStage` special-cases
        // `work` to `LifeStage.horse` before it ever looks at sex, so an adult
        // mare would otherwise never resolve to `LifeStage.mare`. `reproduction`
        // is an equally valid category per `categoriesFor`, and picking it here
        // for the one demo mare lets her card read "Yegua" instead of "Caballo".
        if (spec.species == Species.equine &&
            spec.sex == Sex.female &&
            lifecycle.ageMonths >= 36 &&
            category == Category.work) {
          category = Category.reproduction;
        }

        return AnimalEntity(
          uuid: byUuid[spec.slug]!,
          earTagNumber: spec.earTag,
          customName: spec.name,
          species: spec.species,
          category: category,
          lifeStage: lifecycle.lifeStage,
          sex: spec.sex,
          breed: spec.breed,
          crossBreed: spec.crossBreed,
          birthDate: birthDate,
          ageMonths: lifecycle.ageMonths,
          // Animals with a weighing history (`demo_weights.dart`) get this
          // overwritten by `WeightRecordRepository`'s side effect once step 5 of
          // `DemoScenarioService._seedAll` adds their records — this baseline is
          // what the ~35 without one keep permanently.
          weight:
              spec.weight ??
              _estimatedWeightKg(spec.species, spec.sex, lifecycle.ageMonths),
          sireUuid: spec.sireSlug != null ? byUuid[spec.sireSlug!] : null,
          damUuid: spec.damSlug != null ? byUuid[spec.damSlug!] : null,
          healthStatus: spec.healthStatus,
          bodyConditionScore: spec.bodyConditionScore,
          vaccinated: spec.vaccinated,
          dewormed: spec.dewormed,
          hasVitamins: spec.hasVitamins,
          hasChronicIssues: spec.hasChronicIssues,
          reproductiveStatus: spec.reproductiveStatus,
          productionPurpose: spec.productionPurpose,
          productionStage: spec.productionStage,
          productionSystem: spec.productionSystem,
          coatColor: spec.coatColor,
          notes: spec.notes,
          originType: spec.originType,
          currentLocationId: spec.locationSlug != null
              ? demoId('location', spec.locationSlug!)
              : null,
          initialLocationId: demoId(
            'location',
            spec.initialLocationSlug ?? spec.locationSlug ?? locRanchSlug,
          ),
          underObservation: spec.underObservation,
          requiresAttention: spec.requiresAttention,
          riskLevel: spec.riskLevel,
          gallery: const [],
          purchasePrice: spec.purchasePrice,
          batchUuid: spec.batchSlug != null
              ? demoId('lote', spec.batchSlug!)
              : null,
          status: spec.status,
          synced: false,
          creationDate: reference,
          lastUpdateDate: reference,
        );
      })
      .toList(growable: false);
}

/// Resolves a demo animal's uuid from its slug — used by the other builders
/// so they never hardcode a `demoId('animal', ...)` call themselves.
String demoAnimalUuid(String slug) => demoId('animal', slug);

/// Plausible adult/juvenile weight in kg for the ~35 demo animals that carry
/// no explicit weighing history — a coarse species/sex/age curve, not a
/// breed-accurate figure. Animals with a `demo_weights.dart` series get this
/// value overwritten by `WeightRecordRepository`'s side effect regardless.
double _estimatedWeightKg(Species species, Sex sex, int ageMonths) {
  double scaleByAge(double adult, int maturityMonths) {
    if (ageMonths >= maturityMonths) return adult;
    final fraction = (ageMonths / maturityMonths).clamp(0.05, 1.0);
    return adult * fraction;
  }

  switch (species) {
    case Species.cattle:
      final adult = sex == Sex.male ? 520.0 : 420.0;
      return scaleByAge(adult, 30);
    case Species.equine:
      final adult = sex == Sex.male ? 430.0 : 400.0;
      return scaleByAge(adult, 36);
    case Species.goat:
      final adult = sex == Sex.male ? 60.0 : 48.0;
      return scaleByAge(adult, 12);
    case Species.sheep:
      final adult = sex == Sex.male ? 70.0 : 55.0;
      return scaleByAge(adult, 12);
    case Species.pig:
      final adult = sex == Sex.male ? 160.0 : 140.0;
      return scaleByAge(adult, 8);
    case Species.poultry:
      final adult = sex == Sex.male ? 3.2 : 2.4;
      return scaleByAge(adult, 5);
    case Species.canine:
      return scaleByAge(22.0, 12);
    case Species.other:
      return scaleByAge(50.0, 24);
  }
}
