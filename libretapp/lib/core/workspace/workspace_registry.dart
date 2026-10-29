import 'dart:convert';

import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:uuid/uuid.dart';

enum WorkspaceKind { guest, account, demo }

class LocalWorkspace {
  factory LocalWorkspace.fromJson(Map<String, dynamic> value) {
    final id = value['id'] as String;
    if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(id)) {
      throw const FormatException('Espacio local inválido.');
    }
    final kind = WorkspaceKind.values.byName(value['kind'] as String);
    final userId = value['userId'] as String?;
    if (kind == WorkspaceKind.account && (userId == null || userId.isEmpty)) {
      throw const FormatException('Cuenta local inválida.');
    }
    return LocalWorkspace(
      id: id,
      kind: kind,
      userId: userId,
      phoneSuffix: value['phoneSuffix'] as String?,
      legacy: value['legacy'] == true,
    );
  }
  const LocalWorkspace({
    required this.id,
    required this.kind,
    this.userId,
    this.phoneSuffix,
    this.legacy = false,
  });
  final String id;
  final WorkspaceKind kind;
  final String? userId;
  final String? phoneSuffix;
  final bool legacy;
  bool get isDemo => kind == WorkspaceKind.demo;
  String get preferencePrefix => legacy ? '' : 'workspace.$id.';
  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'userId': userId,
    'phoneSuffix': phoneSuffix,
    'legacy': legacy,
  };
}

/// One versioned snapshot keeps ownership and the active space consistent.
/// Dataset contents, complete phone numbers and tokens are never stored here.
class WorkspaceRegistry {
  WorkspaceRegistry(this.preferences);
  static const key = 'workspaces.registry.v1';
  final SharedPrefsService preferences;
  List<LocalWorkspace> _spaces = [];
  String? _activeId;
  bool hadRegistry = false;
  bool interruptedDemo = false;
  final List<LocalWorkspace> discardedDemos = [];
  List<LocalWorkspace> get spaces => List.unmodifiable(_spaces);
  LocalWorkspace? get active => byId(_activeId);
  LocalWorkspace? byId(String? id) {
    for (final space in _spaces) {
      if (space.id == id) return space;
    }
    return null;
  }

  LocalWorkspace? account(String userId) {
    for (final space in _spaces) {
      if (space.userId == userId && space.kind == WorkspaceKind.account) {
        return space;
      }
    }
    return null;
  }

  LocalWorkspace get guest =>
      _spaces.firstWhere((space) => space.kind == WorkspaceKind.guest);

  Future<void> load({bool startup = true}) async {
    final raw = preferences.getString(key);
    hadRegistry = raw != null;
    if (raw == null) {
      if (!startup) {
        _spaces = [const LocalWorkspace(id: 'legacy', kind: WorkspaceKind.guest, legacy: true)];
        _activeId = null;
        return;
      }
      await replace([
        const LocalWorkspace(
          id: 'legacy',
          kind: WorkspaceKind.guest,
          legacy: true,
        ),
      ], null);
      return;
    }
    final value = jsonDecode(raw) as Map<String, dynamic>;
    if (value['version'] != 1) {
      throw const FormatException('Versión de espacios no compatible.');
    }
    _spaces = (value['spaces'] as List)
        .map(
          (entry) =>
              LocalWorkspace.fromJson(Map<String, dynamic>.from(entry as Map)),
        )
        .toList();
    _activeId = value['active'] as String?;
    if (_spaces.map((s) => s.id).toSet().length != _spaces.length ||
        (_activeId != null && active == null)) {
      throw const FormatException('Registro de espacios inválido.');
    }
    if (_spaces.where((s) => s.kind == WorkspaceKind.guest).length != 1 ||
        _spaces
                .where((s) => s.userId != null)
                .map((s) => s.userId)
                .toSet()
                .length !=
            _spaces.where((s) => s.userId != null).length) {
      throw const FormatException('Propietarios de espacios inválidos.');
    }
    // A demo never resumes after process death.
    if (!startup) return;
    discardedDemos.addAll(_spaces.where((s) => s.isDemo));
    interruptedDemo = active?.isDemo ?? false;
    if (discardedDemos.isNotEmpty) {
      await replace(
        _spaces.where((s) => !s.isDemo).toList(),
        interruptedDemo ? null : _activeId,
      );
    }
  }

  LocalWorkspace create(
    WorkspaceKind kind, {
    String? userId,
    String? phoneSuffix,
  }) => LocalWorkspace(
    id: const Uuid().v4(),
    kind: kind,
    userId: userId,
    phoneSuffix: phoneSuffix,
  );

  Future<void> replace(List<LocalWorkspace> spaces, String? activeId) async {
    await preferences.setString(
      key,
      jsonEncode({
        'version': 1,
        'active': activeId,
        'spaces': spaces.map((s) => s.toJson()).toList(),
      }),
    );
    _spaces = List.of(spaces);
    _activeId = activeId;
  }
}
