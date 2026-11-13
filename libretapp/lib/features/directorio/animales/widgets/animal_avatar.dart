/// Rounded animal avatar shared by every Directory record card.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_directory_layout.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_palette.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_photo.dart';

class AnimalAvatar extends StatelessWidget {
  const AnimalAvatar({
    super.key,
    required this.borderColor,
    required this.fallback,
    this.photoPath,
    this.fit = BoxFit.cover,
  });

  final Color borderColor;

  /// Shown when [photoPath] is empty or cannot be decoded.
  final Widget fallback;
  final String? photoPath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final metrics = AppDirectoryMetrics.of(context);
    final background = AnimalPalette.avatarBackgroundLight;
    final radius = metrics.profileAvatarSize * 0.2;

    return Material(
      elevation: 2.2,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(radius),
      color: background,
      child: Container(
        width: metrics.profileAvatarSize,
        height: metrics.profileAvatarSize,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: borderColor,
            width: metrics.avatarBorderWidth,
          ),
        ),
        padding: EdgeInsets.all(metrics.avatarPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            radius - metrics.avatarBorderWidth - metrics.avatarPadding,
          ),
          child: SizedBox.expand(
            child: AnimalPhotoImage(
              path: photoPath,
              fallback: fallback,
              fit: fit,
            ),
          ),
        ),
      ),
    );
  }
}
