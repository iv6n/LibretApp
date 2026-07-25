import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';

void main() {
  test('registro sanitario detecta un periodo de retiro vigente', () {
    final record = HealthRecord(
      date: DateTime.now(),
      type: HealthRecordType.treatment,
      product: 'Antibiótico',
      medicineBatch: 'L-2407',
      withdrawalDays: 15,
      withdrawalEndDate: DateTime.now().add(const Duration(days: 15)),
    );

    expect(record.isInWithdrawalPeriod, isTrue);
    expect(record.medicineBatch, 'L-2407');
  });

  test('inventario medicinal conserva datos regulatorios', () {
    final item = InventoryItem(
      name: 'Antibiótico',
      quantity: 10,
      unit: 'frasco',
      category: InventoryCategory.medicine,
      activeIngredient: 'Oxitetraciclina',
      batchNumber: 'L-2407',
      withdrawalDays: 28,
      unitCost: 350,
    );

    final updated = item.copyWith(quantity: 9);
    expect(updated.activeIngredient, 'Oxitetraciclina');
    expect(updated.batchNumber, 'L-2407');
    expect(updated.withdrawalDays, 28);
    expect(updated.unitCost, 350);
  });
}
