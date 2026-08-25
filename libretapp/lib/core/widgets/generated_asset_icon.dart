import 'package:flutter/material.dart';

/// Small generated raster icon with a Material fallback when the asset is
/// unavailable from the bundle.
class GeneratedAssetIcon extends StatelessWidget {
  const GeneratedAssetIcon({
    required this.assetPath,
    required this.fallbackIcon,
    this.size = 24,
    super.key,
  });

  final String assetPath;
  final IconData fallbackIcon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => Icon(fallbackIcon, size: size),
    );
  }
}
