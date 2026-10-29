import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/persistence/drift_feature_database.dart';
import 'package:libretapp/core/persistence/drift_feature_record_store.dart';
import 'package:libretapp/core/persistence/isar_feature_record_store.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/persistence/json_feature_repository.dart';
import 'package:libretapp/features/ubicaciones/almacen/inventory_models.dart';
import 'package:libretapp/features/ubicaciones/almacen/inventory_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final adapter in ['Isar', 'Drift']) {
    group(adapter, () {
      late Directory root;
      late FeatureRecordStore store;
      late Future<void> Function() close;
      late InventoryService inventory;
      setUp(() async {
        root = await Directory.systemTemp.createTemp('libret_store_');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'), (_) async => root.path);
        if (adapter == 'Isar') {
          final db = IsarDatabase.workspace(root.path, name: 'shared');
          await db.initialize(); store = IsarFeatureRecordStore(db); close = db.close;
        } else {
          final db = DriftFeatureDatabase(NativeDatabase.memory());
          store = DriftFeatureRecordStore(db); close = db.close;
        }
        inventory = InventoryService(JsonFeatureRepository<InventoryTransaction>(store: store,
          kind: 'inventory.transaction', decode: InventoryTransaction.fromJson, encode: (value) => value.toJson()));
      });
      tearDown(() async {
        await close();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'), null);
        await root.delete(recursive: true);
      });
      FeatureRecord row(String uuid, {String farm='a', String kind='test'}) => FeatureRecord(uuid:uuid, farmId:farm,
        kind:kind, payload: {'owner':farm}, createdAt:DateTime(2026), updatedAt:DateTime(2026));
      test('UUID farm and kind collisions roll back the entire write', () async {
        await store.put(row('existing'));
        await expectLater(store.put(row('new'), alsoPut:[row('existing', farm:'b')]), throwsArgumentError);
        expect(await store.get('a','new'), isNull);
        expect((await store.get('a','existing'))!.kind, 'test');
        await expectLater(store.put(row('existing', kind:'other')), throwsArgumentError);
        expect((await store.get('a','existing'))!.kind, 'test');
      });
      test('concurrent consumptions cannot create negative stock', () async {
        await inventory.record(farmId:'a', productId:'feed', type:InventoryTransactionType.entry, quantity:100, unit:'kg');
        Future<bool> consume(String uuid) async {
          try {
            await inventory.record(farmId:'a', productId:'feed', type:InventoryTransactionType.consumption, quantity:70, unit:'kg', uuid:uuid);
            return true;
          } on InventoryValidationException { return false; }
        }
        final results = await Future.wait([consume('one'),consume('two')]);
        expect(results.where((ok)=>ok), hasLength(1));
        expect((await inventory.balance('a','feed')).quantity,30);
      });
      test('transfer preserves quantity and valuation, conflicting retry fails', () async {
        await inventory.record(farmId:'a', productId:'feed', type:InventoryTransactionType.entry, quantity:100, unit:'kg',locationId:'A',unitCostCents:200);
        Future<InventoryTransaction> transfer(double quantity) => inventory.record(farmId:'a', productId:'feed', type:InventoryTransactionType.transfer,
          quantity:quantity, unit:'kg', locationId:'A',destinationLocationId:'B',uuid:'transfer');
        await Future.wait([transfer(40),transfer(40)]);
        await expectLater(transfer(41), throwsA(isA<InventoryValidationException>()));
        final a=await inventory.balance('a','feed',locationId:'A');
        final b=await inventory.balance('a','feed',locationId:'B');
        final farm=await inventory.balance('a','feed');
        expect(a.quantity,60); expect(b.quantity,40); expect(farm.quantity,100);
        expect(a.valueCents,12000); expect(b.valueCents,8000); expect(farm.valueCents,20000);
        expect(await inventory.kardex('a','feed'),hasLength(2));
      });
    });
  }
}
