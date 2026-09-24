/// Double-entry accounting models. All monetary values are integer cents.
library;

enum LedgerEntryStatus { posted, reversed }

class LedgerAccount {
  const LedgerAccount({required this.uuid, required this.farmId, required this.code, required this.name, required this.type, this.parentCode, this.active = true});
  final String uuid;
  final String farmId;
  final String code;
  final String name;
  final String type;
  final String? parentCode;
  final bool active;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'code': code, 'name': name, 'type': type, 'parentCode': parentCode, 'active': active};
  factory LedgerAccount.fromJson(Map<String, dynamic> json) => LedgerAccount(uuid: json['uuid'] as String, farmId: json['farmId'] as String, code: json['code'] as String, name: json['name'] as String, type: json['type'] as String, parentCode: json['parentCode'] as String?, active: json['active'] as bool? ?? true);
}

class LedgerLine {
  const LedgerLine({required this.accountCode, this.debitCents = 0, this.creditCents = 0, this.description});
  final String accountCode;
  final int debitCents;
  final int creditCents;
  final String? description;
  Map<String, dynamic> toJson() => {'accountCode': accountCode, 'debitCents': debitCents, 'creditCents': creditCents, 'description': description};
  factory LedgerLine.fromJson(Map<String, dynamic> json) => LedgerLine(accountCode: json['accountCode'] as String, debitCents: (json['debitCents'] as num?)?.toInt() ?? 0, creditCents: (json['creditCents'] as num?)?.toInt() ?? 0, description: json['description'] as String?);
}

class JournalEntry {
  const JournalEntry({required this.uuid, required this.farmId, required this.date, required this.description, required this.lines, this.sourceUuid, this.status = LedgerEntryStatus.posted, this.reversalOf});
  final String uuid;
  final String farmId;
  final DateTime date;
  final String description;
  final List<LedgerLine> lines;
  final String? sourceUuid;
  final LedgerEntryStatus status;
  final String? reversalOf;
  int get debitsCents => lines.fold(0, (sum, line) => sum + line.debitCents);
  int get creditsCents => lines.fold(0, (sum, line) => sum + line.creditCents);
  bool get isBalanced => debitsCents == creditsCents && debitsCents >= 0;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'date': date.toUtc().toIso8601String(), 'description': description, 'lines': lines.map((l) => l.toJson()).toList(), 'sourceUuid': sourceUuid, 'status': status.name, 'reversalOf': reversalOf};
  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(uuid: json['uuid'] as String, farmId: json['farmId'] as String, date: DateTime.parse(json['date'] as String).toUtc(), description: json['description'] as String, lines: ((json['lines'] as List?) ?? const []).map((l) => LedgerLine.fromJson(Map<String, dynamic>.from(l as Map))).toList(), sourceUuid: json['sourceUuid'] as String?, status: LedgerEntryStatus.values.byName(json['status'] as String? ?? 'posted'), reversalOf: json['reversalOf'] as String?);
}

class AccountingException implements Exception {
  const AccountingException(this.message);
  final String message;
  @override
  String toString() => message;
}
