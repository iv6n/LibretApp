library;

import 'package:libretapp/core/persistence/json_feature_repository.dart';
import 'package:libretapp/features/finanzas/contabilidad/ledger_models.dart';
import 'package:uuid/uuid.dart';

class LedgerService {
  LedgerService({required JsonFeatureRepository<LedgerAccount> accounts, required JsonFeatureRepository<JournalEntry> entries}) : _accounts = accounts, _entries = entries;
  final JsonFeatureRepository<LedgerAccount> _accounts;
  final JsonFeatureRepository<JournalEntry> _entries;

  Future<List<LedgerAccount>> accounts(String farmId) => _accounts.list(farmId);
  Future<List<JournalEntry>> entries(String farmId) => _entries.list(farmId);

  Future<JournalEntry> post(JournalEntry entry) async {
    if (!entry.isBalanced) throw const AccountingException('El asiento debe cuadrar: cargos y abonos deben ser iguales.');
    if (entry.lines.any((line) => line.debitCents < 0 || line.creditCents < 0 || (line.debitCents > 0 && line.creditCents > 0))) throw const AccountingException('Cada línea debe ser cargo o abono, no ambos.');
    final current = await _entries.get(entry.farmId, entry.uuid);
    if (current != null) return current;
    final source = entry.sourceUuid;
    if (source != null) {
      final existing = (await _entries.list(entry.farmId)).where((e) => e.sourceUuid == source && e.status == LedgerEntryStatus.posted).firstOrNull;
      if (existing != null) return existing;
    }
    return _entries.save(farmId: entry.farmId, value: entry, uuid: entry.uuid);
  }

  Future<JournalEntry> reverse(JournalEntry original, {String? reason}) async {
    if (original.status == LedgerEntryStatus.reversed) return original;
    final reversal = JournalEntry(
      uuid: const Uuid().v4(), farmId: original.farmId, date: DateTime.now().toUtc(),
      description: 'Reverso de ${original.description}${reason == null ? '' : ': $reason'}',
      sourceUuid: 'reversal:${original.uuid}', reversalOf: original.uuid,
      lines: original.lines.map((line) => LedgerLine(accountCode: line.accountCode, debitCents: line.creditCents, creditCents: line.debitCents, description: line.description)).toList(),
    );
    await post(reversal);
    final closed = JournalEntry(uuid: original.uuid, farmId: original.farmId, date: original.date, description: original.description, lines: original.lines, sourceUuid: original.sourceUuid, status: LedgerEntryStatus.reversed, reversalOf: original.reversalOf);
    await _entries.save(farmId: original.farmId, value: closed, uuid: original.uuid);
    return closed;
  }

  Future<Map<String, int>> trialBalance(String farmId) async {
    final totals = <String, int>{};
    for (final entry in await entries(farmId)) {
      if (entry.status != LedgerEntryStatus.posted) continue;
      for (final line in entry.lines) totals.update(line.accountCode, (v) => v + line.debitCents - line.creditCents, ifAbsent: () => line.debitCents - line.creditCents);
    }
    return totals;
  }
}
