library;

import 'package:libretapp/core/persistence/json_feature_repository.dart';
import 'payroll_models.dart';
import 'package:uuid/uuid.dart';

class PayrollService {
  PayrollService({required JsonFeatureRepository<AttendanceRecord> attendance, required JsonFeatureRepository<PayrollIncident> incidents, required JsonFeatureRepository<PayrollReceipt> receipts}) : _attendance = attendance, _incidents = incidents, _receipts = receipts;
  final JsonFeatureRepository<AttendanceRecord> _attendance;
  final JsonFeatureRepository<PayrollIncident> _incidents;
  final JsonFeatureRepository<PayrollReceipt> _receipts;
  Future<AttendanceRecord> recordAttendance(AttendanceRecord value) => _attendance.save(farmId: value.farmId, value: value, uuid: value.uuid);
  Future<PayrollIncident> recordIncident(PayrollIncident value) => _incidents.save(farmId: value.farmId, value: value, uuid: value.uuid);
  Future<List<AttendanceRecord>> attendance(String farmId, String workerId) async => (await _attendance.list(farmId)).where((r) => r.workerId == workerId).toList(growable: false);
  Future<PayrollReceipt> calculateReceipt({required String farmId, required String workerId, required String periodId, required int baseCents, required int workedDays, required int deductionsCents, String? uuid}) async {
    final gross = baseCents * workedDays;
    final receipt = PayrollReceipt(uuid: uuid ?? const Uuid().v4(), farmId: farmId, workerId: workerId, periodId: periodId, grossCents: gross, deductionsCents: deductionsCents.clamp(0, gross), netCents: gross - deductionsCents.clamp(0, gross));
    return _receipts.save(farmId: farmId, value: receipt, uuid: receipt.uuid);
  }
}
