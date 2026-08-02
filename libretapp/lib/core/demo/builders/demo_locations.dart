/// core › demo › builders › demo_locations — hierarchical property layout
/// for the demo ranch.
///
/// 15 locations rooted at a single property, covering every
/// [LocationCategory]: macro (the ranch), livestock (pastures, corrals, a
/// stable), handling (a chute), a quarantine area, agricultural (a milpa),
/// natural (monte/agostadero), infrastructure (a warehouse) and water (a dam
/// and a trough). Every uuid uses the `demo-*` namespace via [demoId], so
/// none of it collides with `IsarLocationRepository`'s own implicit seed
/// (`'prop-casa'`, `'casa-corral-1'`, etc.) — that seed is unrelated,
/// pre-existing behaviour this scenario does not need to touch or depend on.
library;

import 'package:libretapp/core/demo/demo_identity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_task_type.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/water_type.dart';

// Slugs shared with other builders (animals, movements, agenda, inventory)
// so they can point `currentLocationId`/`locationUuid` at these locations via
// `demoId('location', <slug>)` without importing this file's private specs.
const String locRanchSlug = 'rancho-el-mezquite';
const String locPotreroNorteSlug = 'potrero-norte';
const String locPotreroSurSlug = 'potrero-sur';
const String locPotreroBecerrasSlug = 'potrero-becerras';
const String locCorralPrincipalSlug = 'corral-principal';
const String locCorralMenoresSlug = 'corral-menores';
const String locCorralAvesSlug = 'corral-aves';
const String locEstabloSlug = 'establo';
const String locAreaManejoSlug = 'area-manejo';
const String locCuarentenaSlug = 'cuarentena';
const String locBodegaSlug = 'bodega';
const String locMilpaSlug = 'milpa';
const String locMonteSlug = 'monte';
const String locRepresaSlug = 'represa';
const String locAbrevaderoNorteSlug = 'abrevadero-norte';

