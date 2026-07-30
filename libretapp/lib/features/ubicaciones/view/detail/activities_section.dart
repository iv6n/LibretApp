part of '../location_detail_widgets.dart';

// ─── ActivitiesSection ────────────────────────────────────────────────────────

class ActivitiesSection extends StatelessWidget {
  const ActivitiesSection({super.key, 
    required this.location,
    required this.allLocations,
  });

  final LocationEntity location;
  final List<LocationEntity> allLocations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AgendaBloc, AgendaState>(
      builder: (context, state) {
        final entries = state is AgendaLoaded
            ? state.entries
                  .where((e) => e.locationUuid == location.uuid)
                  .toList()
            : <AgendaEntry>[];

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
                        'Actividades',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Icon(Icons.event_note_outlined),
                  ],
                ),
                const SizedBox(height: 12),
                if (state is AgendaLoading)
                  const Center(child: CircularProgressIndicator())
                else if (entries.isEmpty)
                  Text(
                    'Sin actividades programadas.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  ...entries.map((entry) => _AgendaEntryTile(entry: entry)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Agregar actividad'),
                    onPressed: () => _showAddActivity(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddActivity(BuildContext context) {
    final bloc = context.read<AgendaBloc>();
    showAgendaFormSheet(
      context: context,
      initialDate: DateTime.now(),
      locations: allLocations,
      entry: AgendaEntry(
        id: '',
        titulo: '',
        descripcion: '',
        fecha: DateTime.now(),
        tipo: 'General',
        animalIds: const [],
        loteIds: const [],
        ubicacion: location.name,
        estado: AgendaEstado.pendiente,
        completedAnimalIds: const [],
        notas: '',
        locationUuid: location.uuid,
      ),
      onSave: (saved) {
        bloc.add(AddAgendaEntry(saved.copyWith(id: generateId())));
      },
    );
  }
}

// ─── AgendaEntryTile ──────────────────────────────────────────────────────────

class _AgendaEntryTile extends StatelessWidget {
  const _AgendaEntryTile({required this.entry});

  final AgendaEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = entry.estado == AgendaEstado.completado;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_outline
                  : Icons.radio_button_unchecked,
              size: 18,
              color: isCompleted
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.titulo,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '${entry.tipo} · '
                  '${entry.fecha.day.toString().padLeft(2, '0')}/'
                  '${entry.fecha.month.toString().padLeft(2, '0')}/'
                  '${entry.fecha.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

