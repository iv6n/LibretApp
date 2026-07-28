import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/biblioteca/cubit/biblioteca_cubit.dart';
import 'package:libretapp/features/biblioteca/data/library_item.dart';
import 'package:libretapp/features/biblioteca/data/library_repository.dart';

class _FakeLibraryRepository implements LibraryRepository {
  bool shouldFail = false;
  String? lastSearchQuery;

  @override
  Future<List<LibraryItem>> byCategory(LibraryCategory category) async =>
      const [];

  @override
  Future<List<LibraryItem>> getAll() async {
    if (shouldFail) throw StateError('boom');
    return const [
      LibraryItem(
        id: 'guide-1',
        title: 'Guía de vacunación',
        summary: 'Calendario recomendado',
        category: LibraryCategory.guides,
        contentType: LibraryContentType.guide,
      ),
    ];
  }

  @override
  Future<List<LibraryItem>> search(String query) async {
    lastSearchQuery = query;
    if (shouldFail) throw StateError('boom');
    return const [
      LibraryItem(
        id: 'guide-2',
        title: 'Resultado de búsqueda',
        summary: 'Coincide con la búsqueda',
        category: LibraryCategory.guides,
        contentType: LibraryContentType.guide,
      ),
    ];
  }
}

void main() {
  late _FakeLibraryRepository repository;
  late BibliotecaCubit cubit;

  setUp(() {
    repository = _FakeLibraryRepository();
    cubit = BibliotecaCubit(libraryRepository: repository);
  });

  tearDown(() => cubit.close());

  test('loads every item when no query is given', () async {
    await cubit.loadBiblioteca();

    expect(cubit.state.status, BibliotecaLoadStatus.loaded);
    expect(cubit.state.items, hasLength(1));
    expect(cubit.state.items.single.id, 'guide-1');
  });

  test('searches when a non-empty query is given', () async {
    await cubit.loadBiblioteca(query: 'vacuna');

    expect(repository.lastSearchQuery, 'vacuna');
    expect(cubit.state.items.single.id, 'guide-2');
    expect(cubit.state.query, 'vacuna');
  });

  test('treats a whitespace-only query as no query (getAll, not search)', () async {
    await cubit.loadBiblioteca(query: '   ');

    expect(repository.lastSearchQuery, isNull);
    expect(cubit.state.items.single.id, 'guide-1');
  });

  test('emits an error state when the repository throws', () async {
    repository.shouldFail = true;

    await cubit.loadBiblioteca();

    expect(cubit.state.status, BibliotecaLoadStatus.error);
    expect(cubit.state.errorMessage, isNotNull);
  });
}
