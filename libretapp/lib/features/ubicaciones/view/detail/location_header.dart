part of '../location_detail_widgets.dart';

// ─── LocationHeader ───────────────────────────────────────────────────────────

class LocationHeader extends StatelessWidget {
  const LocationHeader({super.key, required this.location, required this.animalsHere});

  final LocationEntity location;
  final List<AnimalEntity> animalsHere;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dominantSpecies = _dominantSpeciesLabel(animalsHere);
    final systemLabel = _systemLabel(context, location.type);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.earth],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Última actualización ${location.costs.isNotEmpty ? location.costs.last.date : 'N/D'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    locationTypeLabel(context, location.type).toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    locationStatusLabel(context, location.status).toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: LocationTypeAvatar(
                              type: location.type,
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              fallbackColor:
                                  theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  location.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${locationTypeLabel(context, location.type)} • ${location.terrainType}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary
                                        .withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const _MiniMapPlaceholder(),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(
                  icon: Icons.badge_outlined,
                  label: dominantSpecies ?? 'Especie sin asignar',
                ),
                _InfoPill(icon: Icons.safety_divider, label: systemLabel),
                _InfoPill(
                  icon: Icons.water_drop_outlined,
                  label: location.waterSource,
                ),
                _InfoPill(
                  icon: Icons.landscape_outlined,
                  label: location.terrainType,
                ),
                _InfoPill(
                  icon: Icons.straighten,
                  label:
                      '${location.surfaceArea.toStringAsFixed(1)} ha superficie',
                ),
                _InfoPill(
                  icon: Icons.groups,
                  label: '${location.capacity} capacidad',
                ),
              ],
            ),

            const SizedBox(height: 12),
            const _GalleryStrip(),
          ],
        ),
      ),
    );
  }
}

String _systemLabel(BuildContext context, LocationType type) {
  switch (type) {
    case LocationType.pasture:
    case LocationType.feedlot:
    case LocationType.pen:
      return 'Pastoreo';
    case LocationType.monte:
    case LocationType.forest:
    case LocationType.protectedArea:
      return 'Pastoreo extensivo';
    case LocationType.corral:
    case LocationType.chute:
    case LocationType.quarantineArea:
    case LocationType.loadingArea:
    case LocationType.weighingArea:
      return 'Confinamiento';
    case LocationType.warehouse:
    case LocationType.workshop:
    case LocationType.office:
      return 'Almacén';
    case LocationType.pond:
    case LocationType.well:
    case LocationType.dam:
    case LocationType.spring:
    case LocationType.trough:
    case LocationType.canal:
    case LocationType.reservoir:
    case LocationType.lagoon:
    case LocationType.river:
    case LocationType.wetland:
    case LocationType.waterTank:
      return 'Conservación agua';
    case LocationType.ranch:
    case LocationType.farm:
    case LocationType.finca:
    case LocationType.hacienda:
    case LocationType.property:
      return 'Mixto';
    case LocationType.field:
    case LocationType.plot:
    case LocationType.milpa:
    case LocationType.orchard:
    case LocationType.greenhouse:
    case LocationType.nursery:
    case LocationType.garden:
      return 'Pastoreo / rotación';
    case LocationType.house:
    case LocationType.barn:
    case LocationType.stable:
      return 'Habitacional';
    default:
      return locationTypeLabel(context, type);
  }
}

String? _dominantSpeciesLabel(List<AnimalEntity> animals) {
  if (animals.isEmpty) return null;
  final counts = <Species, int>{};
  for (final animal in animals) {
    counts[animal.species] = (counts[animal.species] ?? 0) + 1;
  }
  final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
  return top.key.displayName;
}

// ─── InfoPill ─────────────────────────────────────────────────────────────────

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MiniMapPlaceholder ───────────────────────────────────────────────────────

class _MiniMapPlaceholder extends StatelessWidget {
  const _MiniMapPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Icon(
              Icons.map_outlined,
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              size: 80,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'GPS pendiente',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── GalleryStrip ─────────────────────────────────────────────────────────────

class _GalleryStrip extends StatelessWidget {
  const _GalleryStrip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Container(
            width: 88,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.photo_outlined),
                const SizedBox(height: 6),
                Text(
                  index == 0 ? 'Agregar foto' : 'Foto ${index + 1}',
                  style: theme.textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

