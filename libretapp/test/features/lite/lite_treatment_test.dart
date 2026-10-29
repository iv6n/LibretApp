import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/lite/lite_task_composer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'cada toma tiene fecha e identidad propia y se confirma sin afectar las demás',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repository = AgendaRepositoryImpl(
        SharedPrefsService(await SharedPreferences.getInstance()),
      );
      final firstAt = DateTime(2030, 1, 5, 8);
      final entries = LiteTaskComposer.compose(
        title: 'Medicamento de Mora',
        notes: 'Según receta',
        type: 'Medicamento',
        firstAt: firstAt,
        doses: 3,
        intervalHours: 8,
        petUuid: 'pet-1',
        planId: 'plan-1',
      );
      expect(entries.map((e) => e.fecha), [
        firstAt,
        DateTime(2030, 1, 5, 16),
        DateTime(2030, 1, 6),
      ]);
      expect(entries.map((e) => e.id).toSet(), hasLength(3));
      expect(
        entries.every((e) => e.planId == 'plan-1' && e.sourceType == 'lite'),
        isTrue,
      );
      await repository.saveEntries(entries);
      final first = await repository.getEntry(entries.first.id);
      await repository.updateEntry(
        first.copyWith(
          estado: AgendaEstado.completado,
          fechaCompletado: DateTime(2030, 1, 5, 8, 10),
        ),
      );
      final restored = await repository.fetchEntries();
      expect(
        restored.where((e) => e.estado == AgendaEstado.completado),
        hasLength(1),
      );
      expect(
        restored.where((e) => e.estado == AgendaEstado.pendiente),
        hasLength(2),
      );
    },
  );
}
