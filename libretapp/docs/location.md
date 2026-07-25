# Location Model

Complete reference for the ubicaciones domain: entities, enums, persistence rules, hierarchy, and migration.

---

## LocationEntity

`lib/features/ubicaciones/domain/entities/location_entity.dart`

| Field | Type | Default | Notes |
|---|---|---|---|
| `id` | `int?` | `null` | Isar auto-increment primary key |
| `uuid` | `String` | required | Stable cross-device identifier |
| `name` | `String` | required | Display name |
| `kind` | `LocationKind` | `LocationKind.instance` | `instance` vs `template` |
| `parentUuid` | `String?` | `null` | UUID of parent location. **Sole source of truth for hierarchy.** |
| `templateUuid` | `String?` | `null` | UUID of the template this was created from |
| `type` | `LocationType` | required | One of 43 English enum values (see below) |
| `surfaceArea` | `double` | required | Surface area in hectares |
| `capacity` | `int` | required | Max animal head capacity |
| `waterSource` | `String` | required | Free-text water source description |
| `terrainType` | `String` | required | Free-text terrain description |
| `status` | `LocationStatus` | `LocationStatus.available` | Operational status |
| `category` | `LocationCategory?` | `null` | Explicit category override; falls back to `type.category` |
| `geometry` | `String?` | `null` | GeoJSON string for GIS integration |
| `isShared` | `bool` | `false` | Shared across multiple herds/operations |
| `isCommunal` | `bool` | `false` | Communal/ejido land (affects legal tenure logic) |
| `attributes` | `List<DynamicAttribute>` | `[]` | User-defined key-value attributes |
| `inventory` | `List<InventoryItem>` | `[]` | Stored inventory items |
| `visits` | `List<VisitRecord>` | `[]` | Vet/operator visit records |
| `waters` | `List<WaterRecord>` | `[]` | Water source records |
| `salts` | `List<SaltRecord>` | `[]` | Salt/mineral supplement records |
| `shades` | `List<ShadeRecord>` | `[]` | Shade structure records |
| `pastures` | `List<PastureRecord>` | `[]` | Pasture condition records |
| `seedings` | `List<SeedingRecord>` | `[]` | Seeding/planting records |
| `irrigations` | `List<IrrigationRecord>` | `[]` | Irrigation records |
| `rains` | `List<RainRecord>` | `[]` | Rainfall records |
| `costs` | `List<CostRecord>` | `[]` | Cost records |
| `crops` | `List<CropRecord>` | `[]` | Crop records |

### Computed getter

```dart
LocationCategory get effectiveCategory => category ?? type.category;
```

---

## LocationType (43 values)

`lib/features/ubicaciones/domain/enums/location_type.dart`

Isar stores the enum `.name` string (e.g. `"pasture"`). Old Spanish values were remapped once by `LocationEnumMigrationService`.

### Macro property — `isRootType = true`

These are top-level containers. They can act as parents for any other location.

| Value | Label |
|---|---|
| `ranch` | Ranch |
| `farm` | Farm |
| `finca` | Finca |
| `hacienda` | Hacienda |
| `plantation` | Plantation |
| `ejido` | Ejido |
| `property` | Property |
| `homestead` | Homestead |

### Livestock — `supportsAnimals = true` (most)

| Value | Label |
|---|---|
| `pasture` | Pasture |
| `corral` | Corral |
| `feedlot` | Feedlot |
| `barn` | Barn |
| `stable` | Stable |
| `pen` | Pen |

### Handling

| Value | Label |
|---|---|
| `chute` | Chute |
| `quarantineArea` | Quarantine Area |
| `loadingArea` | Loading Area |
| `weighingArea` | Weighing Area |

### Agricultural — `supportsCrops = true`

| Value | Label |
|---|---|
| `field` | Field |
| `plot` | Plot |
| `milpa` | Milpa |
| `orchard` | Orchard |
| `greenhouse` | Greenhouse |
| `nursery` | Nursery |
| `garden` | Garden |

