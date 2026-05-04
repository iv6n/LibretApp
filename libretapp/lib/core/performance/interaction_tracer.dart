/// core › performance › interaction_tracer — traces gesture interaction timing.
library;

import 'package:flutter/gestures.dart';
import 'package:libretapp/core/performance/performance_monitor.dart';
import 'package:libretapp/core/services/logger_service.dart';

/// Captures global pointer taps to correlate user interactions with slow frames.
/// This is intentionally lightweight: it records down/up duration and logs a
/// metric entry. It does not try to identify the exact widget hit, but the
/// screen location is included for correlating in dev tools or logs.
class InteractionTracer {
  factory InteractionTracer() => _instance;
  InteractionTracer._internal();

  static final InteractionTracer _instance = InteractionTracer._internal();

  bool _started = false;
  final Map<int, PerformanceSpan> _activeTaps = {};

  void start() {
    if (_started) return;
    _started = true;
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointerEvent);
    LoggerService.i(
      'Interaction tracing enabled (global tap listener)',
      tag: 'Trace',
    );
  }

  void stop() {
    if (!_started) return;
    _started = false;
    GestureBinding.instance.pointerRouter.removeGlobalRoute(
      _handlePointerEvent,
    );
    _activeTaps.clear();
    LoggerService.i('Interaction tracing disabled', tag: 'Trace');
  }

  void _handlePointerEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      // Start a span for this pointer id.
      final label = 'tap.${event.pointer}.${event.timeStamp.inMicroseconds}';
      final span = PerformanceMonitor().startSpan(
        label,
        context: {
          'pointer': event.pointer,
          'x': event.position.dx.toStringAsFixed(1),
          'y': event.position.dy.toStringAsFixed(1),
          'kind': event.kind.name,
        },
      );
      _activeTaps[event.pointer] = span;
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      final span = _activeTaps.remove(event.pointer);
      final elapsed = span?.stop(
        context: {
          'end_x': event.position.dx.toStringAsFixed(1),
          'end_y': event.position.dy.toStringAsFixed(1),
          'canceled': event is PointerCancelEvent,
        },
      );

      if (elapsed != null) {
        LoggerService.metric(
          'tap.duration_ms',
          value: elapsed,
          unit: 'ms',
          context: {'pointer': event.pointer, 'kind': event.kind.name},
          tag: 'Trace',
        );
      }
    }
  }
}
