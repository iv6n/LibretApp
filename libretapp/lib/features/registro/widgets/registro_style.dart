/// Asset mapping for the Registro entry cards.
library;

import 'package:libretapp/core/widgets/record_form_style.dart';

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
String? assetForRegistroAction(String action) =>
    styleForRegistroAction(action)?.assetPath;

RecordFormStyle? styleForRegistroAction(String action) {
  switch (_registroKey(action)) {
    case 'rfid':
      return RecordFormStyle.rfid;
    case 'animal':
      return RecordFormStyle.animal;
    case 'lote':
      return RecordFormStyle.lot;
    case 'paricion':
      return RecordFormStyle.birth;
    case 'tratar_lote':
      return RecordFormStyle.bulkHealth;
    case 'destete':
      return RecordFormStyle.weaning;
    case 'sanitario':
      return RecordFormStyle.health;
    case 'peso':
      return RecordFormStyle.weight;
    case 'costo':
      return RecordFormStyle.cost;
    case 'cambio_de_ubicacion':
      return RecordFormStyle.movement;
    case 'produccion':
      return RecordFormStyle.production;
    case 'ordena':
      return RecordFormStyle.milking;
    case 'reproduccion':
      return RecordFormStyle.reproduction;
    case 'comercial':
      return RecordFormStyle.commercial;
    case 'cultivo':
      return RecordFormStyle.crop;
    case 'cosecha':
      return RecordFormStyle.harvest;
    case 'ubicacion':
      return RecordFormStyle.location;
    case 'riego':
      return RecordFormStyle.watering;
    case 'salud_de_cultivo':
      return RecordFormStyle.cropHealth;
    case 'tarea':
      return RecordFormStyle.task;
    default:
      return null;
  }
}
