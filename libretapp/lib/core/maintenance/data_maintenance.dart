import 'dart:typed_data';

enum MaintenanceIssueKind {
  duplicate,
  invalidNumber,
  orphan,
  monitoring,
  invalidTransfer,
}

class MaintenanceIssue {
  const MaintenanceIssue({
    required this.id,
    required this.collection,
    required this.rowId,
    required this.kind,
    required this.title,
    required this.detail,
    this.canDelete = false,
    this.numberField,
    this.animalUuid,
    this.manualObservation = false,
    this.manualVaccinated = false,
    this.manualDewormed = false,
    this.manualHasVitamins = false,
    this.manualAttention = false,
  });
  final String id;
  final String collection;
  final int rowId;
  final MaintenanceIssueKind kind;
  final String title;
  final String detail;
  final bool canDelete;
  final String? numberField;
  final String? animalUuid;
  final bool manualObservation;
  final bool manualVaccinated;
  final bool manualDewormed;
  final bool manualHasVitamins;
  final bool manualAttention;
}

class MaintenanceReview {
  const MaintenanceReview(this.fingerprint, this.issues);
  final String fingerprint;
  final List<MaintenanceIssue> issues;
}

class MaintenanceChange {
  const MaintenanceChange(
    this.issueId, {
    this.delete = false,
    this.number,
    this.manualObservation,
    this.manualVaccinated,
    this.manualDewormed,
    this.manualHasVitamins,
    this.manualAttention,
  });
  final String issueId;
  final bool delete;
  final double? number;
  final bool? manualObservation;
  final bool? manualVaccinated;
  final bool? manualDewormed;
  final bool? manualHasVitamins;
  final bool? manualAttention;
}

class RecoverySnapshot {
  const RecoverySnapshot({
    required this.id,
    required this.createdAt,
    required this.native,
  });
  final String id;
  final DateTime createdAt;
  final bool native;
}

typedef MaintenanceReopener =
    Future<void> Function(Future<void> Function() action);

abstract interface class DataMaintenance {
  Future<MaintenanceReview> scan();
  Future<String> apply(
    MaintenanceReview review,
    List<MaintenanceChange> changes,
  );
  Future<List<RecoverySnapshot>> snapshots();
  Future<String> createSnapshot();
  Future<Uint8List> exportSnapshot(String id);
  Future<String?> saveSnapshot(String id);
  Future<bool> importSnapshot();
  Future<void> restoreSnapshot(
    String id, {
    required MaintenanceReopener reopen,
  });
}
