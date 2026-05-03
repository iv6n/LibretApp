import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_commercial_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_cost_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_health_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_movement_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_production_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_weight_record.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/isar/isar_lote.dart';
import 'package:libretapp/features/finanzas/infrastructure/isar/isar_general_expense_record.dart';
import 'package:libretapp/features/finanzas/infrastructure/isar/isar_income_record.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/isar/isar_location.dart';

class IsarDatabase {
  factory IsarDatabase() => _instance;

  IsarDatabase._internal();
  static final IsarDatabase _instance = IsarDatabase._internal();

  Isar? _isar;

  Future<Isar> initialize() async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    final dir = await getApplicationSupportDirectory();
    LoggerService.i('Abriendo Isar en ${dir.path}', tag: 'IsarDatabase');

    _isar = await Isar.open(
      [
        IsarAnimalSchema,
        IsarWeightRecordSchema,
        IsarReproductionRecordSchema,
        IsarProductionRecordSchema,
        IsarHealthRecordSchema,
        IsarCostRecordSchema,
        IsarCommercialRecordSchema,
        IsarMovementRecordSchema,
        IsarLoteSchema,
        IsarLocationSchema,
        IsarIncomeRecordSchema,
        IsarGeneralExpenseRecordSchema,
      ],
      directory: dir.path,
      inspector: kDebugMode,
      name: 'libretapp_db',
    );

    return _isar!;
  }

  Isar get isar {
    final instance = _isar;
    if (instance == null || !instance.isOpen) {
      throw StateError('Isar no inicializado. Llama initialize() primero.');
    }
    return instance;
  }

  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
      LoggerService.i('Isar cerrado', tag: 'IsarDatabase');
    }
  }

  Future<void> clearAllCollections() async {
    final db = isar;
    await db.writeTxn(() async {
      await db.isarAnimals.clear();
      await db.isarWeightRecords.clear();
      await db.isarReproductionRecords.clear();
      await db.isarProductionRecords.clear();
      await db.isarHealthRecords.clear();
      await db.isarCostRecords.clear();
      await db.isarCommercialRecords.clear();
      await db.isarMovementRecords.clear();
      await db.isarLotes.clear();
      await db.isarLocations.clear();
      await db.isarIncomeRecords.clear();
      await db.isarGeneralExpenseRecords.clear();
    });
    LoggerService.w(
      'Todas las colecciones Isar fueron limpiadas',
      tag: 'IsarDatabase',
    );
  }
}
