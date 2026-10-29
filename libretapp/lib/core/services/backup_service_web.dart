/// Browser backup service. Files are transferred through FilePicker bytes;
/// no dart:io or native path provider is loaded into the web bundle.
library;

import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/backup_store.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';

export 'package:libretapp/core/backup/backup_models.dart' show BackupImportMode;

class BackupImportSummary {
  const BackupImportSummary({
    required this.mode,
    required this.animalsImported,
    required this.lotesImported,
    required this.agendaEntriesImported,
    required this.workersImported,
    required this.teamsImported,
    required this.milkingSessionsImported,
    required this.milkingEntriesImported,
    this.collectionCounts = const {},
  });
  final BackupImportMode mode;
  final int animalsImported;
  final int lotesImported;
  final int agendaEntriesImported;
  final int workersImported;
  final int teamsImported;
  final int milkingSessionsImported;
  final int milkingEntriesImported;
  final Map<String, int> collectionCounts;
}

class BackupService {
  BackupService({
    required AnimalRepository animalRepository,
    required LotesRepository lotesRepository,
    required AgendaRepository agendaRepository,
    required WorkforceRepository workforceRepository,
    required MilkingRepository milkingRepository,
    BackupStore? backupStore,
    SharedPrefsService? statusPrefs,
    Future<List<Object>> Function()? fetchAllAnimalsIncludingArchived,
  }) : _backupStore = backupStore,
       _statusPrefs = statusPrefs;

  final BackupStore? _backupStore;
  final SharedPrefsService? _statusPrefs;

  Future<String> exportToJsonString() async {
    final envelope = await _requireStore().capture();
    return const JsonEncoder.withIndent('  ').convert(envelope.toJson());
  }

  Future<String?> exportToFile() async {
    final bytes = await createArchiveBytes();
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar respaldo',
      fileName: 'libretapp-backup.libretbackup',
      type: FileType.custom,
      allowedExtensions: const ['libretbackup'],
      bytes: bytes,
    );
    if (path != null && path.isNotEmpty) await markLocalBackup();
    return path;
  }

  Future<void> markLocalBackup() =>
      _statusPrefs?.setDateTime(PrefsKeys.lastLocalBackup, DateTime.now()) ??
      Future.value();
  Future<void> markCloudBackup() =>
      _statusPrefs?.setDateTime(PrefsKeys.lastCloudBackup, DateTime.now()) ??
      Future.value();

  Future<void> markVerifiedCloudBackup() =>
      _statusPrefs?.setDateTime(
        PrefsKeys.lastVerifiedCloudBackup,
        DateTime.now(),
      ) ??
      Future.value();

  Future<BackupImportSummary?> importFromFile({
    required BackupImportMode mode,
  }) async {
    final picked = await FilePicker.platform.pickFiles(
      dialogTitle: 'Seleccionar respaldo',
      type: FileType.any,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return null;
    final file = picked.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      throw const FormatException(
        'El navegador no entregó el contenido del respaldo.',
      );
    }
    final lowerName = file.name.toLowerCase();
    if (!lowerName.endsWith('.libretbackup') && !lowerName.endsWith('.json')) {
      throw const FormatException(
        'Selecciona un respaldo .libretbackup o .json.',
      );
    }
    if (lowerName.endsWith('.json')) {
      return importFromJsonString(utf8.decode(bytes), mode: mode);
    }
    return importArchiveBytes(Uint8List.fromList(bytes), mode: mode);
  }

  Future<BackupImportSummary> importFromJsonString(
    String raw, {
    required BackupImportMode mode,
  }) async {
    final value = jsonDecode(raw);
    if (value is! Map) {
      throw const FormatException('El respaldo no es JSON válido.');
    }
    final envelope = BackupEnvelope.fromJson(Map<String, dynamic>.from(value));
    final result = await _requireStore().restore(envelope, mode: mode);
    return _summary(mode, result);
  }

  Future<Uint8List> createArchiveBytes() async {
    final json = utf8.encode(
      const JsonEncoder.withIndent(
        '  ',
      ).convert((await _requireStore().capture()).toJson()),
    );
    final archive = Archive()
      ..addFile(ArchiveFile('manifest.json', json.length, json));
    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  Future<BackupImportSummary> importArchiveBytes(
    Uint8List bytes, {
    required BackupImportMode mode,
  }) async {
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    final file = archive.findFile('manifest.json');
    if (file == null || !file.isFile) {
      throw const FormatException('El respaldo no contiene manifest.json.');
    }
    final envelope = BackupEnvelope.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(utf8.decode(List<int>.from(file.content as List))) as Map,
      ),
    );
    final result = await _requireStore().restore(envelope, mode: mode);
    return _summary(mode, result);
  }

  String digestArchive(Uint8List bytes) => sha256.convert(bytes).toString();

  BackupStore _requireStore() =>
      _backupStore ?? (throw StateError('BackupStore no configurado.'));

  BackupImportSummary _summary(
    BackupImportMode mode,
    BackupRestoreResult result,
  ) => BackupImportSummary(
    mode: mode,
    animalsImported: result.count('animals'),
    lotesImported: result.count('lotes'),
    agendaEntriesImported: result.count('agendaEntries'),
    workersImported: result.count('workerProfiles'),
    teamsImported: result.count('workTeams'),
    milkingSessionsImported: result.count('milkingSessions'),
    milkingEntriesImported: result.count('milkingEntries'),
    collectionCounts: result.collectionCounts,
  );
}
