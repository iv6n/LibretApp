import 'package:flutter/widgets.dart';
import 'package:libretapp/core/performance/performance_monitor.dart';
import 'package:libretapp/core/services/logger_service.dart';

/// Observes navigation to measure how long it takes for a push/pop to paint
/// the first frame. Uses PerformanceMonitor so slow transitions are surfaced
/// next to frame metrics.
class NavigationTracer extends NavigatorObserver {
  NavigationTracer._internal();

  static final NavigationTracer _instance = NavigationTracer._internal();
  static NavigationTracer get observer => _instance;

  // Keep spans per route so we can stop the right one on the next frame.
  final Map<Route<dynamic>, PerformanceSpan> _pushSpans = {};
  bool _initialized = false;

  /// Called once at startup to ensure the singleton is ready before the router
  /// builds. Safe to call multiple times.
  static void initialize() {
    _instance._initialized = true;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (!_initialized) return;

    final routeName = _routeName(route);
    final fromName = _routeName(previousRoute);
    final label = 'nav.push.${route.hashCode}';

    final span = PerformanceMonitor().startSpan(
      label,
      context: {'to': routeName, 'from': fromName},
    );
    _pushSpans[route] = span;

    // Stop the span on the next frame after the push to capture build + raster.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeSpan = _pushSpans.remove(route);
      activeSpan?.stop(
        context: {
          'phase': 'first_frame',
          'event': 'nav.push',
          'to': routeName,
          'from': fromName,
        },
      );
    });

    LoggerService.i(
      'Navigation push -> $routeName (from $fromName)',
      tag: 'Navigation',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (!_initialized) return;

    final routeName = _routeName(route);
    final toName = _routeName(previousRoute);
    final label = 'nav.pop.${route.hashCode}';

    // Measure pop cost; stops on next frame similar to push.
    final span = PerformanceMonitor().startSpan(
      label,
      context: {'from': routeName, 'to': toName},
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      span.stop(
        context: {
          'phase': 'first_frame',
          'event': 'nav.pop',
          'from': routeName,
          'to': toName,
        },
      );
    });

    LoggerService.i(
      'Navigation pop <- $routeName (to $toName)',
      tag: 'Navigation',
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (!_initialized || newRoute == null) return;

    final newName = _routeName(newRoute);
    final oldName = _routeName(oldRoute);
    final label = 'nav.replace.${newRoute.hashCode}';

    final span = PerformanceMonitor().startSpan(
      label,
      context: {'new': newName, 'old': oldName},
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      span.stop(
        context: {
          'phase': 'first_frame',
          'event': 'nav.replace',
          'new': newName,
          'old': oldName,
        },
      );
    });

    LoggerService.i(
      'Navigation replace $oldName -> $newName',
      tag: 'Navigation',
    );
  }

  String _routeName(Route<dynamic>? route) {
    if (route == null) return 'unknown';
    final settings = route.settings;
    if (settings.name != null && settings.name!.isNotEmpty) {
      return settings.name!;
    }
    if (settings.arguments != null) {
      return settings.arguments.toString();
    }
    return route.runtimeType.toString();
  }
}
