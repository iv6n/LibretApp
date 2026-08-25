import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';

void main() {
  group('CropGrowthStageX.assetPath', () {
    test('maps every growth stage to its generated crop asset', () {
      expect(CropGrowthStage.planted.assetPath, 'assets/images/crop_field.webp');
      expect(
        CropGrowthStage.germinating.assetPath,
        'assets/images/crop_germinating.webp',
      );
      expect(
        CropGrowthStage.vegetative.assetPath,
        'assets/images/crop_vegetative.webp',
      );
      expect(
        CropGrowthStage.flowering.assetPath,
        'assets/images/crop_flowering.webp',
      );
      expect(
        CropGrowthStage.fruiting.assetPath,
        'assets/images/crop_fruiting.webp',
      );
      expect(
        CropGrowthStage.readyToHarvest.assetPath,
        'assets/images/crop_ready_to_harvest.webp',
      );
      expect(
        CropGrowthStage.harvested.assetPath,
        'assets/images/crop_harvested.webp',
      );
    });
  });

  group('CropRecord.assetPath', () {
    final plantingDate = DateTime(2026, 1, 1);

    test('prioritizes the failed status asset', () {
      final crop = CropRecord(
        cropName: 'Maiz',
        plantingDate: plantingDate,
        status: CropStatus.failed,
        growthStage: CropGrowthStage.vegetative,
      );

      expect(crop.assetPath, 'assets/images/crop_failed.webp');
    });

    test('prioritizes the harvested status asset', () {
      final crop = CropRecord(
        cropName: 'Maiz',
        plantingDate: plantingDate,
        status: CropStatus.harvested,
        growthStage: CropGrowthStage.readyToHarvest,
      );

      expect(crop.assetPath, 'assets/images/crop_harvested.webp');
    });
  });
}