/// Builds the 15-location demo property tree.
List<LocationEntity> buildDemoLocations({required DateTime reference}) {
  String uuidOf(String slug) => demoId('location', slug);

  final ranch = LocationEntity(
    uuid: uuidOf(locRanchSlug),
    name: 'Rancho El Mezquite — DEMO',
    type: LocationType.ranch,
    surfaceArea: 480,
    capacity: 200,
    waterSource: 'Pozo propio + presa',
    terrainType: 'Zona rural de Hermosillo, Sonora (llano con matorral)',
    status: LocationStatus.available,
    visits: [
      VisitRecord(
        date: reference.subtract(const Duration(days: 2)),
        animals: 40,
        notes: 'Recorrido general del rancho. Registro de demostración.',
        user: 'Rodrigo Valenzuela (DEMO)',
      ),
    ],
  );

  final potreroNorte = LocationEntity(
    uuid: uuidOf(locPotreroNorteSlug),
    name: 'Potrero Norte',
    parentUuid: ranch.uuid,
    type: LocationType.pasture,
    surfaceArea: 60,
    capacity: 30,
    waterSource: 'Abrevadero Norte',
    terrainType: 'Pastizal inducido',
    status: LocationStatus.inUse,
    pastures: [
      PastureRecord(
        date: reference.subtract(const Duration(days: 10)),
        grassType: 'Zacate buffel',
        condition: 'Bueno',
        carryingCapacity: 30,
      ),
    ],
  );

  final potreroSur = LocationEntity(
    uuid: uuidOf(locPotreroSurSlug),
    name: 'Potrero Sur',
    parentUuid: ranch.uuid,
    type: LocationType.pasture,
    surfaceArea: 55,
    capacity: 28,
    waterSource: 'Represa',
    terrainType: 'Pastizal natural',
    status: LocationStatus.inUse,
    pastures: [
      PastureRecord(
        date: reference.subtract(const Duration(days: 12)),
        grassType: 'Zacate navajita',
        condition: 'Regular',
        carryingCapacity: 28,
      ),
    ],
  );

  final potreroBecerras = LocationEntity(
    uuid: uuidOf(locPotreroBecerrasSlug),
    name: 'Potrero Becerras',
    parentUuid: ranch.uuid,
    type: LocationType.pasture,
    surfaceArea: 15,
    capacity: 15,
    waterSource: 'Toma desde la represa',
    terrainType: 'Pastizal inducido, cercano a casco',
    status: LocationStatus.inUse,
  );

  final corralPrincipal = LocationEntity(
    uuid: uuidOf(locCorralPrincipalSlug),
    name: 'Corral Principal',
    parentUuid: ranch.uuid,
    type: LocationType.corral,
    surfaceArea: 1.2,
    capacity: 20,
    waterSource: 'Bebedero de cemento',
    terrainType: 'Tierra apisonada',
    status: LocationStatus.inUse,
  );

  final corralMenores = LocationEntity(
    uuid: uuidOf(locCorralMenoresSlug),
    name: 'Corral de Menores',
    parentUuid: ranch.uuid,
    type: LocationType.corral,
    surfaceArea: 0.8,
    capacity: 20,
    waterSource: 'Bebedero compartido',
    terrainType: 'Tierra con sombra',
    status: LocationStatus.inUse,
  );

  final corralAves = LocationEntity(
    uuid: uuidOf(locCorralAvesSlug),
    name: 'Corral de Aves',
    parentUuid: ranch.uuid,
    type: LocationType.pen,
    surfaceArea: 0.1,
    capacity: 15,
    waterSource: 'Bebederos manuales',
    terrainType: 'Malla y sombra',
    status: LocationStatus.inUse,
  );

  final establo = LocationEntity(
    uuid: uuidOf(locEstabloSlug),
    name: 'Establo',
    parentUuid: ranch.uuid,
    type: LocationType.stable,
    surfaceArea: 0.3,
    capacity: 6,
    waterSource: 'Bebedero propio',
    terrainType: 'Piso de concreto con camas',
    status: LocationStatus.inUse,
  );

  final areaManejo = LocationEntity(
    uuid: uuidOf(locAreaManejoSlug),
    name: 'Área de Manejo',
    parentUuid: ranch.uuid,
    type: LocationType.chute,
    surfaceArea: 0.05,
    capacity: 4,
    waterSource: '',
    terrainType: 'Manga y báscula',
    status: LocationStatus.available,
  );

  final cuarentena = LocationEntity(
    uuid: uuidOf(locCuarentenaSlug),
    name: 'Corral de Cuarentena',
    parentUuid: ranch.uuid,
    type: LocationType.quarantineArea,
    surfaceArea: 0.4,
    capacity: 5,
    waterSource: 'Bebedero independiente',
    terrainType: 'Tierra, aislado del resto del hato',
    status: LocationStatus.available,
  );

  final bodega = LocationEntity(
    uuid: uuidOf(locBodegaSlug),
    name: 'Bodega de Insumos',
    parentUuid: ranch.uuid,
    type: LocationType.warehouse,
    surfaceArea: 0.1,
    capacity: 0,
    waterSource: '',
    terrainType: 'Nave techada',
    status: LocationStatus.inUse,
    inventory: [
      InventoryItem(
        uuid: uuidOf('inventory-heno'),
        name: 'Pacas de heno',
        category: InventoryCategory.feed,
        quantity: 60,
        unit: 'paca',
        reorderThreshold: 20,
        notes: 'Heno de alfalfa. Registro de demostración.',
      ),
      InventoryItem(
        uuid: uuidOf('inventory-desparasitante'),
        name: 'Desparasitante DEMO',
        category: InventoryCategory.medicine,
        quantity: 3,
        unit: 'frasco',
        reorderThreshold: 5,
        activeIngredient:
            'Ejemplo ilustrativo — no usar como referencia clínica',
        notes: 'Insumo por debajo del mínimo. Registro de demostración.',
      ),
      InventoryItem(
        uuid: uuidOf('inventory-sal-mineral'),
        name: 'Sal mineral',
        category: InventoryCategory.feed,
        quantity: 25,
        unit: 'bulto',
        reorderThreshold: 8,
        notes: 'Suplemento mineral para potreros.',
      ),
      InventoryItem(
        uuid: uuidOf('inventory-herramienta'),
        name: 'Herramienta general',
        category: InventoryCategory.tool,
        quantity: 1,
        unit: 'juego',
        notes: 'Picos, palas, alicates para cerco.',
      ),
    ],
  );

  final milpa = LocationEntity(
    uuid: uuidOf(locMilpaSlug),
    name: 'Milpa',
    parentUuid: ranch.uuid,
    type: LocationType.milpa,
    surfaceArea: 8,
    capacity: 0,
    waterSource: 'Temporal + riego de apoyo desde la represa',
    terrainType: 'Franco arcilloso',
    status: LocationStatus.inUse,
    seedings: [
      SeedingRecord(
        date: reference.subtract(const Duration(days: 60)),
        crop: 'Maíz criollo',
        surface: 8,
        cost: 4800,
      ),
    ],
    irrigations: [
      IrrigationRecord(
        date: reference.subtract(const Duration(days: 7)),
        type: 'Rodado de apoyo',
        duration: const Duration(hours: 3),
        cost: 350,
      ),
    ],
    rains: [
      RainRecord(
        date: reference.subtract(const Duration(days: 15)),
        millimeters: 18,
        location: 'Milpa',
      ),
    ],
    crops: [
      CropRecord(
        uuid: uuidOf('crop-maiz-activo'),
        cropName: 'Maíz criollo',
        variety: 'Criollo sonorense',
        plantingDate: reference.subtract(const Duration(days: 60)),
        expectedHarvestDate: reference.add(const Duration(days: 45)),
        growthStage: CropGrowthStage.vegetative,
        wateringFrequencyDays: 7,
        lastWateredDate: reference.subtract(const Duration(days: 7)),
        status: CropStatus.active,
        surface: 8,
        notes: 'Ciclo actual. Registro de demostración.',
        tasks: [
          CropTask(
            uuid: uuidOf('crop-task-fertilizar'),
            type: CropTaskType.fertilize,
            dueDate: reference.add(const Duration(days: 5)),
            notes: 'Registro de demostración.',
          ),
          CropTask(
            uuid: uuidOf('crop-task-riego'),
            type: CropTaskType.water,
            dueDate: reference.add(const Duration(days: 2)),
            notes: 'Registro de demostración.',
          ),
        ],
      ),
      CropRecord(
        uuid: uuidOf('crop-sorgo-historico'),
        cropName: 'Sorgo forrajero',
        variety: 'Sorgo criollo',
        plantingDate: reference.subtract(const Duration(days: 240)),
        expectedHarvestDate: reference.subtract(const Duration(days: 150)),
        growthStage: CropGrowthStage.harvested,
        status: CropStatus.harvested,
        surface: 5,
        notes: 'Ciclo anterior, ya cosechado. Registro de demostración.',
        harvests: [
          HarvestRecord(
            date: reference.subtract(const Duration(days: 150)),
            yieldKg: 3200,
            qualityRating: 4,
            notes: 'Registro de demostración.',
          ),
        ],
      ),
    ],
  );

  final monte = LocationEntity(
    uuid: uuidOf(locMonteSlug),
    name: 'Monte / Agostadero',
    parentUuid: ranch.uuid,
    type: LocationType.monte,
    surfaceArea: 250,
    capacity: 60,
    waterSource: 'Escurrimientos naturales',
    terrainType: 'Matorral sonorense',
    status: LocationStatus.resting,
  );

  final represa = LocationEntity(
    uuid: uuidOf(locRepresaSlug),
    name: 'Represa',
    parentUuid: ranch.uuid,
    type: LocationType.dam,
    surfaceArea: 2,
    capacity: 0,
    waterSource: 'Escurrimiento natural',
    terrainType: 'Arcilla compactada',
    status: LocationStatus.inUse,
    waters: [
      WaterRecord(
        date: reference.subtract(const Duration(days: 4)),
        level: 70,
        type: WaterType.dam,
        notes: 'Nivel estable tras las últimas lluvias.',
      ),
    ],
  );

  final abrevaderoNorte = LocationEntity(
    uuid: uuidOf(locAbrevaderoNorteSlug),
    name: 'Abrevadero Norte',
    parentUuid: potreroNorte.uuid,
    type: LocationType.trough,
    surfaceArea: 0,
    capacity: 0,
    waterSource: 'Bombeo desde pozo',
    terrainType: 'Cemento',
    status: LocationStatus.inUse,
    waters: [
      WaterRecord(
        date: reference.subtract(const Duration(days: 1)),
        level: 85,
        type: WaterType.trough,
        notes: 'Lleno, sin fugas visibles.',
      ),
    ],
  );

  return [
    ranch,
    potreroNorte,
    potreroSur,
    potreroBecerras,
    corralPrincipal,
    corralMenores,
    corralAves,
    establo,
    areaManejo,
    cuarentena,
    bodega,
    milpa,
    monte,
    represa,
    abrevaderoNorte,
  ];
}
