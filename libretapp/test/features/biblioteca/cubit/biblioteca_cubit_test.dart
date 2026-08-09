import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/biblioteca/cubit/biblioteca_cubit.dart';
import 'package:libretapp/features/biblioteca/data/book_content.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';
import 'package:libretapp/features/biblioteca/data/library_repository.dart';

const _adaptive = LibraryAdaptiveSummary(enabled: false, supportedRegions: []);

class _FakeLibraryRepository implements LibraryRepository {
  bool shouldFail = false;
  String? lastSearchQuery;

  @override
  Future<List<LibraryManifestBook>> getAll() async {
    if (shouldFail) throw StateError('boom');
    return const [
      LibraryManifestBook(
        bookId: 'bovinos',
        subject: 'bovinos',
        packageDir: 'bovinos',
        title: 'Guía de vacunación',
        subtitle: 'Calendario recomendado',
        description: 'Calendario recomendado',
        language: 'es',
        translationStatus: 'publication_ready',
        tags: [],
        stats: {},
        adaptive: _adaptive,
        contentPath: 'content/book-content.json',
      ),
    ];
  }

  @override
  Future<List<LibraryManifestBook>> search(String query) async {
    lastSearchQuery = query;
    if (shouldFail) throw StateError('boom');
    return const [
      LibraryManifestBook(
        bookId: 'caprinos',
        subject: 'caprinos',
        packageDir: 'caprinos',
        title: 'Resultado de búsqueda',
        subtitle: 'Coincide con la búsqueda',
        description: 'Coincide con la búsqueda',
        language: 'es',
        translationStatus: 'publication_ready',
        tags: [],
        stats: {},
        adaptive: _adaptive,
        contentPath: 'content/book-content.json',
      ),
    ];
  }

  @override
  Future<BookContent> loadBookContent(LibraryManifestBook book) {
    throw UnimplementedError('not exercised by BibliotecaCubit tests');
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

  test('loads every book when no query is given', () async {
    await cubit.loadBiblioteca();

    expect(cubit.state.status, BibliotecaLoadStatus.loaded);
    expect(cubit.state.books, hasLength(1));
    expect(cubit.state.books.single.bookId, 'bovinos');
  });

  test('searches when a non-empty query is given', () async {
    await cubit.loadBiblioteca(query: 'vacuna');

    expect(repository.lastSearchQuery, 'vacuna');
    expect(cubit.state.books.single.bookId, 'caprinos');
    expect(cubit.state.query, 'vacuna');
  });

  test('treats a whitespace-only query as no query (getAll, not search)', () async {
    await cubit.loadBiblioteca(query: '   ');

    expect(repository.lastSearchQuery, isNull);
    expect(cubit.state.books.single.bookId, 'bovinos');
  });

  test('emits an error state when the repository throws', () async {
    repository.shouldFail = true;

    await cubit.loadBiblioteca();

    expect(cubit.state.status, BibliotecaLoadStatus.error);
    expect(cubit.state.errorMessage, isNotNull);
  });
}
