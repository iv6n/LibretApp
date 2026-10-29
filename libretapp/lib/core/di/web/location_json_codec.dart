import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/dynamic_attribute.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_kind.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_category.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/water_type.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_task_type.dart';

/// Complete location snapshots keep attachments, inventory and agricultural
/// history when a web user edits a destination used by batch movements.
abstract final class LocationJsonCodec {
  static Map<String, dynamic> encode(LocationEntity value) =>
      _encodeLocationEntity(value);
  static LocationEntity decode(Map<String, dynamic> json) =>
      _decodeLocationEntity(json);
}

List<T> _list<T>(
  Map<String, dynamic> j,
  String key,
  T Function(Map<String, dynamic>) decode,
) => (j[key] as List? ?? const [])
    .map((v) => decode(Map<String, dynamic>.from(v as Map)))
    .toList();

Map<String, dynamic> _encodeVisitRecord(VisitRecord v) => {
  'date': v.date.toIso8601String(),
  'animals': v.animals,
  'notes': v.notes,
  'user': v.user,
};
VisitRecord _decodeVisitRecord(Map<String, dynamic> j) => VisitRecord(
  date: DateTime.parse(j['date'] as String),
  animals: j['animals'] as int,
  notes: j['notes'] as String?,
  user: j['user'] as String?,
);

Map<String, dynamic> _encodeWaterRecord(WaterRecord v) => {
  'date': v.date.toIso8601String(),
  'level': v.level,
  'type': v.type.name,
  'notes': v.notes,
};
WaterRecord _decodeWaterRecord(Map<String, dynamic> j) => WaterRecord(
  date: DateTime.parse(j['date'] as String),
  level: (j['level'] as num).toDouble(),
  type: WaterType.values.byName(j['type'] as String),
  notes: j['notes'] as String?,
);

Map<String, dynamic> _encodeSaltRecord(SaltRecord v) => {
  'date': v.date.toIso8601String(),
  'quantityKg': v.quantityKg,
  'notes': v.notes,
};
SaltRecord _decodeSaltRecord(Map<String, dynamic> j) => SaltRecord(
  date: DateTime.parse(j['date'] as String),
  quantityKg: (j['quantityKg'] as num).toDouble(),
  notes: j['notes'] as String?,
);

Map<String, dynamic> _encodeShadeRecord(ShadeRecord v) => {
  'date': v.date.toIso8601String(),
  'shadePercent': v.shadePercent,
  'condition': v.condition,
  'notes': v.notes,
};
ShadeRecord _decodeShadeRecord(Map<String, dynamic> j) => ShadeRecord(
  date: DateTime.parse(j['date'] as String),
  shadePercent: (j['shadePercent'] as num).toDouble(),
  condition: j['condition'] as String,
  notes: j['notes'] as String?,
);

Map<String, dynamic> _encodePastureRecord(PastureRecord v) => {
  'date': v.date.toIso8601String(),
  'grassType': v.grassType,
  'condition': v.condition,
  'carryingCapacity': v.carryingCapacity,
};
PastureRecord _decodePastureRecord(Map<String, dynamic> j) => PastureRecord(
  date: DateTime.parse(j['date'] as String),
  grassType: j['grassType'] as String,
  condition: j['condition'] as String,
  carryingCapacity: (j['carryingCapacity'] as num).toDouble(),
);

Map<String, dynamic> _encodeSeedingRecord(SeedingRecord v) => {
  'date': v.date.toIso8601String(),
  'crop': v.crop,
  'surface': v.surface,
  'cost': v.cost,
};
SeedingRecord _decodeSeedingRecord(Map<String, dynamic> j) => SeedingRecord(
  date: DateTime.parse(j['date'] as String),
  crop: j['crop'] as String,
  surface: (j['surface'] as num).toDouble(),
  cost: (j['cost'] as num).toDouble(),
);

Map<String, dynamic> _encodeIrrigationRecord(IrrigationRecord v) => {
  'date': v.date.toIso8601String(),
  'type': v.type,
  'duration': v.duration.inMicroseconds,
  'cost': v.cost,
};
IrrigationRecord _decodeIrrigationRecord(Map<String, dynamic> j) =>
    IrrigationRecord(
      date: DateTime.parse(j['date'] as String),
      type: j['type'] as String,
      duration: Duration(microseconds: j['duration'] as int),
      cost: (j['cost'] as num).toDouble(),
    );

