/// features \u203a ubicaciones \u203a domain \u203a enums \u203a crop_task_type \u2014 enum for types of crop tasks.
library;

enum CropTaskType { water, fertilize, spray, harvest, prune }

extension CropTaskTypeX on CropTaskType {
  String get displayName {
    switch (this) {
      case CropTaskType.water:
        return 'Regar';
      case CropTaskType.fertilize:
        return 'Fertilizar';
      case CropTaskType.spray:
        return 'Fumigar';
      case CropTaskType.harvest:
        return 'Cosechar';
      case CropTaskType.prune:
        return 'Podar';
    }
  }
}
