/// Shared animal-photo rendering and editing controls.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/media/image_source_picker.dart';
import 'package:libretapp/core/media/media_store.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AnimalPhotoImage extends StatelessWidget {
  const AnimalPhotoImage({
    super.key,
    required this.path,
    required this.fallback,
    this.fit = BoxFit.cover,
  });

  final String? path;
  final Widget fallback;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final provider = animalPhotoProvider(path);
    if (provider == null) return fallback;
    return Image(
      image: provider,
      fit: fit,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

ImageProvider<Object>? animalPhotoProvider(String? path) {
  final normalized = path?.trim() ?? '';
  if (normalized.isEmpty) return null;
  final uri = Uri.tryParse(normalized);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return NetworkImage(normalized);
  }
  final file = File(normalized);
  return file.existsSync() ? FileImage(file) : null;
}

/// Species illustrations shown when a pet has no personal photograph.
String? petIllustrationAsset(Species species) => switch (species) {
  Species.canine => 'assets/images/canino.webp',
  Species.feline => 'assets/images/felino.png',
  _ => null,
};

Future<void> showAnimalPhoto(
  BuildContext context, {
  required String? path,
  required String name,
}) => showDialog<void>(
  context: context,
  useSafeArea: false,
  builder: (context) => Dialog.fullscreen(
    child: Scaffold(
      appBar: AppBar(
        title: Text(name),
        leading: IconButton(
          tooltip: 'Cerrar fotografía',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: InteractiveViewer(
          minScale: 0.75,
          maxScale: 5,
          child: Center(
            child: AnimalPhotoImage(
              path: path,
              fit: BoxFit.contain,
              fallback: const Text('Fotografía no disponible'),
            ),
          ),
        ),
      ),
    ),
  ),
);

class AnimalPhotoField extends StatelessWidget {
  const AnimalPhotoField({
    super.key,
    required this.photoPath,
    required this.species,
    required this.onChanged,
    this.enabled = true,
    this.compact = false,
  });

  final String? photoPath;
  final Species species;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final bool compact;

  Future<void> _pick(BuildContext context) async {
    final source = await showImageSourcePicker(context);
    if (source == null || !context.mounted) return;
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 84,
        maxWidth: 2048,
      );
      if (image == null) return;
      final savedPath = await locator<MediaStore>().persist(
        image,
        MediaBucket.animals,
      );
      if (context.mounted) onChanged(savedPath);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).mediaSaveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasPhoto = (photoPath ?? '').trim().isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;
    if (compact) {
      return Semantics(
        label: hasPhoto
            ? 'Fotografía del animal añadida'
            : 'Fotografía opcional del animal',
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 56,
                height: 56,
                child: AnimalPhotoImage(
                  path: photoPath,
                  fallback: _SpeciesFallback(species: species),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: enabled ? () => _pick(context) : null,
                icon: Icon(
                  hasPhoto
                      ? Icons.cameraswitch_outlined
                      : Icons.add_a_photo_outlined,
                ),
                label: Text(
                  hasPhoto ? l10n.animalPhotoReplace : l10n.animalPhotoAdd,
                ),
              ),
            ),
            if (hasPhoto)
              IconButton(
                tooltip: l10n.animalPhotoRemove,
                onPressed: enabled ? () => onChanged(null) : null,
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.animalPhotoTitle,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 150,
            color: colorScheme.surfaceContainerLow,
            child: AnimalPhotoImage(
              path: photoPath,
              fallback: _SpeciesFallback(species: species),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: enabled ? () => _pick(context) : null,
              icon: Icon(
                hasPhoto
                    ? Icons.cameraswitch_outlined
                    : Icons.add_a_photo_outlined,
              ),
              label: Text(
                hasPhoto ? l10n.animalPhotoReplace : l10n.animalPhotoAdd,
              ),
            ),
            if (hasPhoto)
              TextButton.icon(
                onPressed: enabled ? () => onChanged(null) : null,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.animalPhotoRemove),
              ),
          ],
        ),
      ],
    );
  }
}

class _SpeciesFallback extends StatelessWidget {
  const _SpeciesFallback({required this.species});

  final Species species;

  @override
  Widget build(BuildContext context) {
    final illustration = petIllustrationAsset(species);
    return Center(
      child: illustration == null
          ? Icon(
              _iconForSpecies(species),
              size: 54,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )
          : Image.asset(
              illustration,
              height: 132,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
    );
  }

  static IconData _iconForSpecies(Species species) => switch (species) {
    Species.cattle => Icons.agriculture_outlined,
    Species.equine => Icons.directions_run,
    Species.sheep || Species.goat => Icons.pets_outlined,
    Species.pig => Icons.cruelty_free_outlined,
    Species.poultry => Icons.egg_outlined,
    Species.canine || Species.feline => Icons.pets,
    Species.other => Icons.category_outlined,
  };
}
