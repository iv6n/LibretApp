/// features › ubicaciones › infrastructure › ubicaciones_export_sheet — writes
/// the "Ubicaciones" sheet for [ExportService].
library;

import 'package:excel/excel.dart';
import 'package:libretapp/core/services/exportable_sheet.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class UbicacionesExportSheet implements ExportableSheet {
  UbicacionesExportSheet(this._locationRepository);

  final LocationRepository _locationRepository;

  @override
  Future<void> writeTo(Excel excel) async {
    final sheet = excel['Ubicaciones'];
    writeExcelRow(sheet, 0, [
      'Nombre',
      'Tipo',
      'Superficie (m²)',
      'Capacidad',
      'Estado',
      'Fuente de Agua',
      'Tipo Terreno',
    ], header: true);

    final locations = await _locationRepository.getAll();
    for (var i = 0; i < locations.length; i++) {
      final l = locations[i];
      writeExcelRow(sheet, i + 1, [
        l.name,
        l.type.name,
        l.surfaceArea,
        l.capacity,
        l.status,
        l.waterSource,
        l.terrainType,
      ]);
    }
  }
}
