import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';

enum BatchRecordKind {
  weight('Pesaje'),
  health('Sanidad'),
  movement('Movimiento');

  const BatchRecordKind(this.label);
  final String label;
}

class BatchParticipant {
  const BatchParticipant({
    required this.uuid,
    required this.tag,
    this.name,
    this.locationId,
  });
  final String uuid;
  final String tag;
  final String? name;
  final String? locationId;
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'tag': tag,
    'name': name,
    'locationId': locationId,
  };
  factory BatchParticipant.fromJson(Map<String, dynamic> json) =>
      BatchParticipant(
        uuid: json['uuid'] as String,
        tag: json['tag'] as String,
        name: json['name'] as String?,
        locationId: json['locationId'] as String?,
      );
}

/// The participant snapshot stays fixed when the lot's membership changes.
/// Raw inputs are retained even before they are valid enough to confirm.
class BatchRecordSession {
  const BatchRecordSession({
    required this.uuid,
    required this.farmId,
    required this.lotUuid,
    required this.lotName,
    required this.kind,
    required this.date,
    required this.createdAt,
    required this.participants,
    this.version = 0,
    this.weights = const {},
    this.skipped = const {},
    this.healthType = HealthRecordType.vaccine,
    this.product = '',
    this.dose = '',
    this.responsible = '',
    this.notes = '',
    this.medicineBatch = '',
    this.withdrawalDays = '',
    this.nextDueDate,
    this.destinationId,
    this.reason = MovementReason.paddockRotation,
    this.completedAt,
    this.savedCount = 0,
  });
  final String uuid;
  final String farmId;
  final String lotUuid;
  final String lotName;
  final BatchRecordKind kind;
  final DateTime date;
  final DateTime createdAt;
  final List<BatchParticipant> participants;
  final int version;
  final Map<String, String> weights;
  final Set<String> skipped;
  final HealthRecordType healthType;
  final String product;
  final String dose;
  final String responsible;
  final String notes;
  final String medicineBatch;
  final String withdrawalDays;
  final DateTime? nextDueDate;
  final String? destinationId;
  final MovementReason reason;
  final DateTime? completedAt;
  final int savedCount;
  bool get isCompleted => completedAt != null;
  List<BatchParticipant> get included => participants
      .where(
        (p) =>
            !skipped.contains(p.uuid) &&
            (kind != BatchRecordKind.weight ||
                weights[p.uuid]?.trim().isNotEmpty == true),
      )
      .toList(growable: false);

  BatchRecordSession copyWith({
    DateTime? date,
    int? version,
    Map<String, String>? weights,
    Set<String>? skipped,
    HealthRecordType? healthType,
    String? product,
    String? dose,
    String? responsible,
    String? notes,
    String? medicineBatch,
    String? withdrawalDays,
    DateTime? nextDueDate,
    bool clearNextDueDate = false,
    String? destinationId,
    MovementReason? reason,
    DateTime? completedAt,
    int? savedCount,
  }) => BatchRecordSession(
    uuid: uuid,
    farmId: farmId,
    lotUuid: lotUuid,
    lotName: lotName,
    kind: kind,
    date: date ?? this.date,
    createdAt: createdAt,
    participants: participants,
    version: version ?? this.version,
    weights: Map.unmodifiable(weights ?? this.weights),
    skipped: Set.unmodifiable(skipped ?? this.skipped),
    healthType: healthType ?? this.healthType,
    product: product ?? this.product,
    dose: dose ?? this.dose,
    responsible: responsible ?? this.responsible,
    notes: notes ?? this.notes,
    medicineBatch: medicineBatch ?? this.medicineBatch,
    withdrawalDays: withdrawalDays ?? this.withdrawalDays,
    nextDueDate: clearNextDueDate ? null : nextDueDate ?? this.nextDueDate,
    destinationId: destinationId ?? this.destinationId,
    reason: reason ?? this.reason,
    completedAt: completedAt ?? this.completedAt,
    savedCount: savedCount ?? this.savedCount,
  );

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'farmId': farmId,
    'lotUuid': lotUuid,
    'lotName': lotName,
    'kind': kind.name,
    'date': date.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'participants': participants.map((p) => p.toJson()).toList(),
    'version': version,
    'weights': weights,
    'skipped': skipped.toList(),
    'healthType': healthType.name,
    'product': product,
    'dose': dose,
    'responsible': responsible,
    'notes': notes,
    'medicineBatch': medicineBatch,
    'withdrawalDays': withdrawalDays,
    'nextDueDate': nextDueDate?.toIso8601String(),
    'destinationId': destinationId,
    'reason': reason.name,
    'completedAt': completedAt?.toIso8601String(),
    'savedCount': savedCount,
  };

  factory BatchRecordSession.fromJson(Map<String, dynamic> json) =>
      BatchRecordSession(
        uuid: json['uuid'] as String,
        farmId: json['farmId'] as String,
        lotUuid: json['lotUuid'] as String,
        lotName: json['lotName'] as String,
        kind: BatchRecordKind.values.byName(json['kind'] as String),
        date: DateTime.parse(json['date'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        participants: (json['participants'] as List)
            .map(
              (p) => BatchParticipant.fromJson(
                Map<String, dynamic>.from(p as Map),
              ),
            )
            .toList(growable: false),
        version: (json['version'] as num?)?.toInt() ?? 0,
        weights: Map<String, String>.from(json['weights'] as Map? ?? const {}),
        skipped: Set<String>.from(json['skipped'] as List? ?? const []),
        healthType: HealthRecordType.values.byName(
          json['healthType'] as String? ?? 'vaccine',
        ),
        product: json['product'] as String? ?? '',
        dose: json['dose'] as String? ?? '',
        responsible: json['responsible'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        medicineBatch: json['medicineBatch'] as String? ?? '',
        withdrawalDays: json['withdrawalDays'] as String? ?? '',
        nextDueDate: json['nextDueDate'] == null
            ? null
            : DateTime.parse(json['nextDueDate'] as String),
        destinationId: json['destinationId'] as String?,
        reason: MovementReason.values.byName(
          json['reason'] as String? ?? 'paddockRotation',
        ),
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
        savedCount: (json['savedCount'] as num?)?.toInt() ?? 0,
      );
}
