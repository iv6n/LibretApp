/// features > biblioteca > data > reader_block — typed reader blocks for
/// book-content.json's `reader.blocks` (see APP_CONTENT_CONTRACT.md in the
/// content repo: the `reader` layer is the only layer safe to render as-is).
///
/// Block shapes are not covered by the JSON schema (it just says
/// `blocks: array`); they're inferred from the actual generator output
/// (book/tools/generate_book_content.ps1) and verified against every
/// packaged book. Unknown/future block types fall back to [UnknownBlock]
/// instead of throwing, so a content-side addition can't crash the reader.
library;

sealed class ReaderBlock {
  const ReaderBlock();

  factory ReaderBlock.fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String?) {
      case 'heading':
        return HeadingBlock(
          level: (json['level'] as num?)?.toInt() ?? 1,
          text: json['text'] as String? ?? '',
        );
      case 'paragraph':
        return ParagraphBlock(
          text: json['text'] as String? ?? '',
          links: (json['links'] as List<dynamic>? ?? const [])
              .map((e) => ReaderLink.fromJson(e as Map<String, dynamic>))
              .toList(growable: false),
        );
      case 'list':
        return ListBlock(
          ordered: json['ordered'] as bool? ?? false,
          items: (json['items'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .toList(growable: false),
        );
      case 'quote':
        return QuoteBlock(text: json['text'] as String? ?? '');
      case 'table':
        return TableBlock(
          rows: (json['rows'] as List<dynamic>? ?? const [])
              .map(
                (row) => (row as List<dynamic>)
                    .map((cell) => cell.toString())
                    .toList(growable: false),
              )
              .toList(growable: false),
        );
      case 'divider':
        return const DividerBlock();
      case 'figure':
        return FigureBlock(
          path: json['path'] as String? ?? '',
          alt: json['alt'] as String? ?? '',
        );
      case 'metadata':
        return MetadataBlock(
          items: (json['items'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .toList(growable: false),
        );
      default:
        return UnknownBlock(type: json['type'] as String? ?? 'unknown');
    }
  }
}

class HeadingBlock extends ReaderBlock {
  const HeadingBlock({required this.level, required this.text});
  final int level;
  final String text;
}

class ParagraphBlock extends ReaderBlock {
  const ParagraphBlock({required this.text, this.links = const []});
  final String text;
  final List<ReaderLink> links;
}

class ListBlock extends ReaderBlock {
  const ListBlock({required this.ordered, required this.items});
  final bool ordered;
  final List<String> items;
}

class QuoteBlock extends ReaderBlock {
  const QuoteBlock({required this.text});
  final String text;
}

class TableBlock extends ReaderBlock {
  const TableBlock({required this.rows});
  final List<List<String>> rows;

  List<String> get header => rows.isEmpty ? const [] : rows.first;
  List<List<String>> get body => rows.length <= 1 ? const [] : rows.sublist(1);
}

class DividerBlock extends ReaderBlock {
  const DividerBlock();
}

/// An inline figure reference within reader flow. [path] is relative to the
/// book's package directory (e.g. `assets/figures/ranch-layout.svg`),
/// matching [Figure.path] in book_content.dart.
class FigureBlock extends ReaderBlock {
  const FigureBlock({required this.path, required this.alt});
  final String path;
  final String alt;
}

/// Condition/action pairs (flattened as alternating strings) used for things
/// like decision-rule summaries. Consumed as-is; the content repo does not
/// promise stable pairing beyond alternating order.
class MetadataBlock extends ReaderBlock {
  const MetadataBlock({required this.items});
  final List<String> items;
}

class UnknownBlock extends ReaderBlock {
  const UnknownBlock({required this.type});
  final String type;
}

class ReaderLink {
  const ReaderLink({required this.label, required this.url});

  factory ReaderLink.fromJson(Map<String, dynamic> json) => ReaderLink(
    label: json['label'] as String? ?? '',
    url: json['url'] as String? ?? '',
  );

  final String label;
  final String url;
}
