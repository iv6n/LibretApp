/// features > biblioteca > cubit > book_detail_cubit — loads one book's full
/// compiled content (chapters, glossary, adaptive data, operational tools)
/// when the reader opens it from the library catalog.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/biblioteca/data/book_content.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';
import 'package:libretapp/features/biblioteca/data/library_repository.dart';

enum BookDetailStatus { loading, loaded, error }

class BookDetailState extends Equatable {
  const BookDetailState({
    required this.status,
    this.manifestBook,
    this.content,
    this.errorMessage,
  });

  final BookDetailStatus status;
  final LibraryManifestBook? manifestBook;
  final BookContent? content;
  final String? errorMessage;

  BookDetailState copyWith({
    BookDetailStatus? status,
    LibraryManifestBook? manifestBook,
    BookContent? content,
    String? errorMessage,
  }) {
    return BookDetailState(
      status: status ?? this.status,
      manifestBook: manifestBook ?? this.manifestBook,
      content: content ?? this.content,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, manifestBook, content, errorMessage];
}

/// Loads a book by [bookId]. If the caller already has the
/// [LibraryManifestBook] in hand (navigating from the catalog list), pass it
/// as [initialManifestBook] to skip re-fetching the manifest; a direct deep
/// link with only an id still resolves it by looking the id up in the
/// catalog.
class BookDetailCubit extends Cubit<BookDetailState> {
  BookDetailCubit({
    required LibraryRepository libraryRepository,
    required String bookId,
    LibraryManifestBook? initialManifestBook,
  }) : _libraryRepository = libraryRepository,
       _bookId = bookId,
       super(
         BookDetailState(
           status: BookDetailStatus.loading,
           manifestBook: initialManifestBook,
         ),
       ) {
    _load();
  }

  final LibraryRepository _libraryRepository;
  final String _bookId;

  Future<void> _load() async {
    try {
      var manifestBook = state.manifestBook;
      if (manifestBook == null) {
        final books = await _libraryRepository.getAll();
        for (final candidate in books) {
          if (candidate.bookId == _bookId) {
            manifestBook = candidate;
            break;
          }
        }
        if (manifestBook == null) {
          emit(
            state.copyWith(
              status: BookDetailStatus.error,
              errorMessage: 'Libro no encontrado: $_bookId',
            ),
          );
          return;
        }
      }
      final content = await _libraryRepository.loadBookContent(manifestBook);
      emit(
        state.copyWith(
          status: BookDetailStatus.loaded,
          manifestBook: manifestBook,
          content: content,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BookDetailStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
