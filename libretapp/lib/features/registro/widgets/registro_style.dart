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
/// Actions without a semantically specific asset intentionally return null so
/// their caller can keep the Material icon fallback.
String? assetForRegistroAction(String action) {
  switch (_registroKey(action)) {
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
    default:
      return null;
  }
}
