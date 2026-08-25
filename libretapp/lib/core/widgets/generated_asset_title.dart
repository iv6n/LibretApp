import 'package:flutter/material.dart';

/// Compact AppBar title that shows a generated raster asset with a Material
/// fallback when the asset cannot be loaded.
class GeneratedAssetTitle extends StatelessWidget {
  const GeneratedAssetTitle({
    required this.title,
    required this.assetPath,
    required this.fallbackIcon,
    super.key,
  });

  final String title;
  final String? assetPath;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: assetPath == null
              ? Icon(fallbackIcon, size: 22)
              : Image.asset(
                  assetPath!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Icon(fallbackIcon, size: 22),
                ),
        ),
        const SizedBox(width: 8),
        Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
