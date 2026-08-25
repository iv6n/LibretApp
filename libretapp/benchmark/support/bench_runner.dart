/// benchmark › support › bench_runner — timing + reporting for the perf suite.
///
/// Deliberately tiny: every measurement is a wall-clock median over repeated
/// runs, printed as a table and appended to a JSON file so a before/after
/// comparison is a plain diff rather than a re-read of the console.
library;

import 'dart:convert';
import 'dart:io';

class BenchResult {
  BenchResult({
    required this.name,
    required this.scale,
    required this.samples,
  });

  final String name;
  final String scale;
  final List<int> samples; // microseconds, one per iteration

  List<int> get _sorted => List<int>.from(samples)..sort();

  int get medianUs => _sorted[_sorted.length ~/ 2];
  int get minUs => _sorted.first;
  int get maxUs => _sorted.last;
  int get p90Us => _sorted[((_sorted.length * 0.9).floor()).clamp(0, _sorted.length - 1)];
  double get meanUs => samples.reduce((a, b) => a + b) / samples.length;

  Map<String, Object?> toJson() => {
    'name': name,
    'scale': scale,
    'iterations': samples.length,
    'median_us': medianUs,
    'mean_us': meanUs.round(),
    'p90_us': p90Us,
    'min_us': minUs,
    'max_us': maxUs,
  };
}

class BenchSuite {
  BenchSuite(this.label);

  final String label;
  final List<BenchResult> results = [];

  /// Runs [body] [warmup] times untimed, then [iterations] times timed.
  Future<BenchResult> measure(
    String name, {
    required String scale,
    required Future<void> Function() body,
    int iterations = 10,
    int warmup = 2,
  }) async {
    for (var i = 0; i < warmup; i++) {
      await body();
    }

    final samples = <int>[];
    for (var i = 0; i < iterations; i++) {
      final sw = Stopwatch()..start();
      await body();
      sw.stop();
      samples.add(sw.elapsedMicroseconds);
    }

    final result = BenchResult(name: name, scale: scale, samples: samples);
    results.add(result);
    stdout.writeln(
      '  ${name.padRight(46)} ${scale.padRight(10)} '
      'median ${_ms(result.medianUs).padLeft(9)}  '
      'p90 ${_ms(result.p90Us).padLeft(9)}  '
      '(n=${samples.length})',
    );
    return result;
  }

  static String _ms(int us) => '${(us / 1000).toStringAsFixed(3)} ms';

  /// Writes the suite to [path] as JSON so runs can be diffed mechanically.
  void writeJson(String path) {
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'label': label,
        'recorded_at': DateTime.now().toIso8601String(),
        'results': results.map((r) => r.toJson()).toList(),
      }),
    );
    stdout.writeln('\nWrote ${results.length} results to $path');
  }
}