Map<String, dynamic> _encodeRainRecord(RainRecord v) => {
  'date': v.date.toIso8601String(),
  'millimeters': v.millimeters,
  'location': v.location,
};
RainRecord _decodeRainRecord(Map<String, dynamic> j) => RainRecord(
  date: DateTime.parse(j['date'] as String),
  millimeters: (j['millimeters'] as num).toDouble(),
  location: j['location'] as String,
);

Map<String, dynamic> _encodeLocationCostRecord(LocationCostRecord v) => {
  'date': v.date.toIso8601String(),
  'maintenance': v.maintenance,
  'fences': v.fences,
  'repairs': v.repairs,
  'labor': v.labor,
  'total': v.total,
};
LocationCostRecord _decodeLocationCostRecord(Map<String, dynamic> j) =>
    LocationCostRecord(
      date: DateTime.parse(j['date'] as String),
      maintenance: (j['maintenance'] as num).toDouble(),
      fences: (j['fences'] as num).toDouble(),
      repairs: (j['repairs'] as num).toDouble(),
      labor: (j['labor'] as num).toDouble(),
      total: (j['total'] as num).toDouble(),
    );

Map<String, dynamic> _encodeMaintenanceRecord(MaintenanceRecord v) => {
  'uuid': v.uuid,
  'date': v.date.toIso8601String(),
  'assetName': v.assetName,
  'maintenanceType': v.maintenanceType,
  'nextDueDate': v.nextDueDate?.toIso8601String(),
  'meterReading': v.meterReading,
  'meterUnit': v.meterUnit,
  'cost': v.cost,
  'notes': v.notes,
};
MaintenanceRecord _decodeMaintenanceRecord(Map<String, dynamic> j) =>
    MaintenanceRecord(
      uuid: j['uuid'] as String,
      date: DateTime.parse(j['date'] as String),
      assetName: j['assetName'] as String,
      maintenanceType: j['maintenanceType'] as String,
      nextDueDate: j['nextDueDate'] == null
          ? null
          : DateTime.parse(j['nextDueDate'] as String),
      meterReading: (j['meterReading'] as num?)?.toDouble(),
      meterUnit: j['meterUnit'] as String?,
      cost: (j['cost'] as num).toDouble(),
      notes: j['notes'] as String?,
    );

Map<String, dynamic> _encodeDynamicAttribute(DynamicAttribute v) => {
  'key': v.key,
  'label': v.label,
  'type': v.type.name,
  'unit': v.unit,
  'numberValue': v.numberValue,
  'boolValue': v.boolValue,
  'textValue': v.textValue,
  'updatedAt': v.updatedAt.toIso8601String(),
  'source': v.source,
};
DynamicAttribute _decodeDynamicAttribute(Map<String, dynamic> j) =>
    DynamicAttribute(
      key: j['key'] as String,
      label: j['label'] as String,
      type: DynamicAttributeType.values.byName(j['type'] as String),
      unit: j['unit'] as String?,
      numberValue: j['numberValue'] as num?,
      boolValue: j['boolValue'] as bool?,
      textValue: j['textValue'] as String?,
      updatedAt: DateTime.parse(j['updatedAt'] as String),
      source: j['source'] as String?,
    );

Map<String, dynamic> _encodeInventoryItem(InventoryItem v) => {
  'uuid': v.uuid,
  'name': v.name,
  'quantity': v.quantity,
  'unit': v.unit,
  'reorderThreshold': v.reorderThreshold,
  'expiryDate': v.expiryDate?.toIso8601String(),
  'lastUpdated': v.lastUpdated.toIso8601String(),
  'category': v.category.name,
  'notes': v.notes,
  'activeIngredient': v.activeIngredient,
  'batchNumber': v.batchNumber,
  'withdrawalDays': v.withdrawalDays,
  'unitCost': v.unitCost,
};
InventoryItem _decodeInventoryItem(Map<String, dynamic> j) => InventoryItem(
  uuid: j['uuid'] as String,
  name: j['name'] as String,
  quantity: (j['quantity'] as num).toDouble(),
  unit: j['unit'] as String,
  reorderThreshold: (j['reorderThreshold'] as num?)?.toDouble(),
  expiryDate: j['expiryDate'] == null
      ? null
      : DateTime.parse(j['expiryDate'] as String),
  lastUpdated: DateTime.parse(j['lastUpdated'] as String),
  category: InventoryCategory.values.byName(j['category'] as String),
  notes: j['notes'] as String?,
  activeIngredient: j['activeIngredient'] as String?,
  batchNumber: j['batchNumber'] as String?,
  withdrawalDays: j['withdrawalDays'] as int?,
  unitCost: (j['unitCost'] as num?)?.toDouble(),
);

