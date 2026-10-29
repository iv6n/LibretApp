import 'backup_models.dart';

class BackupValidator {
  static void validate(BackupEnvelope envelope) {
    if (envelope.schemaVersion < 5 ||
        envelope.schemaVersion > BackupEnvelope.currentSchemaVersion) {
      throw FormatException(
        'Versión de respaldo no compatible: ${envelope.schemaVersion}.',
      );
    }
    _finite(envelope.toJson());
    final tags = <String>{};
    for (final animal in envelope.collections['animals'] ?? <Map<String, dynamic>>[]) {
      final tag = (animal['earTagNumber'] as String? ?? '').trim().toLowerCase();
      if (tag.isNotEmpty && !tags.add(tag)) {
        throw const FormatException('La identificación ya pertenece a otro animal.');
      }
    }
    for (final entry in {'weightRecords': 'weight', 'incomeRecords': 'amount',
        'generalExpenseRecords': 'amount', 'costRecords': 'amount'}.entries) {
      for (final row in envelope.collections[entry.key] ?? <Map<String, dynamic>>[]) {
        final value = row[entry.value];
        if (value is! num || !value.isFinite || value <= 0) {
          throw FormatException('${entry.key} contiene un importe o peso inválido.');
        }
      }
    }
    final requiredCollections = <String>{
      'animals',
      'weightRecords',
      'reproductionRecords',
      'productionRecords',
      'healthRecords',
      'costRecords',
      'commercialRecords',
      'movementRecords',
      'lotes',
      'locations',
      'incomeRecords',
      'generalExpenseRecords',
      'milkingSessions',
      'milkingEntries',
      'agendaEntries',
      // Optional for backwards compatibility: backups from before traceable
      // Agenda registrations simply restore with an empty collection.
      'workerProfiles',
      'workTeams',
      'careRules',
      'careRecords',
      'scheduledCares',
    };
    final missing = requiredCollections.difference(
      envelope.collections.keys.toSet(),
    );
    if (envelope.schemaVersion >= 9 &&
        !envelope.collections.containsKey('cultivations')) {
      throw const FormatException(
        'Falta la colección cultivations en el respaldo.',
      );
    }
    if (missing.isNotEmpty) {
      throw FormatException(
        'Faltan colecciones en el respaldo: ${missing.join(', ')}.',
      );
    }
    const stableFields = <String, String>{
      'animals': 'uuid',
      'weightRecords': 'recordUuid',
      'reproductionRecords': 'recordUuid',
      'productionRecords': 'recordUuid',
      'healthRecords': 'recordUuid',
      'costRecords': 'recordUuid',
      'commercialRecords': 'recordUuid',
      'movementRecords': 'recordUuid',
      'lotes': 'uuid',
      'locations': 'uuid',
      'incomeRecords': 'recordUuid',
      'generalExpenseRecords': 'recordUuid',
      'milkingSessions': 'uuid',
      'milkingEntries': 'uuid',
      'agendaEntries': 'uuid',
      'workerProfiles': 'uuid',
      'workTeams': 'uuid',
      'careRules': 'recordUuid',
      'careRecords': 'recordUuid',
      'scheduledCares': 'recordUuid',
    };
    for (final entry in stableFields.entries) {
      _validateUniqueRows(
        envelope.collections[entry.key]!,
        collection: entry.key,
        field: entry.value,
      );
    }
    for (final name in ['weaningRecords', 'agendaRegistrations', 'featureRecords']) {
      final rows = envelope.collections[name];
      if (rows != null) _validateUniqueRows(rows, collection: name,
          field: name == 'weaningRecords' ? 'recordUuid' : 'uuid');
    }
    final cultivations = envelope.collections['cultivations'];
    if (cultivations != null) {
      _validateUniqueRows(
        cultivations,
        collection: 'cultivations',
        field: 'uuid',
      );
    }

    final animalIds = _stringValues(envelope.collections['animals']!, 'uuid');
    for (final name in const [
      'weightRecords',
      'reproductionRecords',
      'productionRecords',
      'healthRecords',
      'costRecords',
      'commercialRecords',
      'movementRecords',
      'careRecords',
      'scheduledCares',
    ]) {
      for (final row in envelope.collections[name]!) {
        final animalUuid = row['animalUuid'];
        if (animalUuid is! String || !animalIds.contains(animalUuid)) {
          throw FormatException(
            '$name contiene un registro sin animal válido.',
          );
        }
      }
    }
    final careRuleIds = _stringValues(
      envelope.collections['careRules']!,
      'recordUuid',
    );
    for (final name in const ['careRecords', 'scheduledCares']) {
      for (final row in envelope.collections[name]!) {
        final ruleId = row['ruleId'];
        if (ruleId is! String || !careRuleIds.contains(ruleId)) {
          throw FormatException('$name contiene un registro sin regla válida.');
        }
      }
    }
    final sessionIds = _stringValues(
      envelope.collections['milkingSessions']!,
      'uuid',
    );
    for (final row in envelope.collections['milkingEntries']!) {
      if (!sessionIds.contains(row['sessionUuid'])) {
        throw const FormatException(
          'Una entrada de ordeña no tiene una sesión válida.',
        );
      }
      if (!animalIds.contains(row['animalUuid'])) {
        throw const FormatException(
          'Una entrada de ordeña no tiene un animal válido.',
        );
      }
    }
    _validateLocationHierarchy(envelope.collections['locations']!);
  }

  static void _validateUniqueRows(
    List<Map<String, dynamic>> rows, {
    required String collection,
    required String field,
  }) {
    final seen = <String>{};
    for (final row in rows) {
      final value = row[field];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('$collection contiene $field vacío.');
      }
      if (!seen.add(value)) {
        throw FormatException('$collection contiene $field duplicado: $value.');
      }
    }
  }

  static Set<String> _stringValues(List<Map<String, dynamic>> rows, String field) =>
      rows.map((row) => row[field]).whereType<String>().toSet();

  static void _validateLocationHierarchy(List<Map<String, dynamic>> rows) {
    final parents = <String, String?>{
      for (final row in rows)
        if (row['uuid'] is String)
          row['uuid'] as String: row['parentUuid'] as String?,
    };
    for (final entry in parents.entries) {
      final parent = entry.value;
      if (parent != null && !parents.containsKey(parent)) {
        throw FormatException(
          'La ubicación ${entry.key} tiene un padre inexistente.',
        );
      }
      final visited = <String>{entry.key};
      var cursor = parent;
      while (cursor != null) {
        if (!visited.add(cursor)) {
          throw FormatException(
            'El respaldo contiene un ciclo de ubicaciones en ${entry.key}.',
          );
        }
        cursor = parents[cursor];
      }
    }
  }


  static void _finite(Object? value) {
    if (value is num && !value.isFinite) {
      throw const FormatException('El respaldo contiene un número no finito.');
    }
    if (value is Map) for (final child in value.values) { _finite(child); }
    if (value is List) for (final child in value) { _finite(child); }
  }
}
