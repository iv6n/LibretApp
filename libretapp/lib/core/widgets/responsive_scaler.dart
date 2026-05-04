/// core › widgets › responsive_scaler — scales child widget based on screen size.
library;

import 'package:flutter/material.dart';

/// Scales its [child] uniformly based on the current screen width.
class ResponsiveScaler extends StatelessWidget {
  const ResponsiveScaler({required this.child, super.key});

  final Widget child;

  static const double _phoneBaseWidth = 390; // iPhone 12 baseline
  static const double _tabletBreakpoint = 600;
  static const double _desktopBreakpoint = 1200;

  double _scaleForWidth(double width) {
    if (width >= _desktopBreakpoint) {
      // Desktop: no text scaling adjustment
      return 1.0;
    } else if (width >= _tabletBreakpoint) {
      // Tablet: slight scale reduction to fit more content
      return (width / _tabletBreakpoint).clamp(0.95, 1.05).toDouble();
    } else {
      // Phone: scale relative to baseline
      final scale = width / _phoneBaseWidth;
      return scale.clamp(0.85, 1.15).toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final targetScale = _scaleForWidth(media.size.width);
    // Respect user accessibility settings; only upscale if our target is larger.
    final userScale = media.textScaler.scale(1.0);
    final effectiveScale = targetScale > userScale ? targetScale : userScale;
    final textScaler = TextScaler.linear(effectiveScale);

    return MediaQuery(
      data: media.copyWith(textScaler: textScaler),
      child: child,
    );
  }
}
