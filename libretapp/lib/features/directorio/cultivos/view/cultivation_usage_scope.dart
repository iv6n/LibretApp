/// Makes active cultivation assignments available to location cards.
library;

import 'package:flutter/widgets.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';

class CultivationUsageScope extends InheritedWidget {
  CultivationUsageScope({
    super.key,
    required List<CultivationEntity> cultivations,
    required super.child,
  }) : byLocation = _group(cultivations);

  final Map<String, List<CultivationEntity>> byLocation;

  static List<CultivationEntity> forLocation(
    BuildContext context,
    String locationUuid,
  ) {
    return context
            .dependOnInheritedWidgetOfExactType<CultivationUsageScope>()
            ?.byLocation[locationUuid] ??
        const [];
  }

  static Map<String, List<CultivationEntity>> _group(
    List<CultivationEntity> items,
  ) {
    final result = <String, List<CultivationEntity>>{};
    for (final item in items.where((item) => item.isActive)) {
      final locationUuid = item.locationUuid;
      if (locationUuid == null || locationUuid.isEmpty) continue;
      result.putIfAbsent(locationUuid, () => []).add(item);
    }
    return {
      for (final entry in result.entries)
        entry.key: List<CultivationEntity>.unmodifiable(entry.value),
    };
  }

  @override
  bool updateShouldNotify(CultivationUsageScope oldWidget) =>
      byLocation != oldWidget.byLocation;
}
