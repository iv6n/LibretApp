import 'dart:convert';
import 'package:isar_community/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'isar_farm_profile.dart';
import 'perfil_model.dart';
import 'perfil_repository.dart';
import 'perfil_shared_prefs_repository.dart';

class PerfilIsarRepository implements PerfilRepository {
  PerfilIsarRepository(this.database, this.preferences);
  final IsarDatabase database;
  final SharedPrefsService preferences;

  /// The original preference is intentionally retained. The Isar row itself is
  /// the migration marker, so interruption never marks a missing row migrated.
  Future<void> migrate() async {
    final db = await database.initialize();
    if (await db.isarFarmProfiles.get(1) != null) return;
    final old = await PerfilSharedPrefsRepository(preferences).fetchPerfil();
    await db.writeTxn(() async {
      if (await db.isarFarmProfiles.get(1) == null) {
        await writeWithinTransaction(db, old);
      }
    });
  }

  static Future<Perfil> readWithinTransaction(Isar db) async {
    final row = await db.isarFarmProfiles.get(1);
    return Perfil.fromJson(row == null ? {} :
        Map<String, dynamic>.from(jsonDecode(row.payloadJson) as Map));
  }

  static Future<void> writeWithinTransaction(Isar db, Perfil value) async {
    await db.isarFarmProfiles.put(IsarFarmProfile()
      ..payloadJson = jsonEncode(value.toJson()));
  }

  @override
  Future<Perfil> fetchPerfil() async {
    await migrate();
    return readWithinTransaction(database.isar);
  }

  @override
  Future<void> savePerfil(Perfil perfil) async {
    final db = await database.initialize();
    await db.writeTxn(() => writeWithinTransaction(db, perfil));
  }

  @override
  Future<void> updatePerfil(Perfil perfil) => savePerfil(perfil);
}