Map<String, dynamic> _encodeHarvestRecord(HarvestRecord v) => {
  'uuid': v.uuid,
  'date': v.date.toIso8601String(),
  'yieldKg': v.yieldKg,
  'qualityRating': v.qualityRating,
  'isFinal': v.isFinal,
  'notes': v.notes,
};
HarvestRecord _decodeHarvestRecord(Map<String, dynamic> j) => HarvestRecord(
  uuid: j['uuid'] as String,
  date: DateTime.parse(j['date'] as String),
  yieldKg: (j['yieldKg'] as num).toDouble(),
  qualityRating: j['qualityRating'] as int,
  isFinal: j['isFinal'] as bool,
  notes: j['notes'] as String?,
);

Map<String, dynamic> _encodeCropWateringRecord(CropWateringRecord v) => {
  'date': v.date.toIso8601String(),
  'amountLiters': v.amountLiters,
  'method': v.method,
  'notes': v.notes,
};
CropWateringRecord _decodeCropWateringRecord(Map<String, dynamic> j) =>
    CropWateringRecord(
      date: DateTime.parse(j['date'] as String),
      amountLiters: (j['amountLiters'] as num).toDouble(),
      method: j['method'] as String,
      notes: j['notes'] as String?,
    );

Map<String, dynamic> _encodeCropHealthRecord(CropHealthRecord v) => {
  'date': v.date.toIso8601String(),
  'issue': v.issue,
  'treatment': v.treatment,
  'severity': v.severity,
  'notes': v.notes,
};
CropHealthRecord _decodeCropHealthRecord(Map<String, dynamic> j) =>
    CropHealthRecord(
      date: DateTime.parse(j['date'] as String),
      issue: j['issue'] as String,
      treatment: j['treatment'] as String,
      severity: j['severity'] as String,
      notes: j['notes'] as String?,
    );

Map<String, dynamic> _encodeCropTask(CropTask v) => {
  'uuid': v.uuid,
  'type': v.type.name,
  'dueDate': v.dueDate.toIso8601String(),
  'completed': v.completed,
  'notes': v.notes,
};
CropTask _decodeCropTask(Map<String, dynamic> j) => CropTask(
  uuid: j['uuid'] as String,
  type: CropTaskType.values.byName(j['type'] as String),
  dueDate: DateTime.parse(j['dueDate'] as String),
  completed: j['completed'] as bool,
  notes: j['notes'] as String?,
);

Map<String, dynamic> _encodeCropRecord(CropRecord v) => {
  'uuid': v.uuid,
  'cropName': v.cropName,
  'variety': v.variety,
  'plantingDate': v.plantingDate.toIso8601String(),
  'expectedHarvestDate': v.expectedHarvestDate?.toIso8601String(),
  'growthStage': v.growthStage.name,
  'wateringFrequencyDays': v.wateringFrequencyDays,
  'lastWateredDate': v.lastWateredDate?.toIso8601String(),
  'status': v.status.name,
  'surface': v.surface,
  'notes': v.notes,
  'harvests': v.harvests.map(_encodeHarvestRecord).toList(),
  'waterings': v.waterings.map(_encodeCropWateringRecord).toList(),
  'healthRecords': v.healthRecords.map(_encodeCropHealthRecord).toList(),
  'tasks': v.tasks.map(_encodeCropTask).toList(),
};
CropRecord _decodeCropRecord(Map<String, dynamic> j) => CropRecord(
  uuid: j['uuid'] as String,
  cropName: j['cropName'] as String,
  variety: j['variety'] as String,
  plantingDate: DateTime.parse(j['plantingDate'] as String),
  expectedHarvestDate: j['expectedHarvestDate'] == null
      ? null
      : DateTime.parse(j['expectedHarvestDate'] as String),
  growthStage: CropGrowthStage.values.byName(j['growthStage'] as String),
  wateringFrequencyDays: j['wateringFrequencyDays'] as int,
  lastWateredDate: j['lastWateredDate'] == null
      ? null
      : DateTime.parse(j['lastWateredDate'] as String),
  status: CropStatus.values.byName(j['status'] as String),
  surface: (j['surface'] as num).toDouble(),
  notes: j['notes'] as String?,
  harvests: _list(j, 'harvests', _decodeHarvestRecord),
  waterings: _list(j, 'waterings', _decodeCropWateringRecord),
  healthRecords: _list(j, 'healthRecords', _decodeCropHealthRecord),
  tasks: _list(j, 'tasks', _decodeCropTask),
);

