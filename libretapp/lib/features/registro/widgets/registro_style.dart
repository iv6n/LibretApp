/// Asset mapping for the Registro entry cards.
library;

import 'package:libretapp/core/assets/app_asset_paths.dart';

String _registroKey(String value) => value
    .toLowerCase()
    .trim()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ü', 'u')
    .replaceAll('ñ', 'n')
    .replaceAll(' ', '_');

/// Returns the approved raster asset for a Registro menu action.
///
/// Every known Registro card resolves to a centralized asset; unknown or
/// future actions return null so the caller can keep its fallback.
String? assetForRegistroAction(String action) {
  switch (_registroKey(action)) {
    case 'rfid':
      return AppAssetPaths.recordRfid;
    case 'animal':
      return AppAssetPaths.recordAnimal;
    case 'lote':
      return AppAssetPaths.recordLot;
    case 'paricion':
      return AppAssetPaths.healthBirth;
    case 'tratar_lote':
      return AppAssetPaths.healthTreatment;
    case 'sanitario':
      return AppAssetPaths.healthVaccine;
    case 'peso':
      return AppAssetPaths.healthWeight;
    case 'costo':
      return AppAssetPaths.recordCost;
    case 'cambio_de_ubicacion':
      return AppAssetPaths.recordMovement;
    case 'produccion':
      return AppAssetPaths.recordProduction;
    case 'ordena':
      return AppAssetPaths.healthMilkProduction;
    case 'reproduccion':
      return AppAssetPaths.recordReproduction;
    case 'comercial':
      return AppAssetPaths.recordSale;
    case 'cultivo':
      return AppAssetPaths.cropField;
    case 'cosecha':
      return AppAssetPaths.cropHarvested;
    case 'ubicacion':
      return AppAssetPaths.recordLocation;
    case 'riego':
      return AppAssetPaths.recordIrrigation;
    case 'salud_de_cultivo':
      return AppAssetPaths.recordCropHealth;
    case 'tarea':
      return AppAssetPaths.recordTask;
    default:
      return null;
  }
}
