import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_bloc.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_event.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_state.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

class _FakeLotesRepository implements LotesRepository {
  @override
  Future<LoteEntity> createLote({
    required String nombre,
    String? descripcion,
    String? notas,
  }) async {
    final now = DateTime.now();
    return LoteEntity(
      uuid: 'new-lote',
      name: nombre,
      description: descripcion ?? '',
      animalUuids: const [],
      createdAt: now,
      closedAt: null,
      active: true,
      notes: notas,
      lastUpdateDate: now,
      synced: false,
      remoteId: null,
      syncDate: null,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _flushEvents() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(const Duration(milliseconds: 20));
}

void main() {
  test(
    'a mutating event dispatched before LotesLoaded emits a visible error '
    'instead of silently doing nothing',
    () async {
      final bloc = LotesBloc(_FakeLotesRepository());
      addTearDown(bloc.close);

      expect(bloc.state, isA<LotesInitial>());

      bloc.add(const CreateLote(name: 'Lote nuevo'));
      await _flushEvents();

      expect(
        bloc.state,
        isA<LotesError>(),
        reason:
            'a caller awaiting the next settled state (e.g. a form page '
            'using the same _dispatchAndAwait pattern as LoteFormPage) '
            'must not hang forever waiting for a state that never arrives',
      );
    },
  );
}
