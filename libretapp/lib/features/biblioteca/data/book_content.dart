/// features > biblioteca > data > book_content — Dart mirror of the
/// `libretapp-content` schema (book/schemas/libretapp-content.schema.json,
/// schema_version 1.0) produced per book at content/book-content.json.
///
/// Per APP_CONTENT_CONTRACT.md in the content repo: `reader` is the only
/// layer safe to render as text; `machine`/`operational`/`adaptive` carry
/// structured data (rules, decisions, alerts, checklists, records, regional
/// adaptations) for app logic, never as raw text.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/biblioteca/data/reader_block.dart';

class Reader {
  const Reader({required this.blocks});

  factory Reader.fromJson(Map<String, dynamic> json) => Reader(
    blocks: (json['blocks'] as List<dynamic>? ?? const [])
        .map((e) => ReaderBlock.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
  );

  final List<ReaderBlock> blocks;
}

/// A figure declared at chapter/book level: `{id, path, title, alt_text}`.
/// [path] is relative to the book's package dir, e.g. `assets/figures/x.svg`.
class Figure extends Equatable {
  const Figure({
    required this.id,
    required this.path,
    required this.title,
    required this.altText,
  });

  factory Figure.fromJson(Map<String, dynamic> json) => Figure(
    id: json['id'] as String? ?? '',
    path: json['path'] as String? ?? '',
    title: json['title'] as String? ?? '',
    altText: json['alt_text'] as String? ?? '',
  );

  final String id;
  final String path;
  final String title;
  final String altText;

  @override
  List<Object?> get props => [id, path, title, altText];
}

class GlossaryTerm {
  const GlossaryTerm({required this.term, required this.definition});

  factory GlossaryTerm.fromJson(Map<String, dynamic> json) => GlossaryTerm(
    term: json['term'] as String? ?? '',
    definition: json['definition'] as String? ?? '',
  );

  final String term;
  final String definition;
}

class Glossary {
  const Glossary({required this.terms, required this.reader});

  factory Glossary.fromJson(Map<String, dynamic> json) => Glossary(
    terms: (json['terms'] as List<dynamic>? ?? const [])
        .map((e) => GlossaryTerm.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    reader: Reader.fromJson(
      json['reader'] as Map<String, dynamic>? ?? const {},
    ),
  );

  final List<GlossaryTerm> terms;
  final Reader reader;
}

/// A single `machine` entry: `{id, kind, text, source_path}`. `kind` is
/// `rule` | `decision` | `alert`; `id` carries the RULE_/DEC_/ALERT_ prefix
/// used by the content QA tooling.
class MachineRecord {
  const MachineRecord({
    required this.id,
    required this.kind,
    required this.text,
    required this.sourcePath,
  });

  factory MachineRecord.fromJson(Map<String, dynamic> json) => MachineRecord(
    id: json['id'] as String? ?? '',
    kind: json['kind'] as String? ?? '',
    text: json['text'] as String? ?? '',
    sourcePath: json['source_path'] as String? ?? '',
  );

  final String id;
  final String kind;
  final String text;
  final String sourcePath;
}

/// Chapter/appendix-level `machine` object: only `records` + `yaml_blocks`
/// (a subset of the book-level [BookMachine]).
class ChapterMachine {
  const ChapterMachine({required this.records, required this.yamlBlocks});

  factory ChapterMachine.fromJson(Map<String, dynamic> json) =>
      ChapterMachine(
        records: (json['records'] as List<dynamic>? ?? const [])
            .map((e) => MachineRecord.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        yamlBlocks: List<dynamic>.from(json['yaml_blocks'] as List? ?? const []),
      );

  final List<MachineRecord> records;
  final List<dynamic> yamlBlocks;
}

/// Book-level `machine` object: `records` is the union of `rules` +
/// `decisions` + `alerts`, kept separately here for direct access.
class BookMachine {
  const BookMachine({
    required this.records,
    required this.rules,
    required this.decisions,
    required this.alerts,
    required this.sources,
    required this.yamlBlocks,
  });

  factory BookMachine.fromJson(Map<String, dynamic> json) {
    List<MachineRecord> parse(String key) =>
        (json[key] as List<dynamic>? ?? const [])
            .map((e) => MachineRecord.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);
    return BookMachine(
      records: parse('records'),
      rules: parse('rules'),
      decisions: parse('decisions'),
      alerts: parse('alerts'),
      sources: parse('sources'),
      yamlBlocks: List<dynamic>.from(json['yaml_blocks'] as List? ?? const []),
    );
  }

