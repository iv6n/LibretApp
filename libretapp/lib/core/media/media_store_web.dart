/// Browser media persistence. The returned data URL is portable across
/// refreshes and can later be replaced by IndexedDB-backed media storage.
library;

import 'dart:convert';
import 'package:image_picker/image_picker.dart';

enum MediaBucket {
  agenda('agenda'),
  locations('locations'),
  animals('animals');

  const MediaBucket(this.directoryName);
  final String directoryName;
}

class MediaStore {
  Future<String> persist(XFile source, MediaBucket bucket) async {
    final bytes = await source.readAsBytes();
    final name = source.name.toLowerCase();
    final mime = name.endsWith('.png') ? 'image/png' : 'image/jpeg';
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }
}
