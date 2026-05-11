import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/commercial_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/cost_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/health_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/movement_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/production_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/reproduction_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/weight_record_repository_isar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'libretapp_records_isar_test_',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          return tempDir.path;
        });
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await IsarDatabase().close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  tearDown(() async {
    await IsarDatabase().close();
  });

  // ─── HealthRecord ──────────────────────────────────────────────────────────

  group('HealthRecordRepositoryIsar', () {
    test(
      'guarda y lee un registro de salud con todos sus campos',
      () async {
        final repo = HealthRecordRepositoryIsar(IsarDatabase());
        const uuid = 'animal-health-1';

        final saved = await repo.addHealthRecord(
          uuid,
          HealthRecord(
            date: DateTime(2025, 3, 15),
            type: HealthRecordType.vaccine,
            product: 'Vacuna Triple',
            dose: '5 ml',
            appliedBy: 'Dr. López',
            notes: 'Sin reacciones adversas',
          ),
        );

        expect(saved.id, isNotNull);

        final records = await repo.getHealthRecords(uuid);

        expect(records, hasLength(1));
        expect(records.first.type, HealthRecordType.vaccine);
        expect(records.first.product, 'Vacuna Triple');
        expect(records.first.dose, '5 ml');
        expect(records.first.appliedBy, 'Dr. López');
        expect(records.first.notes, 'Sin reacciones adversas');
      },
      skip: !_canRunIsarNative(),
    );

    test(
      'no retorna registros pertenecientes a otro animal',
      () async {
        final repo = HealthRecordRepositoryIsar(IsarDatabase());

        await repo.addHealthRecord(
          'animal-health-A',
          HealthRecord(
            date: DateTime(2025, 3, 15),
            type: HealthRecordType.deworming,
            product: 'Ivermectina',
          ),
        );

        final recordsB = await repo.getHealthRecords('animal-health-B');
        expect(recordsB, isEmpty);
      },
      skip: !_canRunIsarNative(),
    );

    test('elimina el registro y deja la colección vacía', () async {
      final repo = HealthRecordRepositoryIsar(IsarDatabase());
      const uuid = 'animal-health-del';

      final saved = await repo.addHealthRecord(
        uuid,
        HealthRecord(
          date: DateTime(2025, 3, 15),
          type: HealthRecordType.checkup,
          product: 'Revisión general',
        ),
      );

      await repo.deleteHealthRecord(saved.id!);
      final records = await repo.getHealthRecords(uuid);

      expect(records, isEmpty);
    }, skip: !_canRunIsarNative());
  });

  // ─── WeightRecord ─────────────────────────────────────────────────────────

  group('WeightRecordRepositoryIsar', () {
    test(
      'guarda y lee un registro de peso con todos sus campos',
      () async {
        final repo = WeightRecordRepositoryIsar(IsarDatabase());
        const uuid = 'animal-weight-1';

        final saved = await repo.addWeightRecord(
          uuid,
          WeightRecord(
            date: DateTime(2025, 4, 10),
            weight: 385.5,
            method: WeightMethod.scale,
            measuredBy: 'Juan Pérez',
            notes: 'Pesaje mensual',
          ),
        );

        expect(saved.id, isNotNull);

        final records = await repo.getWeightRecords(uuid);

        expect(records, hasLength(1));
        expect(records.first.weight, 385.5);
        expect(records.first.method, WeightMethod.scale);
        expect(records.first.measuredBy, 'Juan Pérez');
        expect(records.first.notes, 'Pesaje mensual');
      },
      skip: !_canRunIsarNative(),
    );

    test(
      'no retorna registros pertenecientes a otro animal',
      () async {
        final repo = WeightRecordRepositoryIsar(IsarDatabase());

        await repo.addWeightRecord(
          'animal-weight-X',
          WeightRecord(
            date: DateTime(2025, 4, 10),
            weight: 200.0,
            method: WeightMethod.estimated,
          ),
        );

        final records = await repo.getWeightRecords('animal-weight-Y');
        expect(records, isEmpty);
      },
      skip: !_canRunIsarNative(),
    );

    test('elimina el registro y deja la colección vacía', () async {
      final repo = WeightRecordRepositoryIsar(IsarDatabase());
      const uuid = 'animal-weight-del';

      final saved = await repo.addWeightRecord(
        uuid,
        WeightRecord(
          date: DateTime(2025, 4, 10),
          weight: 300.0,
          method: WeightMethod.scale,
        ),
      );

      await repo.deleteWeightRecord(saved.id!);
      final records = await repo.getWeightRecords(uuid);

      expect(records, isEmpty);
    }, skip: !_canRunIsarNative());
  });

  // ─── CostRecord ───────────────────────────────────────────────────────────

  group('CostRecordRepositoryIsar', () {
    test(
      'guarda y lee un registro de costo con todos sus campos',
      () async {
        final repo = CostRecordRepositoryIsar(IsarDatabase());
        const uuid = 'animal-cost-1';

        final saved = await repo.addCostRecord(
          uuid,
          CostRecord(
            date: DateTime(2025, 5, 1),
            type: CostType.medication,
            amount: 75.0,
            currency: 'USD',
            notes: 'Antibiótico preventivo',
          ),
        );

        expect(saved.id, isNotNull);

        final records = await repo.getCostRecords(uuid);

        expect(records, hasLength(1));
        expect(records.first.type, CostType.medication);
        expect(records.first.amount, 75.0);
        expect(records.first.currency, 'USD');
        expect(records.first.notes, 'Antibiótico preventivo');
      },
      skip: !_canRunIsarNative(),
    );

    test(
      'no retorna registros pertenecientes a otro animal',
      () async {
        final repo = CostRecordRepositoryIsar(IsarDatabase());

        await repo.addCostRecord(
          'animal-cost-X',
          CostRecord(
            date: DateTime(2025, 5, 1),
            type: CostType.feeding,
            amount: 50.0,
          ),
        );

        final records = await repo.getCostRecords('animal-cost-Y');
        expect(records, isEmpty);
      },
      skip: !_canRunIsarNative(),
    );

    test('elimina el registro y deja la colección vacía', () async {
      final repo = CostRecordRepositoryIsar(IsarDatabase());
      const uuid = 'animal-cost-del';

      final saved = await repo.addCostRecord(
        uuid,
        CostRecord(
          date: DateTime(2025, 5, 1),
          type: CostType.labor,
          amount: 100.0,
        ),
      );

      await repo.deleteCostRecord(saved.id!);
      final records = await repo.getCostRecords(uuid);

      expect(records, isEmpty);
    }, skip: !_canRunIsarNative());
  });

  // ─── MovementRecord ───────────────────────────────────────────────────────

  group('MovementRecordRepositoryIsar', () {
    test(
      'guarda y lee un registro de movimiento con todos sus campos',
      () async {
        final repo = MovementRecordRepositoryIsar(IsarDatabase());
        const uuid = 'animal-move-1';

        final saved = await repo.addMovementRecord(
          uuid,
          MovementRecord(
            date: DateTime(2025, 6, 20),
            fromLocation: 'Potrero Norte',
            toLocation: 'Potrero Sur',
            reason: MovementReason.paddockRotation,
            movedBy: 'Carlos',
            notes: 'Rotación programada',
          ),
        );

        expect(saved.id, isNotNull);

        final records = await repo.getMovementRecords(uuid);

        expect(records, hasLength(1));
        expect(records.first.fromLocation, 'Potrero Norte');
        expect(records.first.toLocation, 'Potrero Sur');
        expect(records.first.reason, MovementReason.paddockRotation);
        expect(records.first.movedBy, 'Carlos');
        expect(records.first.notes, 'Rotación programada');
      },
      skip: !_canRunIsarNative(),
    );

    test(
      'no retorna registros pertenecientes a otro animal',
      () async {
        final repo = MovementRecordRepositoryIsar(IsarDatabase());

        await repo.addMovementRecord(
          'animal-move-X',
          MovementRecord(
            date: DateTime(2025, 6, 20),
            toLocation: 'Corral',
            reason: MovementReason.quarantine,
          ),
        );

        final records = await repo.getMovementRecords('animal-move-Y');
        expect(records, isEmpty);
      },
      skip: !_canRunIsarNative(),
    );

    test('elimina el registro y deja la colección vacía', () async {
      final repo = MovementRecordRepositoryIsar(IsarDatabase());
      const uuid = 'animal-move-del';

      final saved = await repo.addMovementRecord(
        uuid,
        MovementRecord(
          date: DateTime(2025, 6, 20),
          toLocation: 'Bodega',
          reason: MovementReason.treatment,
        ),
      );

      await repo.deleteMovementRecord(saved.id!);
      final records = await repo.getMovementRecords(uuid);

      expect(records, isEmpty);
    }, skip: !_canRunIsarNative());
  });

  // ─── ProductionRecord ─────────────────────────────────────────────────────

  group('ProductionRecordRepositoryIsar', () {
    test(
      'guarda y lee un registro productivo con todos sus campos',
      () async {
        final repo = ProductionRecordRepositoryIsar(IsarDatabase());
        const uuid = 'animal-prod-1';

        final saved = await repo.addProductionRecord(
          uuid,
          ProductionRecord(
            date: DateTime(2025, 7, 1),
            type: ProductionRecordType.production,
            value: 18.5,
            unit: 'L',
            notes: 'Producción diaria de leche',
          ),
        );

        expect(saved.id, isNotNull);

        final records = await repo.getProductionRecords(uuid);

        expect(records, hasLength(1));
        expect(records.first.type, ProductionRecordType.production);
        expect(records.first.value, 18.5);
        expect(records.first.unit, 'L');
        expect(records.first.notes, 'Producción diaria de leche');
      },
      skip: !_canRunIsarNative(),
    );

    test(
      'no retorna registros pertenecientes a otro animal',
      () async {
        final repo = ProductionRecordRepositoryIsar(IsarDatabase());

        await repo.addProductionRecord(
          'animal-prod-X',
          ProductionRecord(
            date: DateTime(2025, 7, 1),
            type: ProductionRecordType.weighing,
            value: 400.0,
            unit: 'kg',
          ),
        );

        final records = await repo.getProductionRecords('animal-prod-Y');
        expect(records, isEmpty);
      },
      skip: !_canRunIsarNative(),
    );

    test('elimina el registro y deja la colección vacía', () async {
      final repo = ProductionRecordRepositoryIsar(IsarDatabase());
      const uuid = 'animal-prod-del';

      final saved = await repo.addProductionRecord(
        uuid,
        ProductionRecord(
          date: DateTime(2025, 7, 1),
          type: ProductionRecordType.weightGain,
          value: 1.2,
          unit: 'kg/día',
        ),
      );

      await repo.deleteProductionRecord(saved.id!);
      final records = await repo.getProductionRecords(uuid);

      expect(records, isEmpty);
    }, skip: !_canRunIsarNative());
  });

  // ─── ReproductionRecord ───────────────────────────────────────────────────

  group('ReproductionRecordRepositoryIsar', () {
    test(
      'guarda y lee un registro reproductivo con todos sus campos',
      () async {
        final repo = ReproductionRecordRepositoryIsar(IsarDatabase());
        const uuid = 'animal-repro-1';

        final saved = await repo.addReproductionRecord(
          uuid,
          ReproductionRecord(
            serviceDate: DateTime(2025, 2, 14),
            serviceType: ServiceType.artificialInsemination,
            maleSireIdentifier: 'TORO-SEMEN-42',
            servicedBy: 'Técnico García',
            notes: 'Primera inseminación del ciclo',
          ),
        );

        expect(saved.id, isNotNull);

        final records = await repo.getReproductionRecords(uuid);

        expect(records, hasLength(1));
        expect(records.first.serviceType, ServiceType.artificialInsemination);
        expect(records.first.maleSireIdentifier, 'TORO-SEMEN-42');
        expect(records.first.servicedBy, 'Técnico García');
        expect(records.first.notes, 'Primera inseminación del ciclo');
      },
      skip: !_canRunIsarNative(),
    );

    test(
      'no retorna registros pertenecientes a otro animal',
      () async {
        final repo = ReproductionRecordRepositoryIsar(IsarDatabase());

        await repo.addReproductionRecord(
          'animal-repro-X',
          ReproductionRecord(
            serviceDate: DateTime(2025, 2, 14),
            serviceType: ServiceType.naturalService,
          ),
        );

        final records = await repo.getReproductionRecords('animal-repro-Y');
        expect(records, isEmpty);
      },
      skip: !_canRunIsarNative(),
    );

    test('elimina el registro y deja la colección vacía', () async {
      final repo = ReproductionRecordRepositoryIsar(IsarDatabase());
      const uuid = 'animal-repro-del';

      final saved = await repo.addReproductionRecord(
        uuid,
        ReproductionRecord(
          serviceDate: DateTime(2025, 2, 14),
          serviceType: ServiceType.ivf,
        ),
      );

      await repo.deleteReproductionRecord(saved.id!);
      final records = await repo.getReproductionRecords(uuid);

      expect(records, isEmpty);
    }, skip: !_canRunIsarNative());
  });

  // ─── CommercialRecord ─────────────────────────────────────────────────────

  group('CommercialRecordRepositoryIsar', () {
    test(
      'guarda y lee un registro comercial con todos sus campos',
      () async {
        final repo = CommercialRecordRepositoryIsar(IsarDatabase());
        const uuid = 'animal-comm-1';

        final saved = await repo.addCommercialRecord(
          uuid,
          CommercialRecord(
            date: DateTime(2025, 8, 10),
            type: CommercialRecordType.sale,
            amount: 2500.0,
            currency: 'USD',
            counterparty: 'Comprador Martínez',
            notes: 'Venta en feria ganadera',
          ),
        );

        expect(saved.id, isNotNull);

        final records = await repo.getCommercialRecords(uuid);

        expect(records, hasLength(1));
        expect(records.first.type, CommercialRecordType.sale);
        expect(records.first.amount, 2500.0);
        expect(records.first.currency, 'USD');
        expect(records.first.counterparty, 'Comprador Martínez');
        expect(records.first.notes, 'Venta en feria ganadera');
      },
      skip: !_canRunIsarNative(),
    );

    test(
      'no retorna registros pertenecientes a otro animal',
      () async {
        final repo = CommercialRecordRepositoryIsar(IsarDatabase());

        await repo.addCommercialRecord(
          'animal-comm-X',
          CommercialRecord(
            date: DateTime(2025, 8, 10),
            type: CommercialRecordType.purchase,
            amount: 1000.0,
          ),
        );

        final records = await repo.getCommercialRecords('animal-comm-Y');
        expect(records, isEmpty);
      },
      skip: !_canRunIsarNative(),
    );

    test('elimina el registro y deja la colección vacía', () async {
      final repo = CommercialRecordRepositoryIsar(IsarDatabase());
      const uuid = 'animal-comm-del';

      final saved = await repo.addCommercialRecord(
        uuid,
        CommercialRecord(
          date: DateTime(2025, 8, 10),
          type: CommercialRecordType.ownershipChange,
          amount: 800.0,
        ),
      );

      await repo.deleteCommercialRecord(saved.id!);
      final records = await repo.getCommercialRecords(uuid);

      expect(records, isEmpty);
    }, skip: !_canRunIsarNative());
  });
}

bool _canRunIsarNative() {
  if (!Platform.isWindows) return true;
  final candidates = <File>[
    File('isar.dll'),
    File('${Directory.current.path}\\isar.dll'),
  ];
  return candidates.any((file) => file.existsSync());
}
