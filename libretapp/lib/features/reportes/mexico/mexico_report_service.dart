library;

import 'mexico_report_models.dart';

class MexicoReportService {
  const MexicoReportService();
  MexicoReportTemplate templateFor(MexicoReportType type) => MexicoReportCatalog.templates.firstWhere((t) => t.type == type);
  List<List<String>> toRows(MexicoReportRequest request, Iterable<Map<String, dynamic>> records) {
    final template = templateFor(request.type);
    return [template.columns, ...records.map((row) => template.columns.map((column) => '${row[column] ?? ''}').toList())];
  }
}