Map<String, dynamic> _encodeLocationEntity(LocationEntity v) => {
  'id': v.id,
  'uuid': v.uuid,
  'name': v.name,
  'kind': v.kind.name,
  'parentUuid': v.parentUuid,
  'templateUuid': v.templateUuid,
  'type': v.type.name,
  'surfaceArea': v.surfaceArea,
  'capacity': v.capacity,
  'waterSource': v.waterSource,
  'terrainType': v.terrainType,
  'status': v.status.name,
  'category': v.category?.name,
  'geometry': v.geometry,
  'createdAt': v.createdAt?.toIso8601String(),
  'updatedAt': v.updatedAt?.toIso8601String(),
  'archivedAt': v.archivedAt?.toIso8601String(),
  'isShared': v.isShared,
  'isCommunal': v.isCommunal,
  'imagePaths': v.imagePaths,
  'attributes': v.attributes.map(_encodeDynamicAttribute).toList(),
  'inventory': v.inventory.map(_encodeInventoryItem).toList(),
  'visits': v.visits.map(_encodeVisitRecord).toList(),
  'waters': v.waters.map(_encodeWaterRecord).toList(),
  'salts': v.salts.map(_encodeSaltRecord).toList(),
  'shades': v.shades.map(_encodeShadeRecord).toList(),
  'pastures': v.pastures.map(_encodePastureRecord).toList(),
  'seedings': v.seedings.map(_encodeSeedingRecord).toList(),
  'irrigations': v.irrigations.map(_encodeIrrigationRecord).toList(),
  'rains': v.rains.map(_encodeRainRecord).toList(),
  'costs': v.costs.map(_encodeLocationCostRecord).toList(),
  'maintenances': v.maintenances.map(_encodeMaintenanceRecord).toList(),
  'crops': v.crops.map(_encodeCropRecord).toList(),
};
LocationEntity _decodeLocationEntity(Map<String, dynamic> j) => LocationEntity(
  id: j['id'] as int?,
  uuid: j['uuid'] as String,
  name: j['name'] as String,
  kind: LocationKind.values.byName(j['kind'] as String),
  parentUuid: j['parentUuid'] as String?,
  templateUuid: j['templateUuid'] as String?,
  type: LocationType.values.byName(j['type'] as String),
  surfaceArea: (j['surfaceArea'] as num).toDouble(),
  capacity: j['capacity'] as int,
  waterSource: j['waterSource'] as String,
  terrainType: j['terrainType'] as String,
  status: LocationStatus.values.byName(j['status'] as String),
  category: j['category'] == null
      ? null
      : LocationCategory.values.byName(j['category'] as String),
  geometry: j['geometry'] as String?,
  createdAt: j['createdAt'] == null
      ? null
      : DateTime.parse(j['createdAt'] as String),
  updatedAt: j['updatedAt'] == null
      ? null
      : DateTime.parse(j['updatedAt'] as String),
  archivedAt: j['archivedAt'] == null
      ? null
      : DateTime.parse(j['archivedAt'] as String),
  isShared: j['isShared'] as bool,
  isCommunal: j['isCommunal'] as bool,
  imagePaths: List<String>.from(j['imagePaths'] as List? ?? const []),
  attributes: _list(j, 'attributes', _decodeDynamicAttribute),
  inventory: _list(j, 'inventory', _decodeInventoryItem),
  visits: _list(j, 'visits', _decodeVisitRecord),
  waters: _list(j, 'waters', _decodeWaterRecord),
  salts: _list(j, 'salts', _decodeSaltRecord),
  shades: _list(j, 'shades', _decodeShadeRecord),
  pastures: _list(j, 'pastures', _decodePastureRecord),
  seedings: _list(j, 'seedings', _decodeSeedingRecord),
  irrigations: _list(j, 'irrigations', _decodeIrrigationRecord),
  rains: _list(j, 'rains', _decodeRainRecord),
  costs: _list(j, 'costs', _decodeLocationCostRecord),
  maintenances: _list(j, 'maintenances', _decodeMaintenanceRecord),
  crops: _list(j, 'crops', _decodeCropRecord),
);