### Natural

| Value | Label | Notes |
|---|---|---|
| `monte` | Monte | Scrubland/brushland; retained as-is (recognised management unit in MX/LATAM) |
| `forest` | Forest | |
| `lagoon` | Lagoon | |
| `river` | River | |
| `wetland` | Wetland | |
| `protectedArea` | Protected Area | |

### Infrastructure — `supportsInventory = true` (subset)

| Value | Label | supportsInventory |
|---|---|---|
| `warehouse` | Warehouse | ✓ |
| `workshop` | Workshop | ✓ |
| `office` | Office | |
| `house` | House | ✓ |
| `road` | Road | |
| `waterTank` | Water Tank | |
| `gate` | Gate | |

### Water

| Value | Label |
|---|---|
| `well` | Well |
| `dam` | Dam |
| `spring` | Spring |
| `pond` | Pond |
| `trough` | Trough |
| `canal` | Canal |
| `reservoir` | Reservoir |

### Extension helpers (`LocationTypeX`)

| Getter | Return | Description |
|---|---|---|
| `label` | `String` | English display name (fallback; production uses ARB) |
| `category` | `LocationCategory` | Operational category |
| `isRootType` | `bool` | `true` for macro category; can be a hierarchy root |
| `supportsAnimals` | `bool` | Animals can be assigned here |
| `supportsInventory` | `bool` | Inventory items can be stored here |
| `supportsCrops` | `bool` | Crop records can be attached |

### Legacy name map (Isar migration)

```dart
static const Map<String, String> legacyNameMap = {
  'rancho'        : 'ranch',
  'potrero'       : 'pasture',
  'monte'         : 'monte',
  'corral'        : 'corral',
  'almacenamiento': 'warehouse',
  'aguada'        : 'pond',
  'siembra'       : 'field',
  'casa'          : 'house',
};
```

---

## LocationCategory (7 values)

`lib/features/ubicaciones/domain/enums/location_category.dart`

| Value | Purpose |
|---|---|
| `macro` | Top-level property containers (ranch, farm, ejido …) |
| `agricultural` | Crop and cultivation zones |
| `livestock` | Animal grazing and housing |
| `handling` | Animal processing / handling infrastructure |
| `natural` | Unmanaged / natural terrain |
| `infrastructure` | Buildings, roads, storage |
| `water` | Water bodies and distribution |

---

## LocationStatus (6 values)

`lib/features/ubicaciones/domain/enums/location_status.dart`

| Value | Meaning |
|---|---|
| `available` | Ready for use; default for new locations |
| `inUse` | Currently occupied/active |
| `resting` | Temporarily rested (pasture rotation, etc.) |
| `closed` | Administratively closed |
| `inPreparation` | Being prepared for use |
| `abandoned` | No longer in use |

Legacy name map:

```dart
{ 'disponible':'available', 'enUso':'inUse', 'enDescanso':'resting',
  'clausurado':'closed', 'enPreparacion':'inPreparation' }
```

---

## WaterType (7 values)

`lib/features/ubicaciones/domain/enums/water_type.dart`

| Value | Meaning |
|---|---|
| `well` | Bored or dug well |
| `dam` | Earth/concrete dam |
| `tank` | Storage tank |
| `spring` | Natural spring |
| `river` | River or stream |
| `pond` | Natural or artificial pond |
| `trough` | Drinking trough |

Legacy name map: `{ 'pozo':'well', 'represo':'dam', 'pila':'tank' }`

---

## InventoryCategory (5 values)

`lib/features/ubicaciones/domain/entities/inventory_item.dart`

| Value | Meaning |
|---|---|
| `feed` | Animal feed / forage |
| `medicine` | Veterinary medicines |
| `tool` | Hand tools |
| `equipment` | Machinery / equipment |
| `other` | Default for uncategorised items |

