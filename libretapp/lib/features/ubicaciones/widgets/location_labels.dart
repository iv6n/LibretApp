/// features › ubicaciones › widgets › location_labels — localized labels for location enums.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_category.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';

String locationTypeLabel(BuildContext context, LocationType type) {
  final languageCode = Localizations.localeOf(context).languageCode;
  return locationTypeLabelByLanguage(type, languageCode);
}

String locationTypeLabelByLanguage(LocationType type, String languageCode) {
  if (languageCode.toLowerCase().startsWith('es')) {
    return _locationTypeEs[type] ?? type.label;
  }
  return type.label;
}

String locationTypeLabelEs(LocationType type) =>
    _locationTypeEs[type] ?? type.label;

String locationStatusLabel(BuildContext context, LocationStatus status) {
  final languageCode = Localizations.localeOf(context).languageCode;
  return locationStatusLabelByLanguage(status, languageCode);
}

String locationStatusLabelByLanguage(
  LocationStatus status,
  String languageCode,
) {
  if (languageCode.toLowerCase().startsWith('es')) {
    return _locationStatusEs[status] ?? status.label;
  }
  return status.label;
}

String locationCategoryLabel(BuildContext context, LocationCategory category) {
  final languageCode = Localizations.localeOf(context).languageCode;
  return locationCategoryLabelByLanguage(category, languageCode);
}

String locationCategoryLabelByLanguage(
  LocationCategory category,
  String languageCode,
) {
  if (languageCode.toLowerCase().startsWith('es')) {
    return _locationCategoryEs[category] ?? category.name;
  }
  return _locationCategoryEn[category] ?? category.name;
}

IconData iconForLocationCategory(LocationCategory category) {
  switch (category) {
    case LocationCategory.macro:
      return Icons.home_work_outlined;
    case LocationCategory.livestock:
      return Icons.fence;
    case LocationCategory.handling:
      return Icons.pets_outlined;
    case LocationCategory.agricultural:
      return Icons.agriculture;
    case LocationCategory.natural:
      return Icons.forest;
    case LocationCategory.infrastructure:
      return Icons.warehouse_outlined;
    case LocationCategory.water:
      return Icons.water_drop_outlined;
  }
}

String locationPropertyLabel(BuildContext context, String key) {
  final languageCode = Localizations.localeOf(context).languageCode;
  return locationPropertyLabelByLanguage(key, languageCode);
}

String locationPropertyLabelByLanguage(String key, String languageCode) {
  if (languageCode.toLowerCase().startsWith('es')) {
    return _locationPropertyEs[key] ?? key;
  }
  return _locationPropertyEn[key] ?? key;
}

const Map<LocationCategory, String> _locationCategoryEs = {
  LocationCategory.macro: 'Propiedad',
  LocationCategory.livestock: 'Ganaderia',
  LocationCategory.handling: 'Manejo',
  LocationCategory.agricultural: 'Agricola',
  LocationCategory.natural: 'Natural',
  LocationCategory.infrastructure: 'Infraestructura',
  LocationCategory.water: 'Agua',
};

const Map<LocationCategory, String> _locationCategoryEn = {
  LocationCategory.macro: 'Property',
  LocationCategory.livestock: 'Livestock',
  LocationCategory.handling: 'Handling',
  LocationCategory.agricultural: 'Agricultural',
  LocationCategory.natural: 'Natural',
  LocationCategory.infrastructure: 'Infrastructure',
  LocationCategory.water: 'Water',
};

const Map<LocationStatus, String> _locationStatusEs = {
  LocationStatus.available: 'Disponible',
  LocationStatus.inUse: 'En uso',
  LocationStatus.resting: 'En descanso',
  LocationStatus.closed: 'Cerrada',
  LocationStatus.inPreparation: 'En preparacion',
  LocationStatus.abandoned: 'Abandonada',
};

