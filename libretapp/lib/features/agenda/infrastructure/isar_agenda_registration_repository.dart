library;

import 'package:isar_community/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/agenda/data/agenda_registration_repository.dart';
import 'package:libretapp/features/agenda/domain/agenda_registration.dart';
import 'package:libretapp/features/agenda/infrastructure/isar/isar_agenda_registration.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_activity_tracker.dart';

class IsarAgendaRegistrationRepository implements AgendaRegistrationRepository {
  IsarAgendaRegistrationRepository(this._database);

  final IsarDatabase _database;

  Future<Isar> get _isar => _database.initialize();

  @override
  Future<List<AgendaRegistration>> fetchAll() async {
    final isar = await _isar;
    final values = await isar.isarAgendaRegistrations
        .where()
        .sortByUpdatedAtDesc()
        .findAll();
    return values.map((value) => value.toEntity()).toList(growable: false);
  }

  @override
  Future<List<AgendaRegistration>> fetchForEntries(Set<String> entryIds) async {
    if (entryIds.isEmpty) return const [];
    final isar = await _isar;
    final values = await isar.isarAgendaRegistrations
        .filter()
        .anyOf(entryIds, (q, id) => q.entryIdEqualTo(id))
        .sortByUpdatedAtDesc()
        .findAll();
    return values.map((value) => value.toEntity()).toList(growable: false);
  }

  @override
  Future<AgendaRegistration?> getById(String id) async {
    final isar = await _isar;
    final value = await isar.isarAgendaRegistrations
        .where()
        .uuidEqualTo(id)
        .findFirst();
    return value?.toEntity();
  }

  @override
  Future<AgendaRegistration?> getForRow(
    String entryId,
    String? animalId,
  ) async {
    final isar = await _isar;
    final values = await isar.isarAgendaRegistrations
        .where()
        .entryIdEqualTo(entryId)
        .filter()
        .optional(animalId == null, (q) => q.animalIdIsNull())
        .optional(animalId != null, (q) => q.animalIdEqualTo(animalId))
        .sortByUpdatedAtDesc()
        .findAll();
    return values.isEmpty ? null : values.first.toEntity();
  }

  @override
  Future<void> save(AgendaRegistration registration) async {
    final isar = await _isar;
    final model = registration.toIsar();
    await isar.writeTxn(() async {
      final existing = await isar.isarAgendaRegistrations
          .where()
          .uuidEqualTo(registration.id)
          .findFirst();
      if (existing != null) model.isarId = existing.isarId;
      await isar.isarAgendaRegistrations.put(model);

      final animalUuid = registration.animalId?.trim();
      if (animalUuid == null || animalUuid.isEmpty) return;
      await AnimalActivityTracker.touch(isar, animalUuid, DateTime.now());
    });
  }

  @override
  Future<void> deleteForEntry(String entryId) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      final registrations = await isar.isarAgendaRegistrations
          .where()
          .entryIdEqualTo(entryId)
          .findAll();
      await isar.isarAgendaRegistrations
          .where()
          .entryIdEqualTo(entryId)
          .deleteAll();
      for (final animalUuid
          in registrations
              .map((registration) => registration.animalId)
              .whereType<String>()
              .where((uuid) => uuid.trim().isNotEmpty)
              .toSet()) {
        await AnimalActivityTracker.recalculate(isar, animalUuid);
      }
    });
  }

  @override
  Future<void> clearAll() async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      final registrations = await isar.isarAgendaRegistrations
          .where()
          .findAll();
      await isar.isarAgendaRegistrations.clear();
      for (final animalUuid
          in registrations
              .map((registration) => registration.animalId)
              .whereType<String>()
              .where((uuid) => uuid.trim().isNotEmpty)
              .toSet()) {
        await AnimalActivityTracker.recalculate(isar, animalUuid);
      }
    });
  }
}