Legacy name map: `{ 'pienso':'feed', 'medicina':'medicine', 'herramienta':'tool', 'equipo':'equipment', 'otro':'other' }`

---

## Parent-child hierarchy

- The parent-child relationship is maintained **only via `parentUuid`** in the child entity.
- There is no `childUuids` list on the parent — it was removed.
- To get all children of a location: query `IsarLocation` where `parentUuid == parent.uuid`.
- Only `isRootType` locations (macro category) can appear as valid parents in the UI.

---

## New domain entities

### Organization

`lib/core/domain/organization.dart`

Represents a legal entity that may hold land tenure rights.

| Field | Type |
|---|---|
| `id` | `String` |
| `name` | `String` |
| `type` | `OrganizationType` |
| `taxId` | `String?` |
| `notes` | `String?` |

`OrganizationType` values: `ranch, farm, ejido, cooperative, individual`

---

### TenureType (8 values)

`lib/features/ubicaciones/domain/enums/tenure_type.dart`

| Value | Meaning |
|---|---|
| `owner` | Full ownership |
| `leased` | Leased from another party |
| `communal` | Communal access rights |
| `ejidoRight` | Ejido usufruct right |
| `usufruct` | Usufruct without ownership |
| `licensed` | Licensed use |
| `permitted` | Permit-based access |
| `concession` | Government concession |

---

### LandTenure

`lib/features/ubicaciones/domain/entities/land_tenure.dart`

Links a location to its legal tenure arrangement.

| Field | Type | Required |
|---|---|---|
| `id` | `String` | ✓ |
| `locationId` | `String` | ✓ |
| `tenureType` | `TenureType` | ✓ |
| `holderName` | `String` | ✓ |
| `active` | `bool` | ✓ |
| `organizationId` | `String?` | |
| `livestockCapacity` | `int?` | |
| `areaHectares` | `double?` | |
| `startDate` | `DateTime?` | |
| `endDate` | `DateTime?` | |
| `legalReference` | `String?` | |
| `notes` | `String?` | |

---

### AnimalLocationHistory

`lib/features/directorio/animales/domain/entities/animal_location_history.dart`

Records a single animal movement event.

| Field | Type |
|---|---|
| `id` | `String` |
| `animalId` | `String` |
| `fromLocationId` | `String?` |
| `toLocationId` | `String` |
| `reason` | `MovementReason` |
| `date` | `DateTime` |
| `notes` | `String?` |

`MovementReason` values: `sale, purchase, transfer, treatment, grazing, other`

---

## Isar persistence

### Field rename safety

Fields renamed from Spanish to English use `@Name('originalSpanishName')` so the stored Isar column name is preserved and no data migration is needed:

```dart
@Name('currentPaddockId') String? currentLocationId;  // IsarAnimal
@Name('nombre')           late String name;            // IsarLote
@Name('activo')           bool active = true;          // IsarLote
@Name('fechaCreacion')    late DateTime createdAt;     // IsarLote
```

### Enum migration (value strings)

Isar stores enum values as `.name` strings. Because enum identifiers changed from Spanish to English, `LocationEnumMigrationService` runs **once** on first app launch after the upgrade.

- **Trigger**: checks `SharedPreferences` key `locationEnumsMigrated_v1`.
- **Action**: reads all `IsarLocation` and `IsarInventoryItem` records, remaps any legacy Spanish string to the English equivalent using each enum's `legacyNameMap`, then writes back.
- **Idempotent**: sets the flag after completion; subsequent launches skip migration entirely.
- **DI**: registered as `LazySingleton` in `lib/core/di/injection.dart`; called from `AppBloc._onAppStarted`.

### `.g.dart` regeneration

After any change to an `@collection` class or its fields, run:

```
flutter pub run build_runner build --delete-conflicting-outputs
```

from the `libretapp/` directory. The generated `isar_location.g.dart` contains schema field IDs and all typed query methods (e.g. `categoryEqualTo`, `isSharedEqualTo`).