const Map<String, String> _locationPropertyEs = {
  'geometry': 'Geometria (GeoJSON)',
  'isShared': 'Uso compartido',
  'isCommunal': 'Uso comunal',
  'registryCode': 'Codigo de registro',
  'ownerName': 'Responsable o propietario',
  'herdManager': 'Responsable ganadero',
  'productionFocus': 'Enfoque productivo',
  'lotCount': 'Cantidad de lotes',
  'historicalName': 'Nombre historico',
  'mainCrop': 'Cultivo principal',
  'assemblyContact': 'Contacto de asamblea',
  'cadastralId': 'Clave catastral',
  'householdCount': 'Numero de hogares',
  'fenceCondition': 'Condicion del cercado',
  'shadeCoverage': 'Cobertura de sombra',
  'handlingEase': 'Facilidad de manejo',
  'hasWaterPoint': 'Tiene punto de agua',
  'pastureCondition': 'Condicion del pasto',
  'corralMaterial': 'Material del corral',
  'feedlotStage': 'Etapa de engorda',
  'ventilationType': 'Tipo de ventilacion',
  'stallCount': 'Numero de establos',
  'penPurpose': 'Uso de la corraleta',
  'throughputPerHour': 'Capacidad por hora',
  'floorType': 'Tipo de piso',
  'roofed': 'Cuenta con techado',
  'chuteLength': 'Longitud de manga',
  'quarantineDays': 'Dias de cuarentena',
  'rampType': 'Tipo de rampa',
  'scaleType': 'Tipo de bascula',
  'soilClass': 'Clase de suelo',
  'irrigationType': 'Tipo de riego',
  'cropRotation': 'Rotacion de cultivos',
  'currentCrop': 'Cultivo actual',
  'plotNumber': 'Numero de parcela',
  'companionCrops': 'Cultivos asociados',
  'treeDensity': 'Densidad de arboles',
  'greenhouseType': 'Tipo de invernadero',
  'seedlingCapacity': 'Capacidad de plantulas',
  'gardenPurpose': 'Uso del jardin',
  'conservationStatus': 'Estado de conservacion',
  'biodiversityNotes': 'Notas de biodiversidad',
  'accessLevel': 'Nivel de acceso',
  'forageSpecies': 'Especies forrajeras',
  'canopyCoverage': 'Cobertura de dosel',
  'lagoonDepth': 'Profundidad de laguna',
  'riverFlowSeason': 'Temporada de caudal',
  'wetlandType': 'Tipo de humedal',
  'protectionCategory': 'Categoria de proteccion',
  'serviceState': 'Estado de servicio',
  'electricityAvailable': 'Cuenta con energia electrica',
  'securityLevel': 'Nivel de seguridad',
  'storageClass': 'Clase de almacenamiento',
  'toolSpecialty': 'Especialidad del taller',
  'officeUse': 'Uso de oficina',
  'occupancyType': 'Tipo de ocupacion',
  'roadSurface': 'Tipo de superficie del camino',
  'tankMaterial': 'Material del tanque',
  'gateType': 'Tipo de porton',
  'waterQuality': 'Calidad del agua',
  'flowRate': 'Caudal',
  'storageVolume': 'Volumen de almacenamiento',
  'wellDepth': 'Profundidad del pozo',
  'damType': 'Tipo de presa',
  'springProtection': 'Proteccion del manantial',
  'pondUse': 'Uso del estanque',
  'troughMaterial': 'Material del bebedero',
  'canalLining': 'Recubrimiento del canal',
  'reservoirUse': 'Uso del reservorio',
};

