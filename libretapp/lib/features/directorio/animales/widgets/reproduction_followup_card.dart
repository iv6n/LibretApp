import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_helpers.dart';
import 'package:libretapp/features/registro/view/registro_reproduccion_page.dart'
    show ReproductionInitialStep;

/// The next reproductive action, derived from the records already loaded by
/// the animal detail page. No duplicate state is stored on the animal.
class ReproductionFollowup {
  const ReproductionFollowup({
    required this.status,
    required this.nextDate,
    required this.actionLabel,
    required this.step,
    this.serviceDate,
  });

  final String status;
  final String? nextDate;
  final String actionLabel;
  final ReproductionInitialStep step;
  final DateTime? serviceDate;

  static bool supports(AnimalEntity animal) =>
      animal.sex == Sex.female &&
      {Species.cattle, Species.sheep, Species.goat}.contains(animal.species);

  static ReproductionFollowup from(
    AnimalEntity animal,
    List<ReproductionRecord> records,
  ) {
    final latest = ReproductiveKpiService.latestCycleOf(records);
    if (latest == null) {
      return const ReproductionFollowup(
        status: 'Sin montas registradas',
        nextDate: 'Registra una monta para iniciar el seguimiento.',
        actionLabel: 'Registrar monta',
        step: ReproductionInitialStep.service,
      );
    }
    final serviceDate = latest.serviceDate;
    if (latest.hasCalved) {
      return ReproductionFollowup(
        serviceDate: serviceDate,
        status: 'Último parto: ${formatDate(latest.actualCalvingDate)}',
        nextDate: 'El registro del parto está en Registros.',
        actionLabel: 'Registrar nueva monta',
        step: ReproductionInitialStep.service,
      );
    }
    if (latest.pregnancyResult == PregnancyCheckResult.negative) {
      return ReproductionFollowup(
        serviceDate: serviceDate,
        status: 'Resultado: no preñada',
        nextDate: 'Puedes registrar una nueva monta.',
        actionLabel: 'Registrar nueva monta',
        step: ReproductionInitialStep.service,
      );
    }
    final schedule = serviceDate == null
        ? null
        : const ReproductionScheduler().estimate(
            serviceDate: serviceDate,
            species: animal.species,
          );
    if (latest.pregnancyResult == PregnancyCheckResult.positive) {
      final due = latest.expectedCalvingDate ?? schedule?.dueDate;
      return ReproductionFollowup(
        serviceDate: serviceDate,
        status: 'Preñez confirmada',
        nextDate: due == null ? null : 'Parto estimado: ${formatDate(due)}',
        actionLabel: 'Registrar parto',
        step: ReproductionInitialStep.calving,
      );
    }
    final uncertain = latest.pregnancyResult == PregnancyCheckResult.uncertain;
    final check = latest.pregnancyCheckDate ?? schedule?.pregnancyCheckDate;
    final due = latest.expectedCalvingDate ?? schedule?.dueDate;
    return ReproductionFollowup(
      serviceDate: serviceDate,
      status: uncertain
          ? 'Resultado dudoso: repetir chequeo'
          : 'Preñez: sin confirmar',
      nextDate: [
        if (check != null)
          '${uncertain ? 'Último chequeo' : 'Revisar preñez'}: ${formatDate(check)}',
        if (due != null)
          'Parto estimado si se confirma la preñez: ${formatDate(due)}',
      ].join('\n'),
      actionLabel: 'Registrar resultado de preñez',
      step: ReproductionInitialStep.diagnosis,
    );
  }
}

class ReproductionFollowupCard extends StatelessWidget {
  const ReproductionFollowupCard({
    super.key,
    required this.animal,
    required this.records,
    required this.onAction,
    required this.onShowRecords,
  });

  final AnimalEntity animal;
  final List<ReproductionRecord> records;
  final ValueChanged<ReproductionInitialStep> onAction;
  final VoidCallback onShowRecords;

  @override
  Widget build(BuildContext context) {
    final followup = ReproductionFollowup.from(animal, records);
    final canRecord =
        animal.status.isInActiveHerd &&
        animal.reproductiveStatus != ReproductiveStatus.neutered &&
        animal.reproductiveStatus != ReproductiveStatus.retired;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monta y preñez', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            if (followup.serviceDate != null)
              Text(
                'Última monta: ${formatDate(followup.serviceDate)}',
                style: theme.textTheme.bodyLarge,
              ),
            Text(followup.status, style: theme.textTheme.bodyLarge),
            if (followup.nextDate != null) ...[
              const SizedBox(height: 8),
              Text(followup.nextDate!, style: theme.textTheme.bodyLarge),
            ],
            const SizedBox(height: 12),
            if (canRecord)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                  onPressed: () => onAction(followup.step),
                  child: Text(
                    followup.actionLabel,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (records.isNotEmpty)
              TextButton.icon(
                onPressed: onShowRecords,
                icon: const Icon(Icons.history),
                label: const Text('Ver registros anteriores'),
              ),
          ],
        ),
      ),
    );
  }
}