  final List<MachineRecord> records;
  final List<MachineRecord> rules;
  final List<MachineRecord> decisions;
  final List<MachineRecord> alerts;
  final List<MachineRecord> sources;
  final List<dynamic> yamlBlocks;
}

/// A normalized citation: `{id, title, url, jurisdiction, accessed_on,
/// confidence, source_path}`. `confidence` is one of `cita_con_url` |
/// `cita_editorial` | `verificada_en_revision`. `url` may be empty.
class SourceMetadata {
  const SourceMetadata({
    required this.id,
    required this.title,
    required this.url,
    required this.jurisdiction,
    required this.accessedOn,
    required this.confidence,
    required this.sourcePath,
  });

  factory SourceMetadata.fromJson(Map<String, dynamic> json) =>
      SourceMetadata(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        url: json['url'] as String? ?? '',
        jurisdiction: json['jurisdiction'] as String? ?? '',
        accessedOn: json['accessed_on'] as String? ?? '',
        confidence: json['confidence'] as String? ?? '',
        sourcePath: json['source_path'] as String? ?? '',
      );

  final String id;
  final String title;
  final String url;
  final String jurisdiction;
  final String accessedOn;
  final String confidence;
  final String sourcePath;
}

/// A chapter or appendix (`contentUnit` in the schema).
class ContentUnit extends Equatable {
  const ContentUnit({
    required this.chapterId,
    required this.path,
    required this.title,
    required this.reader,
    required this.machine,
    required this.figures,
    this.number,
    this.category,
    this.difficulty,
    this.estimatedReadTime,
  });

  factory ContentUnit.fromJson(Map<String, dynamic> json) => ContentUnit(
    chapterId: json['chapter_id'] as String? ?? '',
    path: json['path'] as String? ?? '',
    title: json['title'] as String? ?? '',
    number: (json['number'] as num?)?.toInt(),
    category: json['category'] as String?,
    difficulty: json['difficulty'] as String?,
    estimatedReadTime: json['estimated_read_time'] as String?,
    reader: Reader.fromJson(
      json['reader'] as Map<String, dynamic>? ?? const {},
    ),
    machine: ChapterMachine.fromJson(
      json['machine'] as Map<String, dynamic>? ?? const {},
    ),
    figures: (json['figures'] as List<dynamic>? ?? const [])
        .map((e) => Figure.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
  );

  final String chapterId;
  final String path;
  final String title;
  final int? number;
  final String? category;
  final String? difficulty;
  final String? estimatedReadTime;
  final Reader reader;
  final ChapterMachine machine;
  final List<Figure> figures;

  @override
  List<Object?> get props => [chapterId, path, title];
}

/// One region/state/production-setting variant of a chapter's regional
/// adaptation box (`adaptive.regional_adaptations.adaptations_by_chapter[].
/// adaptations[]`). `states`/`regions`/`production_settings` containing
/// `"general"` mark the universal fallback entry.
class AdaptationEntry {
  const AdaptationEntry({
    required this.id,
    required this.states,
    required this.regions,
    required this.productionSettings,
    required this.title,
    required this.body,
    required this.actions,
    required this.verifyBeforePublication,
  });

  factory AdaptationEntry.fromJson(Map<String, dynamic> json) =>
      AdaptationEntry(
        id: json['id'] as String? ?? '',
        states: List<String>.from(json['states'] as List? ?? const []),
        regions: List<String>.from(json['regions'] as List? ?? const []),
        productionSettings: List<String>.from(
          json['production_settings'] as List? ?? const [],
        ),
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        actions: List<String>.from(json['actions'] as List? ?? const []),
        verifyBeforePublication:
            json['verify_before_publication'] as bool? ?? false,
      );

  final String id;
  final List<String> states;
  final List<String> regions;
  final List<String> productionSettings;
  final String title;
  final String body;
  final List<String> actions;
  final bool verifyBeforePublication;
}

class ChapterAdaptations {
  const ChapterAdaptations({
    required this.chapter,
    required this.title,
    required this.category,
    required this.adaptations,
  });

  factory ChapterAdaptations.fromJson(Map<String, dynamic> json) =>
      ChapterAdaptations(
        chapter: json['chapter'] as String? ?? '',
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? '',
        adaptations: (json['adaptations'] as List<dynamic>? ?? const [])
            .map((e) => AdaptationEntry.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
      );

  final String chapter;
  final String title;
  final String category;
  final List<AdaptationEntry> adaptations;
}

class RegionalAdaptations {
  const RegionalAdaptations({required this.adaptationsByChapter});

  factory RegionalAdaptations.fromJson(Map<String, dynamic> json) =>
      RegionalAdaptations(
        adaptationsByChapter:
            (json['adaptations_by_chapter'] as List<dynamic>? ?? const [])
                .map(
                  (e) =>
                      ChapterAdaptations.fromJson(e as Map<String, dynamic>),
                )
                .toList(growable: false),
      );

