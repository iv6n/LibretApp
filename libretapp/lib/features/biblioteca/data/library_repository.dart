/// features > biblioteca > data > library_repository — loads the "book of
/// books" catalog and individual book content from the bundled assets
/// synced by tool/sync_library_assets.ps1 (see assets/library/).
library;

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:libretapp/features/biblioteca/data/book_content.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';

abstract class LibraryRepository {
  /// The full "book of books" catalog — one entry per subject book.
  Future<List<LibraryManifestBook>> getAll();

  /// Filters the catalog by title/subtitle/description/tags.
  Future<List<LibraryManifestBook>> search(String query);

  /// Loads a single book's full compiled content (chapters, glossary,
  /// adaptive data, operational tools). Lazy — call only when the reader
  /// actually opens a book, not for the catalog listing.
  Future<BookContent> loadBookContent(LibraryManifestBook book);
}

class AssetLibraryRepository implements LibraryRepository {
  AssetLibraryRepository();

  static const _manifestAssetPath = 'assets/library/library.json';

  List<LibraryManifestBook>? _cachedBooks;
  final Map<String, BookContent> _contentCache = {};

  Future<List<LibraryManifestBook>> _loadManifest() async {
    final cached = _cachedBooks;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(_manifestAssetPath);
    final manifest = LibraryManifest.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    _cachedBooks = manifest.books;
    return manifest.books;
  }

  @override
  Future<List<LibraryManifestBook>> getAll() => _loadManifest();

  @override
  Future<List<LibraryManifestBook>> search(String query) async {
    final books = await _loadManifest();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return books;
    return books
        .where(
          (book) =>
              book.title.toLowerCase().contains(q) ||
              book.subtitle.toLowerCase().contains(q) ||
              book.description.toLowerCase().contains(q) ||
              book.tags.any((t) => t.toLowerCase().contains(q)),
        )
        .toList(growable: false);
  }

  @override
  Future<BookContent> loadBookContent(LibraryManifestBook book) async {
    final cached = _contentCache[book.bookId];
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(book.contentAssetPath);
    final content = BookContent.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    _contentCache[book.bookId] = content;
    return content;
  }
}
