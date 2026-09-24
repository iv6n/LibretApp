/// Versioned Mexican operational report exports.
library;

enum MexicoReportType { movements, morbidity, mortality }

class MexicoReportRequest {
  const MexicoReportRequest({required this.farmId, required this.type, required this.from, required this.to, this.animalIds = const [], this.veterinarian});
  final String farmId;
  final MexicoReportType type;
  final DateTime from;
  final DateTime to;
  final List<String> animalIds;
  final String? veterinarian;
}

class MexicoReportTemplate {
  const MexicoReportTemplate({required this.type, required this.version, required this.columns, required this.officialReference});
  final MexicoReportType type;
  final String version;
  final List<String> columns;
  final String officialReference;
  bool get connectorEnabled => false;
}

class MexicoReportCatalog {
  static const templates = <MexicoReportTemplate>[
    MexicoReportTemplate(type: MexicoReportType.movements, version: '2026.1', columns: ['fecha', 'animal', 'origen', 'destino', 'upp'], officialReference: 'SENASICA-identificacion-animal'),
    MexicoReportTemplate(type: MexicoReportType.morbidity, version: '2026.1', columns: ['fecha', 'animal', 'diagnostico', 'tratamiento', 'mvz'], officialReference: 'SENASICA-salud'),
    MexicoReportTemplate(type: MexicoReportType.mortality, version: '2026.1', columns: ['fecha', 'animal', 'causa', 'upp', 'mvz'], officialReference: 'SENASICA-mortalidad'),
  ];
}