const Map<String, String> _locationPropertyEn = {
  'geometry': 'Geometry (GeoJSON)',
  'isShared': 'Shared usage',
  'isCommunal': 'Communal usage',
  'registryCode': 'Registry code',
  'ownerName': 'Owner or manager',
  'herdManager': 'Herd manager',
  'productionFocus': 'Production focus',
  'lotCount': 'Lot count',
  'historicalName': 'Historic name',
  'mainCrop': 'Main crop',
  'assemblyContact': 'Assembly contact',
  'cadastralId': 'Cadastral ID',
  'householdCount': 'Household count',
  'fenceCondition': 'Fence condition',
  'shadeCoverage': 'Shade coverage',
  'handlingEase': 'Handling ease',
  'hasWaterPoint': 'Has water point',
  'pastureCondition': 'Pasture condition',
  'corralMaterial': 'Corral material',
  'feedlotStage': 'Feedlot stage',
  'ventilationType': 'Ventilation type',
  'stallCount': 'Stall count',
  'penPurpose': 'Pen purpose',
  'throughputPerHour': 'Throughput per hour',
  'floorType': 'Floor type',
  'roofed': 'Roofed',
  'chuteLength': 'Chute length',
  'quarantineDays': 'Quarantine days',
  'rampType': 'Ramp type',
  'scaleType': 'Scale type',
  'soilClass': 'Soil class',
  'irrigationType': 'Irrigation type',
  'cropRotation': 'Crop rotation',
  'currentCrop': 'Current crop',
  'plotNumber': 'Plot number',
  'companionCrops': 'Companion crops',
  'treeDensity': 'Tree density',
  'greenhouseType': 'Greenhouse type',
  'seedlingCapacity': 'Seedling capacity',
  'gardenPurpose': 'Garden purpose',
  'conservationStatus': 'Conservation status',
  'biodiversityNotes': 'Biodiversity notes',
  'accessLevel': 'Access level',
  'forageSpecies': 'Forage species',
  'canopyCoverage': 'Canopy coverage',
  'lagoonDepth': 'Lagoon depth',
  'riverFlowSeason': 'River flow season',
  'wetlandType': 'Wetland type',
  'protectionCategory': 'Protection category',
  'serviceState': 'Service state',
  'electricityAvailable': 'Electricity available',
  'securityLevel': 'Security level',
  'storageClass': 'Storage class',
  'toolSpecialty': 'Tool specialty',
  'officeUse': 'Office use',
  'occupancyType': 'Occupancy type',
  'roadSurface': 'Road surface',
  'tankMaterial': 'Tank material',
  'gateType': 'Gate type',
  'waterQuality': 'Water quality',
  'flowRate': 'Flow rate',
  'storageVolume': 'Storage volume',
  'wellDepth': 'Well depth',
  'damType': 'Dam type',
  'springProtection': 'Spring protection',
  'pondUse': 'Pond use',
  'troughMaterial': 'Trough material',
  'canalLining': 'Canal lining',
  'reservoirUse': 'Reservoir use',
};

const Map<LocationType, String> _locationTypeEs = {
  LocationType.ranch: 'Rancho',
  LocationType.farm: 'Granja',
  LocationType.finca: 'Finca',
  LocationType.hacienda: 'Hacienda',
  LocationType.plantation: 'Plantacion',
  LocationType.ejido: 'Derecho ejidal',
  LocationType.property: 'Propiedad',
  LocationType.homestead: 'Casa principal',
  LocationType.pasture: 'Potrero',
  LocationType.corral: 'Corral',
  LocationType.feedlot: 'Engorda',
  LocationType.barn: 'Establo',
  LocationType.stable: 'Caballeriza',
  LocationType.pen: 'Corraleta',
  LocationType.chute: 'Manga',
  LocationType.quarantineArea: 'Area de cuarentena',
  LocationType.loadingArea: 'Area de carga',
  LocationType.weighingArea: 'Area de pesaje',
  LocationType.field: 'Campo',
  LocationType.plot: 'Parcela',
  LocationType.milpa: 'Milpa',
  LocationType.orchard: 'Huerto',
  LocationType.greenhouse: 'Invernadero',
  LocationType.nursery: 'Vivero',
  LocationType.garden: 'Jardin',
  LocationType.monte: 'Monte',
  LocationType.forest: 'Bosque',
  LocationType.lagoon: 'Laguna',
  LocationType.river: 'Rio',
  LocationType.wetland: 'Humedal',
  LocationType.protectedArea: 'Area protegida',
  LocationType.warehouse: 'Bodega',
  LocationType.workshop: 'Taller',
  LocationType.office: 'Oficina',
  LocationType.house: 'Casa',
  LocationType.road: 'Camino',
  LocationType.waterTank: 'Tanque de agua',
  LocationType.gate: 'Porton',
  LocationType.well: 'Pozo',
  LocationType.dam: 'Presa',
  LocationType.spring: 'Manantial',
  LocationType.pond: 'Estanque',
  LocationType.trough: 'Bebedero',
  LocationType.canal: 'Canal',
  LocationType.reservoir: 'Reservorio',
};
