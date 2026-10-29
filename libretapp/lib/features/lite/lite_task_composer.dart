import 'package:uuid/uuid.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';

/// Converts the schedule entered by the user into independent Agenda entries.
class LiteTaskComposer {
  const LiteTaskComposer._();

  static List<AgendaEntry> compose({
    required String title,
    required String notes,
    required String type,
    required DateTime firstAt,
    required int doses,
    required int intervalHours,
    String? petUuid,
    String? plantUuid,
    String? planId,
  }) {
    final groupId = planId ?? const Uuid().v4();
    final created = DateTime.now();
    return List.generate(doses, (index) {
      final when = firstAt.add(Duration(hours: index * intervalHours));
      return AgendaEntry(
        id: const Uuid().v4(),
        titulo: doses > 1 ? '$title · toma ${index + 1}/$doses' : title,
        descripcion: notes,
        fecha: when,
        tipo: type,
        animalIds: petUuid == null ? const [] : [petUuid],
        loteIds: const [],
        cropUuid: plantUuid,
        ubicacion: '',
        estado: AgendaEstado.pendiente,
        completedAnimalIds: const [],
        notas: notes,
        createdAt: created,
        updatedAt: created,
        remindAt: when,
        sourceType: 'lite',
        sourceId: groupId,
        planId: groupId,
        actionKind: type == 'Medicamento' ? 'petDose' : 'liteReminder',
      );
    });
  }
}
