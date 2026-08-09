/// features > biblioteca > cubit > biblioteca_cubit — loads the book-of-books
/// library catalog for the biblioteca tab.
///
/// Split out of the old shared `PerfilTabsCubit`, which mixed biblioteca,
/// reportes, and finanzas concerns in one class — reportes now has its own
/// `ReportesCubit`. This one only knows about the library. Physically
/// independent of perfil/** (own feature package), even though today it's
/// still rendered as a tab inside Perfil's UI.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';
import 'package:libretapp/features/biblioteca/data/library_repository.dart';

enum BibliotecaLoadStatus { initial, loading, loaded, error }

class BibliotecaState extends Equatable {
  const BibliotecaState({
    this.status = BibliotecaLoadStatus.initial,
    this.books = const [],
    this.query = '',
    this.errorMessage,
  });

  final BibliotecaLoadStatus status;
  final List<LibraryManifestBook> books;
  final String query;
  final String? errorMessage;

  BibliotecaState copyWith({
    BibliotecaLoadStatus? status,
    List<LibraryManifestBook>? books,
    String? query,
    String? errorMessage,
  }) {
    return BibliotecaState(
      status: status ?? this.status,
      books: books ?? this.books,
      query: query ?? this.query,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, books, query, errorMessage];
}

class BibliotecaCubit extends Cubit<BibliotecaState> {
  BibliotecaCubit({required LibraryRepository libraryRepository})
    : _libraryRepository = libraryRepository,
      super(const BibliotecaState());

  final LibraryRepository _libraryRepository;

  Future<void> loadBiblioteca({String query = ''}) async {
    emit(state.copyWith(status: BibliotecaLoadStatus.loading, query: query));
    try {
      final books = query.trim().isEmpty
          ? await _libraryRepository.getAll()
          : await _libraryRepository.search(query);
      emit(state.copyWith(status: BibliotecaLoadStatus.loaded, books: books));
    } catch (e) {
      emit(
        state.copyWith(
          status: BibliotecaLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
