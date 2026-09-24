// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_feature_database.dart';

// ignore_for_file: type=lint

class $DriftFeatureRecordsTable extends DriftFeatureRecords
    with TableInfo<$DriftFeatureRecordsTable, DriftFeatureRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;

  $DriftFeatureRecordsTable(this.attachedDatabase, [this._alias]);

  static const VerificationMeta _uuidMeta = VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _farmIdMeta = VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _kindMeta = VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _payloadJsonMeta = VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _createdAtMeta = VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _updatedAtMeta = VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _deletedAtMeta = VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );

  static const VerificationMeta _revisionMeta = VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );

  static const VerificationMeta _syncedMeta = VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultValue: const Constant(false),
  );

  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    farmId,
    kind,
    payloadJson,
    createdAt,
    updatedAt,
    deletedAt,
    revision,
    synced,
  ];

  @override
  String get aliasedName => _alias ?? actualTableName;

  @override
  String get actualTableName => $name;

  static const String $name = 'drift_feature_records';

  @override
  VerificationContext validateIntegrity(
    Insertable<DriftFeatureRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};

  @override
  DriftFeatureRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftFeatureRecord(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $DriftFeatureRecordsTable createAlias(String alias) {
    return $DriftFeatureRecordsTable(attachedDatabase, alias);
  }
}

class DriftFeatureRecord extends DataClass
    implements Insertable<DriftFeatureRecord> {
  final String uuid;
  final String farmId;
  final String kind;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int revision;
  final bool synced;

  const DriftFeatureRecord({
    required this.uuid,
    required this.farmId,
    required this.kind,
    required this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.revision,
    required this.synced,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{
      'uuid': Variable<String>(uuid),
      'farm_id': Variable<String>(farmId),
      'kind': Variable<String>(kind),
      'payload_json': Variable<String>(payloadJson),
      'created_at': Variable<DateTime>(createdAt),
      'updated_at': Variable<DateTime>(updatedAt),
      'revision': Variable<int>(revision),
      'synced': Variable<bool>(synced),
    };
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DriftFeatureRecordsCompanion toCompanion(bool nullToAbsent) {
    return DriftFeatureRecordsCompanion(
      uuid: Value(uuid),
      farmId: Value(farmId),
      kind: Value(kind),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
      synced: Value(synced),
    );
  }

  factory DriftFeatureRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftFeatureRecord(
      uuid: serializer.fromJson<String>(json['uuid']),
      farmId: serializer.fromJson<String>(json['farmId']),
      kind: serializer.fromJson<String>(json['kind']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }

  factory DriftFeatureRecord.fromJsonString(
    String encodedJson, {
    ValueSerializer? serializer,
  }) => DriftFeatureRecord.fromJson(
    DataClass.parseJson(encodedJson) as Map<String, dynamic>,
    serializer: serializer,
  );

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'farmId': serializer.toJson<String>(farmId),
      'kind': serializer.toJson<String>(kind),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  DriftFeatureRecord copyWith({
    String? uuid,
    String? farmId,
    String? kind,
    String? payloadJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? revision,
    bool? synced,
  }) => DriftFeatureRecord(
    uuid: uuid ?? this.uuid,
    farmId: farmId ?? this.farmId,
    kind: kind ?? this.kind,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
    synced: synced ?? this.synced,
  );

  DriftFeatureRecord copyWithCompanion(DriftFeatureRecordsCompanion data) {
    return DriftFeatureRecord(
      uuid: data.uuid.present ? data.uuid.value : uuid,
      farmId: data.farmId.present ? data.farmId.value : farmId,
      kind: data.kind.present ? data.kind.value : kind,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : deletedAt,
      revision: data.revision.present ? data.revision.value : revision,
      synced: data.synced.present ? data.synced.value : synced,
    );
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    farmId,
    kind,
    payloadJson,
    createdAt,
    updatedAt,
    deletedAt,
    revision,
    synced,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftFeatureRecord &&
          other.uuid == uuid &&
          other.farmId == farmId &&
          other.kind == kind &&
          other.payloadJson == payloadJson &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt &&
          other.deletedAt == deletedAt &&
          other.revision == revision &&
          other.synced == synced);
}

class DriftFeatureRecordsCompanion extends UpdateCompanion<DriftFeatureRecord> {
  final Value<String> uuid;
  final Value<String> farmId;
  final Value<String> kind;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> revision;
  final Value<bool> synced;

  const DriftFeatureRecordsCompanion({
    this.uuid = const Value.absent(),
    this.farmId = const Value.absent(),
    this.kind = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.synced = const Value.absent(),
  });

  DriftFeatureRecordsCompanion.insert({
    required String uuid,
    required String farmId,
    required String kind,
    required String payloadJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.synced = const Value.absent(),
  }) : uuid = Value(uuid),
       farmId = Value(farmId),
       kind = Value(kind),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) map['uuid'] = Variable<String>(uuid.value);
    if (farmId.present) map['farm_id'] = Variable<String>(farmId.value);
    if (kind.present) map['kind'] = Variable<String>(kind.value);
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (revision.present) map['revision'] = Variable<int>(revision.value);
    if (synced.present) map['synced'] = Variable<bool>(synced.value);
    return map;
  }
}

abstract class _$DriftFeatureDatabase extends GeneratedDatabase {
  _$DriftFeatureDatabase(QueryExecutor e) : super(e);

  late final $DriftFeatureRecordsTable driftFeatureRecords =
      $DriftFeatureRecordsTable(this);

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [driftFeatureRecords];
}
