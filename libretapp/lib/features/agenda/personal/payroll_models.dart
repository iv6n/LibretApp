/// Workforce attendance and payroll records.
library;

enum PayrollIncidentType { absence, overtime, advance, bonus, deduction }

class AttendanceRecord {
  const AttendanceRecord({required this.uuid, required this.farmId, required this.workerId, required this.date, this.hours = 0, this.present = true, this.notes});
  final String uuid;
  final String farmId;
  final String workerId;
  final DateTime date;
  final double hours;
  final bool present;
  final String? notes;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'workerId': workerId, 'date': date.toUtc().toIso8601String(), 'hours': hours, 'present': present, 'notes': notes};
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(uuid: json['uuid'] as String, farmId: json['farmId'] as String, workerId: json['workerId'] as String, date: DateTime.parse(json['date'] as String).toUtc(), hours: (json['hours'] as num?)?.toDouble() ?? 0, present: json['present'] as bool? ?? true, notes: json['notes'] as String?);
}

class PayrollIncident {
  const PayrollIncident({required this.uuid, required this.farmId, required this.workerId, required this.periodId, required this.type, required this.amountCents, this.notes});
  final String uuid;
  final String farmId;
  final String workerId;
  final String periodId;
  final PayrollIncidentType type;
  final int amountCents;
  final String? notes;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'workerId': workerId, 'periodId': periodId, 'type': type.name, 'amountCents': amountCents, 'notes': notes};
  factory PayrollIncident.fromJson(Map<String, dynamic> json) => PayrollIncident(uuid: json['uuid'] as String, farmId: json['farmId'] as String, workerId: json['workerId'] as String, periodId: json['periodId'] as String, type: PayrollIncidentType.values.byName(json['type'] as String), amountCents: (json['amountCents'] as num).toInt(), notes: json['notes'] as String?);
}

class PayrollReceipt {
  const PayrollReceipt({required this.uuid, required this.farmId, required this.workerId, required this.periodId, required this.grossCents, required this.deductionsCents, required this.netCents, this.paidAt, this.fiscalDocumentUuid});
  final String uuid;
  final String farmId;
  final String workerId;
  final String periodId;
  final int grossCents;
  final int deductionsCents;
  final int netCents;
  final DateTime? paidAt;
  final String? fiscalDocumentUuid;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'workerId': workerId, 'periodId': periodId, 'grossCents': grossCents, 'deductionsCents': deductionsCents, 'netCents': netCents, 'paidAt': paidAt?.toUtc().toIso8601String(), 'fiscalDocumentUuid': fiscalDocumentUuid};
  factory PayrollReceipt.fromJson(Map<String, dynamic> json) => PayrollReceipt(uuid: json['uuid'] as String, farmId: json['farmId'] as String, workerId: json['workerId'] as String, periodId: json['periodId'] as String, grossCents: (json['grossCents'] as num).toInt(), deductionsCents: (json['deductionsCents'] as num).toInt(), netCents: (json['netCents'] as num).toInt(), paidAt: (json['paidAt'] as String?) == null ? null : DateTime.parse(json['paidAt'] as String).toUtc(), fiscalDocumentUuid: json['fiscalDocumentUuid'] as String?);
}
