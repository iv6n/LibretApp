/// features > biblioteca > view > chapter_reader_page — renders one chapter
/// or appendix: its reader blocks, plus the additive regional adaptation
/// box resolved from the reader's profile (see adaptive_resolver.dart).
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:libretapp/app/widgets/shell_insets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/biblioteca/data/book_content.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';
import 'package:libretapp/features/biblioteca/data/region_catalog.dart';
import 'package:libretapp/features/biblioteca/domain/adaptive_resolver.dart';
import 'package:libretapp/features/biblioteca/widgets/adaptation_box.dart';
import 'package:libretapp/features/biblioteca/widgets/reader_block_view.dart';
import 'package:libretapp/features/perfil/bloc/perfil_bloc.dart';
import 'package:libretapp/features/perfil/bloc/perfil_event.dart';
import 'package:libretapp/features/perfil/bloc/perfil_state.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:libretapp/theme/app_theme.dart';

/// Everything [ChapterReaderPage] needs, already loaded by whoever
/// navigated here (normally BookDetailPage, which already holds the full
/// [BookContent] in memory — no reason to reload it per chapter).
class ChapterReaderArgs {
  const ChapterReaderArgs({
    required this.book,
    required this.content,
    required this.unit,
  });

  final LibraryManifestBook book;
  final BookContent content;
  final ContentUnit unit;
}

class ChapterReaderPage extends StatefulWidget {
  const ChapterReaderPage({required this.args, super.key});

  final ChapterReaderArgs args;

  @override
  State<ChapterReaderPage> createState() => _ChapterReaderPageState();
}

class _ChapterReaderPageState extends State<ChapterReaderPage> {
  RegionCatalog? _regionCatalog;

  @override
  void initState() {
    super.initState();
    _loadRegionCatalog();
  }

  Future<void> _loadRegionCatalog() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/library/mexico-regions.json',
      );
      if (!mounted) return;
      setState(() {
        _regionCatalog = RegionCatalog.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      });
    } catch (_) {
      // Region catalog is optional for reading: without it every profile
      // resolves via state-match or the general fallback (precedence #1
      // and #4 in ADAPTIVE_CONTENT.md still work; only #2, the climate
      // region step, is skipped).
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PerfilBloc(locator<PerfilRepository>())..add(const LoadPerfil()),
      child: _ChapterReaderView(
        args: widget.args,
        regionCatalog: _regionCatalog,
      ),
    );
  }
}

class _ChapterReaderView extends StatelessWidget {
  const _ChapterReaderView({required this.args, required this.regionCatalog});

  final ChapterReaderArgs args;
  final RegionCatalog? regionCatalog;

  @override
  Widget build(BuildContext context) {
    final book = args.book;
    final unit = args.unit;
    final adaptive = args.content.adaptive;

    return Scaffold(
      appBar: AppBar(title: Text(unit.title)),
      body: BlocBuilder<PerfilBloc, PerfilState>(
        builder: (context, perfilState) {
          final profile = _resolveProfile(perfilState);

          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md + ShellInsets.bottomSafePadding(context),
            ),
            children: [
              if (adaptive != null)
                Builder(
                  builder: (context) {
                    final chapterAdaptations = adaptive.regionalAdaptations
                        .forChapter(unit.path);
                    if (chapterAdaptations == null) {
                      return const SizedBox.shrink();
                    }
                    const resolver = AdaptiveResolver();
                    final entry = resolver.resolveAdaptation(
                      chapterAdaptations,
                      profile,
                    );
                    if (entry == null) return const SizedBox.shrink();
                    final tips = resolver.resolveTaskTips(
                      adaptive.taskTips.forChapter(unit.path),
                      profile,
                    );
                    return AdaptationBox(entry: entry, taskTips: tips);
                  },
                ),
              ReaderBlockView(
                blocks: unit.reader.blocks,
                figureAssetPath: book.assetPath,
              ),
            ],
          );
        },
      ),
    );
  }

  ReaderProfile _resolveProfile(PerfilState perfilState) {
    if (perfilState is! PerfilLoaded) return ReaderProfile.general;
    final perfil = perfilState.perfil;
    final catalog = regionCatalog;
    return ReaderProfile(
      state: perfil.regionState,
      climateRegions: catalog == null
          ? const ['general']
          : catalog.climateRegionsForState(perfil.regionState),
      productionSetting: perfil.productionSetting,
    );
  }
}
