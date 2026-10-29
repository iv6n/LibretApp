import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_health_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_weight_record.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/isar/isar_lote.dart';
import 'package:libretapp/features/directorio/cultivos/infrastructure/isar_cultivation.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/isar/isar_location.dart';
import 'package:libretapp/features/milking/infrastructure/isar/isar_milking_entry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'community core opens, updates and reopens a real Isar 3.1 database',
    () async {
      final dir = await Directory.systemTemp.createTemp('libret_legacy_');
      final db = IsarDatabase();
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (_) async => dir.path);
      try {
        final fixture = await File(
          'test/fixtures/libretapp_isar_3_1.isar.gz',
        ).readAsBytes();
        await File(
          '${dir.path}/libretapp_db.isar',
        ).writeAsBytes(gzip.decode(fixture));
        final isar = await db.initialize();
        expect(await isar.isarAnimals.count(), 40);
        expect(await isar.isarLocations.count(), 16);
        expect(await isar.isarLotes.count(), 6);
        expect(await isar.isarCultivations.count(), 4);
        expect(await isar.isarHealthRecords.count(), 44);
        expect(await isar.isarWeightRecords.count(), 18);
        expect(await isar.isarMilkingEntrys.count(), 115);
        final animals = await isar.isarAnimals.where().findAll();
        final uuids = animals.map((a) => a.uuid).toSet();
        expect(
          animals.any((a) => a.damUuid != null && uuids.contains(a.damUuid)),
          isTrue,
        );
        final animal = animals.first;
        final uuid = animal.uuid;
        await isar.writeTxn(() async {
          animal.notes = 'Actualizado después de conservar la base anterior';
          await isar.isarAnimals.put(animal);
        });
        await db.close();
        final reopened = await db.initialize();
        expect(await reopened.isarAnimals.count(), 40);
        expect(
          (await reopened.isarAnimals.where().uuidEqualTo(uuid).findFirst())!
              .notes,
          'Actualizado después de conservar la base anterior',
        );
      } finally {
        await db.close();
        messenger.setMockMethodCallHandler(channel, null);
        await dir.delete(recursive: true);
      }
    },
  );
}
