/// features > biblioteca > data > library_repository — local mock library (prepared for CMS).
library;

import 'package:libretapp/features/biblioteca/data/library_item.dart';

abstract class LibraryRepository {
  Future<List<LibraryItem>> getAll();
  Future<List<LibraryItem>> search(String query);
  Future<List<LibraryItem>> byCategory(LibraryCategory category);
}

/// Mock library content — clearly marked with [LibraryItem.isMock].
class MockLibraryRepository implements LibraryRepository {
  static const _seed = [
    LibraryItem(
      id: 'guide-vacunacion',
      title: 'Calendario básico de vacunación',
      summary: 'Frecuencias recomendadas para ganado bovino en clima tropical.',
      category: LibraryCategory.health,
      contentType: LibraryContentType.guide,
      tags: ['vacunas', 'bovino'],
    ),
    LibraryItem(
      id: 'guide-partos',
      title: 'Señales de parto inminente',
      summary: 'Qué observar 48 horas antes del parto en vacas y novillas.',
      category: LibraryCategory.reproduction,
      contentType: LibraryContentType.article,
      tags: ['parto', 'reproducción'],
    ),
    LibraryItem(
      id: 'guide-pastos',
      title: 'Rotación de potreros',
      summary: 'Principios de descanso y carga animal por hectárea.',
      category: LibraryCategory.feeding,
      contentType: LibraryContentType.guide,
      tags: ['pasto', 'potrero'],
    ),
    LibraryItem(
      id: 'manual-bienestar',
      title: 'Manual de bienestar animal',
      summary: 'Buenas prácticas de manejo, corrales y reducción de estrés.',
      category: LibraryCategory.manuals,
      contentType: LibraryContentType.pdf,
      isPremium: true,
    ),
    LibraryItem(
      id: 'doc-upp',
      title: 'Registro UPP del rancho',
      summary: 'Plantilla para documentar tu Unidad de Producción Pecuaria.',
      category: LibraryCategory.ranchDocs,
      contentType: LibraryContentType.userFile,
    ),
    LibraryItem(
      id: 'guide-maiz',
      title: 'Siembra de maíz forrajero',
      summary: 'Época, densidad y requerimientos hídricos básicos.',
      category: LibraryCategory.agriculture,
      contentType: LibraryContentType.article,
    ),
    LibraryItem(
      id: 'guide-corrales',
      title: 'Diseño de corrales y mangas',
      summary: 'Flujos de manejo seguros para vacunación y pesaje.',
      category: LibraryCategory.locations,
      contentType: LibraryContentType.guide,
    ),
    LibraryItem(
      id: 'guide-tractor',
      title: 'Mantenimiento preventivo de tractor',
      summary: 'Checklist semanal antes de temporada de labores.',
      category: LibraryCategory.machinery,
      contentType: LibraryContentType.guide,
      tags: ['maquinaria', 'futuro'],
    ),
    LibraryItem(
      id: 'quick-sal',
      title: 'Suplementación mineral',
      summary: 'Tipos de sales y ubicación de comederos.',
      category: LibraryCategory.guides,
      contentType: LibraryContentType.guide,
    ),
  ];

  @override
  Future<List<LibraryItem>> getAll() async => List.unmodifiable(_seed);

  @override
  Future<List<LibraryItem>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAll();
    return _seed
        .where(
          (item) =>
              item.title.toLowerCase().contains(q) ||
              item.summary.toLowerCase().contains(q) ||
              item.tags.any((t) => t.toLowerCase().contains(q)),
        )
        .toList(growable: false);
  }

  @override
  Future<List<LibraryItem>> byCategory(LibraryCategory category) async {
    return _seed
        .where((item) => item.category == category)
        .toList(growable: false);
  }
}
