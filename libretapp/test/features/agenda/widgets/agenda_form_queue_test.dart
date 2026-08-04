import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/widgets/agenda_form_queue.dart';

void main() {
  group('runAgendaFormQueue', () {
    test('éxito total: llama onStepSuccess por cada uuid en orden', () async {
      final pushed = <String>[];
      final succeeded = <String>[];

      final completed = await runAgendaFormQueue<bool>(
        animalUuids: ['a', 'b', 'c'],
        pushStep: (uuid, index, total) async {
          pushed.add(uuid);
          return true;
        },
        isSuccess: (r) => r == true,
        onStepSuccess: succeeded.add,
      );

      expect(pushed, ['a', 'b', 'c']);
      expect(succeeded, ['a', 'b', 'c']);
      expect(completed, ['a', 'b', 'c']);
    });

    test('corta en el primer fallo, no sigue con los siguientes', () async {
      final pushed = <String>[];
      final results = [true, false, true];
      var i = 0;

      final completed = await runAgendaFormQueue<bool>(
        animalUuids: ['a', 'b', 'c'],
        pushStep: (uuid, index, total) async {
          pushed.add(uuid);
          return results[i++];
        },
        isSuccess: (r) => r == true,
        onStepSuccess: (_) {},
      );

      expect(pushed, ['a', 'b'], reason: 'c nunca debería empujarse');
      expect(completed, ['a']);
    });

    test('un resultado null cuenta como fallo (cancelado)', () async {
      final completed = await runAgendaFormQueue<bool>(
        animalUuids: ['a'],
        pushStep: (uuid, index, total) async => null,
        isSuccess: (r) => r == true,
        onStepSuccess: (_) {},
      );

      expect(completed, isEmpty);
    });

    test('lista vacía no hace nada', () async {
      var calls = 0;
      final completed = await runAgendaFormQueue<bool>(
        animalUuids: const [],
        pushStep: (uuid, index, total) async {
          calls++;
          return true;
        },
        isSuccess: (r) => r == true,
        onStepSuccess: (_) {},
      );

      expect(calls, 0);
      expect(completed, isEmpty);
    });

    test('shouldContinue en false corta el loop antes del siguiente paso', () async {
      final pushed = <String>[];

      final completed = await runAgendaFormQueue<bool>(
        animalUuids: ['a', 'b', 'c'],
        pushStep: (uuid, index, total) async {
          pushed.add(uuid);
          return true;
        },
        isSuccess: (r) => r == true,
        onStepSuccess: (_) {},
        shouldContinue: () => pushed.length < 2,
      );

      expect(pushed, ['a', 'b']);
      expect(completed, ['a', 'b']);
    });

    test('pushStep recibe el índice y el total correctos', () async {
      final seen = <String>[];

      await runAgendaFormQueue<bool>(
        animalUuids: ['a', 'b'],
        pushStep: (uuid, index, total) async {
          seen.add('$uuid:$index/$total');
          return true;
        },
        isSuccess: (r) => r == true,
        onStepSuccess: (_) {},
      );

      expect(seen, ['a:0/2', 'b:1/2']);
    });
  });
}
