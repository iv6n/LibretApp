/// features \u203a ubicaciones \u203a domain \u203a enums \u203a crop_growth_stage \u2014 enum for crop growth stages.
library;

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
}
