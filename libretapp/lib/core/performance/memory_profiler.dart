class MemoryProfiler {
  static final MemoryProfiler _instance = MemoryProfiler._internal();

  factory MemoryProfiler() {
    return _instance;
  }

  MemoryProfiler._internal();

  final Map<String, int> _memoryUsage = {};

  void recordMemory(String feature) {
    _memoryUsage[feature] = DateTime.now().millisecondsSinceEpoch;
  }

  int? getMemoryUsage(String feature) {
    return _memoryUsage[feature];
  }

  void clear() {
    _memoryUsage.clear();
  }
}
