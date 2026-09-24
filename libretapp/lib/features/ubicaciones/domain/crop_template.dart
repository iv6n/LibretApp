/// Editable starter templates for common Mexican farm crop cycles.
library;

class CropTemplate {
  const CropTemplate({
    required this.key,
    required this.name,
    required this.cycleType,
    required this.wateringFrequencyDays,
    this.expectedHarvestDays,
  });

  final String key;
  final String name;
  final String cycleType;
  final int wateringFrequencyDays;
  final int? expectedHarvestDays;
}

class CropTemplateLibrary {
  static const templates = <CropTemplate>[
    CropTemplate(
      key: 'maize',
      name: 'Maíz',
      cycleType: 'Anual',
      wateringFrequencyDays: 4,
      expectedHarvestDays: 120,
    ),
    CropTemplate(
      key: 'beans',
      name: 'Frijol',
      cycleType: 'Anual',
      wateringFrequencyDays: 4,
      expectedHarvestDays: 100,
    ),
    CropTemplate(
      key: 'sorghum',
      name: 'Sorgo',
      cycleType: 'Anual',
      wateringFrequencyDays: 5,
      expectedHarvestDays: 115,
    ),
    CropTemplate(
      key: 'alfalfa',
      name: 'Alfalfa / pastura',
      cycleType: 'Forraje',
      wateringFrequencyDays: 3,
      expectedHarvestDays: 70,
    ),
    CropTemplate(
      key: 'fruit-tree',
      name: 'Árbol frutal',
      cycleType: 'Perenne',
      wateringFrequencyDays: 7,
    ),
  ];

  static CropTemplate? byKey(String key) {
    for (final template in templates) {
      if (template.key == key) return template;
    }
    return null;
  }
}
