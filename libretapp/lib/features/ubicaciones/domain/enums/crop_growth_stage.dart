/// features \u203a ubicaciones \u203a domain \u203a enums \u203a crop_growth_stage \u2014 enum for crop growth stages.
library;

import 'package:libretapp/core/assets/app_asset_paths.dart';

enum CropGrowthStage {
  planted,
  germinating,
  vegetative,
  flowering,
  fruiting,
  readyToHarvest,
  harvested,
}

extension CropGrowthStageX on CropGrowthStage {
  String get displayName {
    switch (this) {
      case CropGrowthStage.planted:
        return 'Sembrado';
      case CropGrowthStage.germinating:
        return 'Germinando';
      case CropGrowthStage.vegetative:
        return 'Vegetativo';
      case CropGrowthStage.flowering:
        return 'Floración';
      case CropGrowthStage.fruiting:
        return 'Fructificación';
      case CropGrowthStage.readyToHarvest:
        return 'Listo para cosecha';
      case CropGrowthStage.harvested:
        return 'Cosechado';
    }
  }

  String get assetPath {
    switch (this) {
      case CropGrowthStage.planted:
        return AppAssetPaths.cropField;
      case CropGrowthStage.germinating:
        return AppAssetPaths.cropGerminating;
      case CropGrowthStage.vegetative:
        return AppAssetPaths.cropVegetative;
      case CropGrowthStage.flowering:
        return AppAssetPaths.cropFlowering;
      case CropGrowthStage.fruiting:
        return AppAssetPaths.cropFruiting;
      case CropGrowthStage.readyToHarvest:
        return AppAssetPaths.cropReadyToHarvest;
      case CropGrowthStage.harvested:
        return AppAssetPaths.cropHarvested;
    }
  }
}