  final List<ChapterAdaptations> adaptationsByChapter;

  ChapterAdaptations? forChapter(String chapterPath) {
    for (final entry in adaptationsByChapter) {
      if (entry.chapter == chapterPath) return entry;
    }
    return null;
  }
}

class TaskTipScope {
  const TaskTipScope({
    required this.states,
    required this.regions,
    required this.productionSettings,
    required this.species,
    required this.taskTypes,
    required this.season,
  });

  factory TaskTipScope.fromJson(Map<String, dynamic> json) => TaskTipScope(
    states: List<String>.from(json['states'] as List? ?? const []),
    regions: List<String>.from(json['regions'] as List? ?? const []),
    productionSettings: List<String>.from(
      json['production_settings'] as List? ?? const [],
    ),
    species: List<String>.from(json['species'] as List? ?? const []),
    taskTypes: List<String>.from(json['task_types'] as List? ?? const []),
    season: List<String>.from(json['season'] as List? ?? const []),
  );

  final List<String> states;
  final List<String> regions;
  final List<String> productionSettings;
  final List<String> species;
  final List<String> taskTypes;
  final List<String> season;
}

class TaskTip {
  const TaskTip({
    required this.id,
    required this.chapter,
    required this.appliesTo,
    required this.tip,
    required this.priority,
    required this.verifyBeforePublication,
  });

  factory TaskTip.fromJson(Map<String, dynamic> json) => TaskTip(
    id: json['id'] as String? ?? '',
    chapter: json['chapter'] as String? ?? '',
    appliesTo: TaskTipScope.fromJson(
      json['applies_to'] as Map<String, dynamic>? ?? const {},
    ),
    tip: json['tip'] as String? ?? '',
    priority: json['priority'] as String? ?? '',
    verifyBeforePublication:
        json['verify_before_publication'] as bool? ?? false,
  );

  final String id;
  final String chapter;
  final TaskTipScope appliesTo;
  final String tip;
  final String priority;
  final bool verifyBeforePublication;
}

class TaskTips {
  const TaskTips({required this.tips});

  factory TaskTips.fromJson(Map<String, dynamic> json) => TaskTips(
    tips: (json['tips'] as List<dynamic>? ?? const [])
        .map((e) => TaskTip.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
  );

  final List<TaskTip> tips;

  List<TaskTip> forChapter(String chapterPath) =>
      tips.where((t) => t.chapter == chapterPath).toList(growable: false);
}

/// The resolved `adaptive` block of a book-content.json. `null` when the
/// book has adaptive content disabled (schema allows `adaptive: null`).
class BookAdaptive {
  const BookAdaptive({
    required this.supportedRegions,
    required this.pilotState,
    required this.selectionPrecedence,
    required this.regionalAdaptations,
    required this.taskTips,
  });

  factory BookAdaptive.fromJson(Map<String, dynamic> json) => BookAdaptive(
    supportedRegions: List<String>.from(
      json['supported_regions'] as List? ?? const [],
    ),
    pilotState: json['pilot_state'] as String? ?? '',
    selectionPrecedence: List<String>.from(
      json['selection_precedence'] as List? ?? const [],
    ),
    regionalAdaptations: RegionalAdaptations.fromJson(
      json['regional_adaptations'] as Map<String, dynamic>? ?? const {},
    ),
    taskTips: TaskTips.fromJson(
      json['task_tips'] as Map<String, dynamic>? ?? const {},
    ),
  );

  final List<String> supportedRegions;
  final String pilotState;
  final List<String> selectionPrecedence;
  final RegionalAdaptations regionalAdaptations;
  final TaskTips taskTips;
}

class OperationalRecordField {
  const OperationalRecordField({
    required this.id,
    required this.label,
    required this.type,
    required this.required,
    this.unit,
  });

  factory OperationalRecordField.fromJson(Map<String, dynamic> json) =>
      OperationalRecordField(
        id: json['id'] as String? ?? '',
        label: json['label'] as String? ?? '',
        type: json['type'] as String? ?? 'text',
        required: json['required'] as bool? ?? false,
        unit: json['unit'] as String?,
      );

  final String id;
  final String label;
  final String type;
  final bool required;
  final String? unit;
}

class OperationalChecklist {
  const OperationalChecklist({
    required this.id,
    required this.title,
    required this.frequency,
    required this.steps,
    required this.escalation,
  });

  factory OperationalChecklist.fromJson(Map<String, dynamic> json) =>
      OperationalChecklist(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        frequency: json['frequency'] as String? ?? '',
        steps: List<String>.from(json['steps'] as List? ?? const []),
        escalation: json['escalation'] as String? ?? '',
      );

