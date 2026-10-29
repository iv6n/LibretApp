library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/scheduled_care.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_helpers.dart';
import 'package:libretapp/theme/app_theme.dart';

class AnimalSummaryPanel extends StatelessWidget {
  const AnimalSummaryPanel({
    super.key,
    required this.animal,
    this.data,
    this.onShowCare,
    this.onEditPurpose,
  });
  final AnimalEntity animal;
  final DetailData? data;
  final VoidCallback? onShowCare;
  final VoidCallback? onEditPurpose;

  @override
  Widget build(BuildContext context) {
    final snapshot = data?.indicatorSnapshot;
    final indicators = indicatorsFor(
      animal,
      snapshot: snapshot,
      maxIndicators: 3,
    );
    final pending = animal.status.isInActiveHerd
        ? [...?data?.carePending]
        : <ScheduledCare>[];
    pending.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    final next = pending.firstOrNull;
    final hasRecords =
        data != null &&
        [
          data!.weights,
          data!.weanings,
          data!.health,
          data!.reproductions,
          data!.productions,
          data!.milkingRecords,
          data!.commercial,
          data!.movements,
          data!.costs,
          data!.careRecords,
        ].any((records) => records.isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          title: 'Cómo está',
          subtitle: animal.productionPurpose == ProductionPurpose.undefined
              ? 'Propósito pendiente'
              : animal.productionPurpose.displayName,
          leading: Icon(
            Icons.insights_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final indicator in indicators.where(
                    (item) => item.kind != PurposeIndicatorKind.definePurpose,
                  ))
                    AppChip(
                      label: indicator.label,
                      tone: switch (indicator.severity) {
                        IndicatorSeverity.critical => AppChipTone.error,
                        IndicatorSeverity.attention => AppChipTone.warning,
                        IndicatorSeverity.neutral => AppChipTone.info,
                      },
                    ),
                ],
              ),
              if (animal.productionPurpose == ProductionPurpose.undefined &&
                  onEditPurpose != null)
                TextButton.icon(
                  onPressed: onEditPurpose,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Definir propósito'),
                ),
              const SizedBox(height: AppSpacing.sm),
              Text('Nacimiento: ${animal.hasKnownAge ? formatDate(animal.birthDate) : 'Sin dato'}'),
              if (animal.species == Species.cattle &&
                  ({Category.calf, Category.weaned}.contains(animal.category) ||
                      animal.productionPurpose == ProductionPurpose.meat)) ...[
                Text(
                  'Madre: ${(data?.ancestors[animal.damUuid] == null ? null : primaryAnimalLabel(data!.ancestors[animal.damUuid]!)) ?? animal.damUuid ?? 'No registrada'}',
                ),
                Text(
                  'Padre: ${(data?.ancestors[animal.sireUuid] == null ? null : primaryAnimalLabel(data!.ancestors[animal.sireUuid]!)) ?? animal.sireUuid ?? 'No registrado'}',
                ),
              ],
              if (snapshot?.lastWeightDate != null)
                Text(
                  'Último peso: ${snapshot!.lastWeightKg!.toStringAsFixed(1)} kg · ${formatDate(snapshot.lastWeightDate!)} · ${snapshot.lastWeightMethod == WeightMethod.scale ? 'Báscula' : 'Estimado'}',
                ),
              if (animal.species == Species.cattle &&
                  (animal.productionPurpose == ProductionPurpose.meat ||
                      {
                        Category.calf,
                        Category.weaned,
                      }.contains(animal.category)))
                Text(
                  'Ganancia diaria: ${snapshot?.averageDailyGainKg == null ? 'Sin datos' : '${snapshot!.averageDailyGainKg!.toStringAsFixed(2)} kg/día'}',
                ),
              if (animal.sex == Sex.female &&
                  AnimalRegistrationPolicy.forSpecies(
                    animal.species,
                  ).supportsReproduction) ...[
                Text(
                  'Estado reproductivo: ${animal.reproductiveStatus.displayName}',
                ),
                if (snapshot?.reproductiveKpis?.lastCalvingDate != null)
                  Text(
                    'Último parto: ${formatDate(snapshot!.reproductiveKpis!.lastCalvingDate!)}',
                  ),
                if (animal.expectedCalvingDate != null)
                  Text(
                    'Parto esperado (estimado): ${formatDate(animal.expectedCalvingDate!)}',
                  ),
                Text('Crías vinculadas: ${data?.offspring.length ?? 0}'),
              ],
              if (animal.sex == Sex.male &&
                  animal.species == Species.cattle &&
                  data != null) ...[
                Builder(
                  builder: (context) {
                    final kpi = const ReproductiveKpiService().forSire(
                      records: data!.sireRecords,
                    );
                    return kpi.serviceCount == 0
                        ? const SizedBox.shrink()
                        : Text(
                            'Servicios: ${kpi.serviceCount} · Hembras distintas: ${kpi.femalesServed} · Crías: ${kpi.offspringCount}',
                          );
                  },
                ),
              ],
              if (data?.weanings.isNotEmpty ?? false)
                Text(
                  'Destete: ${formatDate(data!.weanings.first.date)}${data!.weanings.first.weightKg == null ? '' : ' · ${data!.weanings.first.weightKg} kg'}',
                ),
              if (!hasRecords) ...[
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Sin registros todavía. Registra una actividad para comenzar el seguimiento.',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AppCard(
          title: !animal.status.isInActiveHerd
              ? 'Historial conservado'
              : next == null
              ? 'Sin cuidados pendientes'
              : 'Próximo cuidado',
          leading: const Icon(Icons.event_available_outlined),
          subtitle: !animal.status.isInActiveHerd
              ? 'Este animal salió del hato. Puedes consultar y corregir sus registros.'
              : next == null
              ? 'Consulta Cuidados para ver el seguimiento.'
              : '${data!.careRules[next.ruleId]?.name ?? next.type.displayName} · ${formatDate(next.dueAt)}',
          trailing: onShowCare == null ? null : const Icon(Icons.chevron_right),
          onTap: onShowCare,
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
