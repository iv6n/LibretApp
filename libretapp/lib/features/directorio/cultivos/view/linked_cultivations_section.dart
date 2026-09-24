/// Compact cultivation usage summary shown from a location detail.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';

class LinkedCultivationsSection extends StatelessWidget {
  const LinkedCultivationsSection({
    super.key,
    required this.location,
    required this.repository,
  });

  final LocationEntity location;
  final CultivationRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CultivationEntity>>(
      stream: repository.watchByLocation(location.uuid, includeArchived: true),
      initialData: const [],
      builder: (context, snapshot) {
        final all = snapshot.data ?? const [];
        final active = all.where((item) => item.isActive).toList();
        final usedSquareMeters = active.fold<double>(
          0,
          (total, item) => total + item.areaSquareMeters,
        );
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cultivos vinculados',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => context.pushNamed(
                        AppRoutes.nameCultivoNuevo,
                        queryParameters: {'location': location.uuid},
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Nuevo'),
                    ),
                  ],
                ),
                if (active.isEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Sin cultivos activos. La ubicación está disponible para vincular una planta, huerto o siembra.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Text(
                    _usageSummary(active, usedSquareMeters),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Divider(height: 20),
                  for (final cultivation in active)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Icon(_iconForScale(cultivation.scale)),
                      ),
                      title: Text(cultivation.name),
                      subtitle: Text(
                        '${cultivation.measureLabel} · ${cultivation.growthStage.displayName}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.pushNamed(
                        AppRoutes.nameCultivoDetalle,
                        pathParameters: {'uuid': cultivation.uuid},
                      ),
                    ),
                  if (all.length > active.length)
                    Text(
                      '${all.length - active.length} cultivo${all.length - active.length == 1 ? '' : 's'} finalizado${all.length - active.length == 1 ? '' : 's'} en el historial',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _usageSummary(
    List<CultivationEntity> active,
    double usedSquareMeters,
  ) {
    final extra = active.length > 1 ? ' +${active.length - 1}' : '';
    final area = usedSquareMeters <= 0
        ? ''
        : usedSquareMeters >= 10000
        ? ' · ${(usedSquareMeters / 10000).toStringAsFixed(2)} ha usadas'
        : ' · ${usedSquareMeters.toStringAsFixed(0)} m² usados';
    return 'En uso por ${active.first.name}$extra$area';
  }

  IconData _iconForScale(CultivationScale scale) => switch (scale) {
    CultivationScale.individual => Icons.local_florist_outlined,
    CultivationScale.group => Icons.yard_outlined,
    CultivationScale.area => Icons.grass_outlined,
  };
}
