/// core › services › logger_service — centralised application logger.
///
/// Wraps debug/info/warning/error logging with platform-aware output.
library;

import 'package:flutter/foundation.dart';

class LoggerService {
  static const String _tag = '[LIBRETAPP]';

  // Basic ANSI colors for console readability; safe to ignore on clients that don't support them.
  static const _colorReset = '\x1B[0m';
  static const _colorDebug = '\x1B[90m'; // bright black / gray
  static const _colorInfo = '\x1B[32m'; // green
  static const _colorWarn = '\x1B[33m'; // yellow
  static const _colorError = '\x1B[31m'; // red

  static void d(String message, {String? tag}) {
    _log(_LogLevel.debug, message, tag);
  }

  static void i(String message, {String? tag}) {
    _log(_LogLevel.info, message, tag);
  }

  static void w(String message, {String? tag}) {
    _log(_LogLevel.warning, message, tag);
  }

  static void e(String message, {String? tag, StackTrace? stackTrace}) {
    _log(_LogLevel.error, message, tag, stackTrace: stackTrace);
  }

  /// Logs a structured metric/KPI entry to make performance investigation easier.
  /// Example: LoggerService.metric('frame_time', value: 32, unit: 'ms', context: {'route': '/home'})
  static void metric(
    String name, {
    num? value,
    String? unit,
    Map<String, Object?> context = const {},
    String? tag,
  }) {
    final buffer = StringBuffer('METRIC $name');
    if (value != null) {
      buffer.write(' value=$value');
      if (unit != null && unit.isNotEmpty) {
        buffer.write(unit);
      }
    }
    if (context.isNotEmpty) {
      final serializedContext = context.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join(' ');
      buffer.write(' [$serializedContext]');
    }
    _log(_LogLevel.info, buffer.toString(), tag ?? 'Metric');
  }

  static void _log(
    _LogLevel level,
    String message,
    String? tag, {
    StackTrace? stackTrace,
  }) {
    final prefix = '$_tag [${tag ?? 'APP'}] [${level.name.toUpperCase()}]';
    final color = switch (level) {
      _LogLevel.debug => _colorDebug,
      _LogLevel.info => _colorInfo,
      _LogLevel.warning => _colorWarn,
      _LogLevel.error => _colorError,
    };

    debugPrint('$color$prefix: $message$_colorReset');
    if (stackTrace != null) {
      debugPrint('$color${stackTrace.toString()}$_colorReset');
    }
  }
}

enum _LogLevel { debug, info, warning, error }