  final String id;
  final String title;
  final String frequency;
  final List<String> steps;
  final String escalation;
}

class OperationalRecordDef {
  const OperationalRecordDef({
    required this.id,
    required this.title,
    required this.frequency,
    required this.fields,
  });

  factory OperationalRecordDef.fromJson(Map<String, dynamic> json) =>
      OperationalRecordDef(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        frequency: json['frequency'] as String? ?? '',
        fields: (json['fields'] as List<dynamic>? ?? const [])
            .map(
              (e) => OperationalRecordField.fromJson(e as Map<String, dynamic>),
            )
            .toList(growable: false),
      );

  final String id;
  final String title;
  final String frequency;
  final List<OperationalRecordField> fields;
}

class OperationalDecisionGuide {
  const OperationalDecisionGuide({
    required this.id,
    required this.title,
    required this.trigger,
    required this.steps,
    required this.escalation,
  });

  factory OperationalDecisionGuide.fromJson(Map<String, dynamic> json) =>
      OperationalDecisionGuide(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        trigger: json['trigger'] as String? ?? '',
        steps: List<String>.from(json['steps'] as List? ?? const []),
        escalation: json['escalation'] as String? ?? '',
      );

  final String id;
  final String title;
  final String trigger;
  final List<String> steps;
  final String escalation;
}

class OperationalTools {
  const OperationalTools({
    required this.checklists,
    required this.records,
    required this.decisionGuides,
  });

  factory OperationalTools.fromJson(Map<String, dynamic> json) =>
      OperationalTools(
        checklists: (json['checklists'] as List<dynamic>? ?? const [])
            .map((e) => OperationalChecklist.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        records: (json['records'] as List<dynamic>? ?? const [])
            .map((e) => OperationalRecordDef.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        decisionGuides: (json['decision_guides'] as List<dynamic>? ?? const [])
            .map(
              (e) =>
                  OperationalDecisionGuide.fromJson(e as Map<String, dynamic>),
            )
            .toList(growable: false),
      );

  final List<OperationalChecklist> checklists;
  final List<OperationalRecordDef> records;
  final List<OperationalDecisionGuide> decisionGuides;
}

/// Top-level `book-content.json` document — the only file the app should
/// parse for a book's editorial content (never book.json or Markdown).
class BookContent extends Equatable {
  const BookContent({
    required this.bookId,
    required this.language,
    required this.translationStatus,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.stats,
    required this.chapters,
    required this.appendices,
    required this.figures,
    required this.glossary,
    required this.adaptive,
    required this.operational,
    required this.sourceMetadata,
    required this.machine,
  });

  factory BookContent.fromJson(Map<String, dynamic> json) => BookContent(
    bookId: json['book_id'] as String? ?? '',
    language: json['language'] as String? ?? 'es',
    translationStatus: json['translation_status'] as String? ?? '',
    title: json['title'] as String? ?? '',
    subtitle: json['subtitle'] as String? ?? '',
    description: json['description'] as String? ?? '',
    stats: Map<String, dynamic>.from(json['stats'] as Map? ?? const {}),
    chapters: (json['chapters'] as List<dynamic>? ?? const [])
        .map((e) => ContentUnit.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    appendices: (json['appendices'] as List<dynamic>? ?? const [])
        .map((e) => ContentUnit.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    figures: (json['figures'] as List<dynamic>? ?? const [])
        .map((e) => Figure.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    glossary: Glossary.fromJson(
      json['glossary'] as Map<String, dynamic>? ?? const {},
    ),
    adaptive: json['adaptive'] == null
        ? null
        : BookAdaptive.fromJson(json['adaptive'] as Map<String, dynamic>),
    operational: OperationalTools.fromJson(
      json['operational'] as Map<String, dynamic>? ?? const {},
    ),
    sourceMetadata: (json['source_metadata'] as List<dynamic>? ?? const [])
        .map((e) => SourceMetadata.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    machine: BookMachine.fromJson(
      json['machine'] as Map<String, dynamic>? ?? const {},
    ),
  );

  final String bookId;
  final String language;
  final String translationStatus;
  final String title;
  final String subtitle;
  final String description;
  final Map<String, dynamic> stats;
  final List<ContentUnit> chapters;
  final List<ContentUnit> appendices;
  final List<Figure> figures;
  final Glossary glossary;
  final BookAdaptive? adaptive;
  final OperationalTools operational;
  final List<SourceMetadata> sourceMetadata;
  final BookMachine machine;

  @override
  List<Object?> get props => [bookId, title, chapters.length];
}
