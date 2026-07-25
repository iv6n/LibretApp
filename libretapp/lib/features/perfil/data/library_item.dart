/// features › perfil › data › library_item — educational library content model.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum LibraryCategory {
  guides,
  ranchDocs,
  manuals,
  health,
  reproduction,
  feeding,
  agriculture,
  locations,
  machinery,
}

extension LibraryCategoryLabel on LibraryCategory {
  String get label {
    switch (this) {
      case LibraryCategory.guides:
        return 'Guías rápidas';
      case LibraryCategory.ranchDocs:
        return 'Documentos del rancho';
      case LibraryCategory.manuals:
        return 'Manuales de manejo';
      case LibraryCategory.health:
        return 'Sanidad';
      case LibraryCategory.reproduction:
        return 'Reproducción';
      case LibraryCategory.feeding:
        return 'Alimentación';
      case LibraryCategory.agriculture:
        return 'Agricultura';
      case LibraryCategory.locations:
        return 'Ubicaciones';
      case LibraryCategory.machinery:
        return 'Maquinaria';
    }
  }

  IconData get icon {
    switch (this) {
      case LibraryCategory.guides:
        return Icons.menu_book_outlined;
      case LibraryCategory.ranchDocs:
        return Icons.folder_open_outlined;
      case LibraryCategory.manuals:
        return Icons.auto_stories_outlined;
      case LibraryCategory.health:
        return Icons.medical_services_outlined;
      case LibraryCategory.reproduction:
        return Icons.pregnant_woman_outlined;
      case LibraryCategory.feeding:
        return Icons.grass_outlined;
      case LibraryCategory.agriculture:
        return Icons.agriculture_outlined;
      case LibraryCategory.locations:
        return Icons.map_outlined;
      case LibraryCategory.machinery:
        return Icons.agriculture;
    }
  }
}

enum LibraryContentType { article, guide, pdf, userFile }

class LibraryItem extends Equatable {
  const LibraryItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.contentType,
    this.isPremium = false,
    this.isMock = true,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String summary;
  final LibraryCategory category;
  final LibraryContentType contentType;
  final bool isPremium;
  final bool isMock;
  final List<String> tags;

  @override
  List<Object?> get props => [
    id,
    title,
    summary,
    category,
    contentType,
    isPremium,
    isMock,
    tags,
  ];
}
