/// Persistent storage for user-selected application media.
library;

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:libretapp/core/utils/id_generator.dart';
import 'package:path_provider/path_provider.dart';

enum MediaBucket {
  agenda('agenda'),
  locations('locations'),
  animals('animals');

  const MediaBucket(this.directoryName);

  final String directoryName;
}

typedef DocumentsDirectoryProvider = Future<Directory> Function();
typedef MediaIdGenerator = String Function();

class MediaStore {
  MediaStore({
    DocumentsDirectoryProvider? documentsDirectory,
    MediaIdGenerator? idGenerator,
  }) : _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory,
       _idGenerator = idGenerator ?? generateId;

  final DocumentsDirectoryProvider _documentsDirectory;
  final MediaIdGenerator _idGenerator;

  Future<String> persist(XFile source, MediaBucket bucket) async {
    final documents = await _documentsDirectory();
    final separator = Platform.pathSeparator;
    final directory = Directory(
      '${documents.path}${separator}libretapp_media$separator'
      '${bucket.directoryName}',
    );
    await directory.create(recursive: true);

    final extension = _safeExtension(source.name);
    final baseName = _idGenerator();
    var destination = File('${directory.path}$separator$baseName$extension');
    var suffix = 1;
    while (await destination.exists()) {
      destination = File(
        '${directory.path}$separator$baseName-$suffix$extension',
      );
      suffix++;
    }

    await destination.writeAsBytes(await source.readAsBytes(), flush: true);
    return destination.absolute.path;
  }

  static String _safeExtension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '.jpg';
    final extension = fileName.substring(dot).toLowerCase();
    return RegExp(r'^\.[a-z0-9]{1,10}$').hasMatch(extension)
        ? extension
        : '.jpg';
  }
}


