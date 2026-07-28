import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/ubicaciones_export_sheet.dart';

class _FakeLocationRepository implements LocationRepository {
  _FakeLocationRepository(this._locations);
  final List<LocationEntity> _locations;

  @override
  Future<List<LocationEntity>> getAll() async => _locations;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LocationEntity _location({
  required String uuid,
  required String name,
  LocationType type = LocationType.pasture,
  LocationStatus status = LocationStatus.available,
}) {
  return LocationEntity(
    uuid: uuid,
    name: name,
    type: type,
    surfaceArea: 12.5,
    capacity: 30,
    waterSource: 'Pozo',
    terrainType: 'Plano',
    status: status,
  );
}

List<Data?> _row(Excel excel, int index) => excel['Ubicaciones'].rows[index];

String? _text(Data? cell) => cell?.value?.toString();

void main() {
  test('writes a header row and one row per location', () async {
    final repository = _FakeLocationRepository([
      _location(uuid: 'u1', name: 'Potrero Norte'),
      _location(
        uuid: 'u2',
        name: 'Corral',
        type: LocationType.corral,
        status: LocationStatus.inUse,
      ),
    ]);
    final sheet = UbicacionesExportSheet(repository);
    final excel = Excel.createExcel();

    await sheet.writeTo(excel);

    final rows = excel['Ubicaciones'].rows;
    expect(rows, hasLength(3)); // header + 2 locations
    expect(_text(_row(excel, 0)[0]), 'Nombre');
    expect(_text(_row(excel, 1)[0]), 'Potrero Norte');
    expect(_text(_row(excel, 1)[1]), 'pasture');
    expect(_text(_row(excel, 2)[0]), 'Corral');
    expect(_text(_row(excel, 2)[1]), 'corral');
  });

  test('writes an empty sheet (header only) when there are no locations', () async {
    final sheet = UbicacionesExportSheet(_FakeLocationRepository(const []));
    final excel = Excel.createExcel();

    await sheet.writeTo(excel);

    expect(excel['Ubicaciones'].rows, hasLength(1));
  });
}
