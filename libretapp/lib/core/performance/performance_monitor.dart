import 'dart:collection';

import 'package:flutter/scheduler.dart';
import 'package:libretapp/core/services/logger_service.dart';

const int _defaultSlowOperationMs = 120;
const int _defaultSlowFrameMs = 120;

class PerformanceSample {
  PerformanceSample({
    required this.label,
    required this.elapsedMs,
    required this.timestamp,
    this.context = const {},
  });

  final String label;
  final int elapsedMs;
  final DateTime timestamp;
  final Map<String, Object?> context;
}

class PerformanceSpan {
  PerformanceSpan(this.label, this._monitor);

  final String label;
  final PerformanceMonitor _monitor;
  bool _stopped = false;

  int? stop({Map<String, Object?> context = const {}}) {
    if (_stopped) return null;
    _stopped = true;
    return _monitor.stop(label, context: context);
  }
}

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();

  factory PerformanceMonitor() => _instance;

  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _stopwatches = {};
  final Map<String, DateTime> _startTimes = {};
  final Map<String, Map<String, Object?>> _contexts = {};
  final Map<String, int> _contextSlowThreshold = {};
  final Queue<PerformanceSample> _samples = Queue();

  int maxSamples = 200;
  int slowOperationThresholdMs = _defaultSlowOperationMs;
  int slowFrameThresholdMs = _defaultSlowFrameMs;

  PerformanceSpan startSpan(
    String label, {
    Map<String, Object?> context = const {},
    int? slowThresholdMs,
  }) {
    start(label, context: context, slowThresholdMs: slowThresholdMs);
    return PerformanceSpan(label, this);
  }

  void start(
    String label, {
    Map<String, Object?> context = const {},
    int? slowThresholdMs,
  }) {
    final stopwatch = Stopwatch()..start();
    _stopwatches[label] = stopwatch;
    _startTimes[label] = DateTime.now();
    _contexts[label] = context;
    if (slowThresholdMs != null) {
      _contextSlowThreshold[label] = slowThresholdMs;
    }
    LoggerService.d('Started: $label', tag: 'Performance');
  }

  int? stop(String label, {Map<String, Object?> context = const {}}) {
    final stopwatch = _stopwatches.remove(label);
    final startedAt = _startTimes.remove(label);
    final baseContext = _contexts.remove(label) ?? const {};
    final mergedContext = {...baseContext, ...context};
    final slowThresholdMs = _contextSlowThreshold.remove(label);

    if (stopwatch != null) {
      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;
      _recordSample(
        label: label,
        elapsedMs: elapsed,
        startedAt: startedAt,
        context: mergedContext,
        slowThresholdMs: slowThresholdMs,
      );
      return elapsed;
    }
    return null;
  }

  Future<T> measure<T>(
    String label, {
    Map<String, Object?> context = const {},
    int? slowThresholdMs,
    required Future<T> Function() run,
  }) async {
    start(label, context: context, slowThresholdMs: slowThresholdMs);
    try {
      final result = await run();
      return result;
    } finally {
      stop(label);
    }
  }

  void attachFrameTimings({int? slowFrameThresholdMs}) {
    if (slowFrameThresholdMs != null) {
      this.slowFrameThresholdMs = slowFrameThresholdMs;
    }

    SchedulerBinding.instance.addTimingsCallback((timings) {
      for (final timing in timings) {
        final buildMs = timing.buildDuration.inMilliseconds;
        final rasterMs = timing.rasterDuration.inMilliseconds;
        final totalMs = buildMs + rasterMs;
        final sampleContext = {
          'build_ms': buildMs,
          'raster_ms': rasterMs,
          'total_ms': totalMs,
        };

        LoggerService.metric(
          'frame_time',
          value: totalMs,
          unit: 'ms',
          context: sampleContext,
          tag: 'Performance',
        );

        final frameThreshold =
            slowFrameThresholdMs ?? this.slowFrameThresholdMs;
        if (totalMs >= frameThreshold) {
          LoggerService.w(
            'Slow frame detected: ${totalMs}ms (build ${buildMs}ms, raster ${rasterMs}ms)',
            tag: 'Performance',
          );
        }

        _recordSample(
          label: 'frame',
          elapsedMs: totalMs,
          startedAt: DateTime.now(),
          context: sampleContext,
          slowThresholdMs: slowFrameThresholdMs ?? this.slowFrameThresholdMs,
        );
      }
    });
  }

  void logSummary({int maxEntries = 5}) {
    if (_samples.isEmpty) {
      LoggerService.i(
        'No performance samples to summarize',
        tag: 'Performance',
      );
      return;
    }

    final Map<String, List<int>> grouped = {};
    for (final sample in _samples) {
      grouped.putIfAbsent(sample.label, () => <int>[]).add(sample.elapsedMs);
    }

    grouped.forEach((label, values) {
      values.sort();
      final count = values.length;
      final avg = values.reduce((a, b) => a + b) / count;
      final p90Index = ((values.length * 0.9).floor()).clamp(
        0,
        values.length - 1,
      );
      final p90 = values[p90Index];
      final max = values.last;

      LoggerService.metric(
        'performance_summary.$label',
        context: {
          'count': count,
          'avg_ms': avg.toStringAsFixed(1),
          'p90_ms': p90,
          'max_ms': max,
        },
        tag: 'Performance',
      );
    });
  }

  void clear() {
    _stopwatches.clear();
    _startTimes.clear();
    _contexts.clear();
    _samples.clear();
    _contextSlowThreshold.clear();
  }

  void _recordSample({
    required String label,
    required int elapsedMs,
    DateTime? startedAt,
    Map<String, Object?> context = const {},
    int? slowThresholdMs,
  }) {
    final threshold = slowThresholdMs ?? slowOperationThresholdMs;
    final sample = PerformanceSample(
      label: label,
      elapsedMs: elapsedMs,
      timestamp: DateTime.now(),
      context: context,
    );

    _samples.add(sample);
    while (_samples.length > maxSamples) {
      _samples.removeFirst();
    }

    final contextWithStart = startedAt != null
        ? {...context, 'started_at': startedAt.toIso8601String()}
        : context;

    LoggerService.metric(
      'performance.$label',
      value: elapsedMs,
      unit: 'ms',
      context: contextWithStart,
      tag: 'Performance',
    );

    if (elapsedMs >= threshold) {
      LoggerService.w(
        'Slow $label detected: ${elapsedMs}ms (threshold ${threshold}ms)',
        tag: 'Performance',
      );
    }
  }
}
