/// Shared LibretApp identity for light and dark surfaces.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppBrandVariant { symbol, logo }

class AppBrand extends StatelessWidget {
  const AppBrand({
    this.variant = AppBrandVariant.logo,
    this.height = 40,
    this.excludeFromSemantics = false,
    super.key,
  }) : assert(height > 0);

  final AppBrandVariant variant;
  final double height;

  /// Use when nearby text already introduces LibretApp to screen readers.
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    final appearance = Theme.of(context).brightness == Brightness.dark
        ? 'dark'
        : 'light';
    final picture = SvgPicture.asset(
      'assets/branding/${variant.name}-$appearance.svg',
      height: height,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );

    if (excludeFromSemantics) return picture;

    return Semantics(
      label: 'LibretApp',
      image: true,
      excludeSemantics: true,
      child: picture,
    );
  }
}
