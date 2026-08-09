/// Barrel — biblioteca feature
///
/// The "book of books" library: 7 subject books bundled from the content
/// repo (assets/library/), the cubits that load the catalog and individual
/// books, the adaptive-content resolver, and the UI (catalog, book detail,
/// chapter reader). Physically independent of perfil/**, though it's
/// currently rendered as a tab inside Perfil's UI.
library;

export 'cubit/biblioteca_cubit.dart';
export 'cubit/book_detail_cubit.dart';
export 'data/book_content.dart';
export 'data/library_manifest.dart';
export 'data/library_repository.dart';
export 'data/reader_block.dart';
export 'data/region_catalog.dart';
export 'domain/adaptive_resolver.dart';
export 'view/biblioteca_tab.dart';
export 'view/book_detail_page.dart';
export 'view/chapter_reader_page.dart';
export 'widgets/adaptation_box.dart';
export 'widgets/library_book_card.dart';
export 'widgets/reader_block_view.dart';
