library;

enum ProjectionMethod { observedGdp, manualEstimate, scenario }

class ProjectionResult {
  const ProjectionResult({required this.metric, required this.value, required this.targetDate, required this.method, required this.dataUsed, this.insufficientData = false});
  final String metric;
  final double? value;
  final DateTime? targetDate;
  final ProjectionMethod method;
  final List<String> dataUsed;
  final bool insufficientData;
}

class ProjectionService {
  ProjectionResult weight({required double? currentKg, required double? targetKg, required double? observedGdp, required DateTime asOf}) {
    if (currentKg == null || targetKg == null || observedGdp == null || observedGdp <= 0) return const ProjectionResult(metric: 'peso', value: null, targetDate: null, method: ProjectionMethod.observedGdp, dataUsed: [], insufficientData: true);
    final days = ((targetKg - currentKg) / observedGdp).ceil();
    return ProjectionResult(metric: 'peso', value: targetKg, targetDate: asOf.add(Duration(days: days.clamp(0, 100000))), method: ProjectionMethod.observedGdp, dataUsed: ['peso_actual', 'peso_objetivo', 'gdp_observada']);
  }
}
