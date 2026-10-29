import 'package:flutter/material.dart';

/// Renders one of the app's existing transparent 2.5D illustrations.
class LiteArtwork extends StatelessWidget {
  const LiteArtwork({
    super.key,
    required this.assetPath,
    required this.size,
    required this.fallbackIcon,
  });

  final String assetPath;
  final double size;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(fallbackIcon, size: size * 0.72),
    ),
  );
}
