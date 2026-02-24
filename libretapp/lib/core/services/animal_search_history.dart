import 'package:shared_preferences/shared_preferences.dart';

class AnimalSearchHistory {
  AnimalSearchHistory({this.maxItems = 10});

  final int maxItems;
  static const _storageKey = 'animal_search_history';

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_storageKey) ?? <String>[];
    return List<String>.from(saved);
  }

  Future<List<String>> add(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return load();

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_storageKey) ?? <String>[];
    final filtered = current
        .where((item) => item.toLowerCase() != query.toLowerCase())
        .toList();
    filtered.insert(0, query);
    if (filtered.length > maxItems) {
      filtered.removeRange(maxItems, filtered.length);
    }
    await prefs.setStringList(_storageKey, filtered);
    return filtered;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
