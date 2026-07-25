part of '../location_detail_widgets.dart';

// ─── SublocationsSection ─────────────────────────────────────────────────────

class SublocationsSection extends StatelessWidget {
  const SublocationsSection({
    super.key,
    required this.location,
    required this.allLocations,
  });

  final LocationEntity location;
  final List<LocationEntity> allLocations;

  @override
  Widget build(BuildContext context) {
    if (!location.type.isRootType) return const SizedBox.shrink();

    final children = allLocations
        .where((l) => l.parentUuid == location.uuid)
        .toList();

    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Zonas internas',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.account_tree_outlined),
              ],
            ),
            const SizedBox(height: 12),
            if (children.isEmpty)
              Text(
                'Sin zonas agregadas aún.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...children.map(
                (child) => _ChildLocationTile(
                  child: child,
                  onTap: () =>
                      context.push(AppRoutes.ubicacionDetallePath(child.uuid)),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text('Agregar zona'),
                onPressed: () => context.pushNamed(
                  AppRoutes.nameUbicacionNueva,
                  extra: location.uuid,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildLocationTile extends StatelessWidget {
  const _ChildLocationTile({required this.child, required this.onTap});

  final LocationEntity child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: LocationTypeAvatar(
          type: child.type,
          radius: 18,
          backgroundColor: Colors.transparent,
          fallbackColor: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(child.name),
      subtitle: Text(locationTypeLabel(context, child.type)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
