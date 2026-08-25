import 'package:flutter/material.dart';
import 'package:libretapp/features/agenda/domain/agenda_registration.dart';
import 'package:libretapp/features/agenda/domain/agenda_task_grouping.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_presentation.dart';

/// Compact, traceable view of the records already saved for an Agenda task.
class AgendaRegistrationTable extends StatelessWidget {
  const AgendaRegistrationTable({
    required this.rows,
    required this.detailsByRow,
    required this.animalsById,
    this.onEdit,
    super.key,
  });

  final List<AgendaTaskRow> rows;
  final Map<String, AgendaRegistrationDetail> detailsByRow;
  final Map<String, AnimalEntity> animalsById;
  final Future<void> Function(
    AgendaTaskRow row,
    AgendaRegistrationDetail detail,
  )?
  onEdit;

  List<_RegistrationRow> get _registeredRows {
    final result = <_RegistrationRow>[];
    for (final row in rows) {
      final detail =
          detailsByRow[agendaRegistrationRowKey(row.entry.id, row.animalId)];
      if (detail != null) {
        result.add(_RegistrationRow(row, detail));
      } else if (row.isCompleted) {
        final now = DateTime.now();
        result.add(
          _RegistrationRow(
            row,
            AgendaRegistrationDetail(
              registration: AgendaRegistration(
                id: 'missing:${row.entry.id}:${row.animalId ?? 'general'}',
                batchId: '',
                entryId: row.entry.id,
                eventKey: row.entry.id,
                animalId: row.animalId,
                kind: registrationKindForEntry(row.entry),
                performedAt: now,
                createdAt: now,
                updatedAt: now,
              ),
              summary: 'Completado sin detalle',
              fields: const {'Estado': 'Completado sin detalle'},
            ),
          ),
        );
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _registeredRows;
    if (entries.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final kind = entries.first.detail.registration.kind;
    final fields = _fieldColumns(kind);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registros guardados',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                key: const ValueKey('agenda-registration-table'),
                columnSpacing: 22,
                headingRowHeight: 38,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 62,
                columns: [
                  const DataColumn(label: Text('Animal')),
                  for (final field in fields) DataColumn(label: Text(field)),
                  if (onEdit != null) const DataColumn(label: Text('')),
                ],
                rows: [
                  for (final entry in entries)
                    DataRow(
                      cells: [
                        DataCell(Text(_animalLabel(entry.row.animalId))),
                        for (final field in fields)
                          DataCell(
                            Text(
                              entry.detail.fields[field] ?? '—',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (onEdit != null)
                          DataCell(
                            IconButton(
                              key: ValueKey(
                                'agenda-registration-edit-${entry.detail.registration.id}',
                              ),
                              tooltip: 'Editar',
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () => onEdit!(entry.row, entry.detail),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _fieldColumns(AgendaRegistrationKind kind) => switch (kind) {
    AgendaRegistrationKind.health => const ['Producto', 'Dosis', 'Fecha'],
    AgendaRegistrationKind.weight => const ['Peso', 'Método', 'Fecha'],
    AgendaRegistrationKind.movement => const ['Destino', 'Motivo', 'Fecha'],
    AgendaRegistrationKind.reproduction => const [
      'Evento',
      'Resultado',
      'Fecha',
    ],
    AgendaRegistrationKind.general => const ['Responsable', 'Fecha', 'Notas'],
  };

  String _animalLabel(String? animalId) {
    if (animalId == null) return 'Tarea general';
    final animal = animalsById[animalId];
    if (animal == null) return animalId;
    return primaryAnimalLabel(animal);
  }
}

class _RegistrationRow {
  const _RegistrationRow(this.row, this.detail);

  final AgendaTaskRow row;
  final AgendaRegistrationDetail detail;
}
