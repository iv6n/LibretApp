import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/biblioteca/data/book_content.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';
import 'package:libretapp/features/biblioteca/data/reader_block.dart';

void main() {
  group('LibraryManifest.fromJson', () {
    test('parses the bundled library.json with all 7 books', () {
      final raw = File('assets/library/library.json').readAsStringSync();
      final manifest = LibraryManifest.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );

      expect(manifest.books, hasLength(7));
      expect(
        manifest.books.map((b) => b.bookId).toSet(),
        {
          'agriculture',
          'bovinos',
          'caprinos',
          'equinos',
          'mascotas',
          'suelos',
          'ovinos',
        },
      );
      for (final book in manifest.books) {
        expect(book.title, isNotEmpty);
        expect(book.adaptive.enabled, isTrue);
        expect(book.adaptive.supportedRegions, isNotEmpty);
      }
    });
  });

  group('BookContent.fromJson', () {
    late BookContent bovinos;

    setUpAll(() {
      final raw = File(
        'assets/library/bovinos/content/book-content.json',
      ).readAsStringSync();
      bovinos = BookContent.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    });

    test('parses top-level book metadata', () {
      expect(bovinos.bookId, 'bovinos');
      expect(bovinos.language, 'es');
      expect(bovinos.translationStatus, 'publication_ready');
      expect(bovinos.chapters, hasLength(30));
      expect(bovinos.appendices, hasLength(1));
      expect(bovinos.glossary.terms, isNotEmpty);
    });

    test('parses every reader block in every chapter without UnknownBlock', () {
      final unknownTypes = <String>{};
      for (final unit in [...bovinos.chapters, ...bovinos.appendices]) {
        expect(unit.reader.blocks, isNotEmpty, reason: unit.path);
        for (final block in unit.reader.blocks) {
          if (block is UnknownBlock) unknownTypes.add(block.type);
        }
      }
      expect(
        unknownTypes,
        isEmpty,
        reason: 'Unrecognized block types found: $unknownTypes',
      );
    });

    test('resolves adaptive regional adaptations for chapter 1', () {
      final adaptive = bovinos.adaptive;
      expect(adaptive, isNotNull);
      expect(adaptive!.pilotState, 'sonora');

      final chapterAdaptations =
          adaptive.regionalAdaptations.forChapter('ch-01.md');
      expect(chapterAdaptations, isNotNull);

      final hasGeneralFallback = chapterAdaptations!.adaptations.any(
        (a) => a.states.contains('general'),
      );
      final hasSonora = chapterAdaptations.adaptations.any(
        (a) => a.states.contains('sonora'),
      );
      expect(hasGeneralFallback, isTrue);
      expect(hasSonora, isTrue);
    });

    test('operational tools carry checklists and typed record fields', () {
      expect(bovinos.operational.checklists, isNotEmpty);
      expect(bovinos.operational.records, isNotEmpty);
      final treatment = bovinos.operational.records.firstWhere(
        (r) => r.id == 'cattle_treatment',
      );
      expect(treatment.fields, isNotEmpty);
      expect(treatment.fields.first.id, isNotEmpty);
    });

    test('figure blocks resolve to files that exist under the asset base', () {
      for (final figure in bovinos.figures) {
        final file = File('assets/library/bovinos/${figure.path}');
        expect(file.existsSync(), isTrue, reason: figure.path);
      }
    });
  });

  group('BookContent.fromJson across the whole library', () {
    late LibraryManifest manifest;

    setUpAll(() {
      final raw = File('assets/library/library.json').readAsStringSync();
      manifest = LibraryManifest.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    });

    test('every book parses with no unknown block types and all figures present', () {
      for (final book in manifest.books) {
        final raw = File(book.contentAssetPath).readAsStringSync();
        final content = BookContent.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );

        final unknownTypes = <String>{};
        for (final unit in [...content.chapters, ...content.appendices]) {
          for (final block in unit.reader.blocks) {
            if (block is UnknownBlock) unknownTypes.add(block.type);
          }
        }
        expect(unknownTypes, isEmpty, reason: '${book.bookId}: $unknownTypes');

        for (final figure in content.figures) {
          final file = File('assets/library/${book.packageDir}/${figure.path}');
          expect(
            file.existsSync(),
            isTrue,
            reason: '${book.bookId}: ${figure.path}',
          );
        }
      }
    });
  });
}
