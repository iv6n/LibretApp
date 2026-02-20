import 'package:flutter/material.dart';

class ResponsiveScaler extends StatelessWidget {
  const ResponsiveScaler({required this.child, super.key});

  final Widget child;

  double _scaleForWidth(double width) {
    const double baseWidth = 390; // iPhone 12 baseline
    final scale = width / baseWidth;
    return scale.clamp(0.9, 1.15).toDouble();
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
