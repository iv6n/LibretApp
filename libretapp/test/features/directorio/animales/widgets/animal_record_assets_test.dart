import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_record_assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('maps health record types to specific approved assets', () {
    expect(
      assetForHealthRecordType(HealthRecordType.vaccine),
      'assets/images/health_vaccine.webp',
    );
    expect(
      assetForHealthRecordType(HealthRecordType.treatment),
      'assets/images/health_treatment.webp',
    );
    expect(
      assetForHealthRecordType(HealthRecordType.disease),
      'assets/images/health_diagnosis.webp',
    );
    expect(assetForHealthRecordType(HealthRecordType.other), isNull);
  });

  test('maps production record types to specific approved assets', () {
    expect(
      assetForProductionRecordType(ProductionRecordType.weighing),
      'assets/images/health_weight.webp',
    );
    expect(
      assetForProductionRecordType(ProductionRecordType.bodyConditionScore),
      'assets/images/health_body_condition.webp',
    );
    expect(
      assetForProductionRecordType(ProductionRecordType.production),
      'assets/images/health_milk_production.webp',
    );
    expect(
      assetForProductionRecordType(ProductionRecordType.fatteningStart),
      isNull,
    );
  });

  test('all T18 assets are bundled', () async {
    const assets = [
      'assets/images/health_vaccine.webp',
      'assets/images/health_treatment.webp',
      'assets/images/health_diagnosis.webp',
      'assets/images/health_weight.webp',
      'assets/images/health_body_condition.webp',
      'assets/images/health_birth.webp',
      'assets/images/health_reproduction.webp',
      'assets/images/health_milk_production.webp',
    ];

    for (final asset in assets) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(0), reason: asset);
    }
  });
}
