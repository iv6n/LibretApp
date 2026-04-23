import 'dart:typed_data';

abstract class KeyProviderPort {
  Future<Uint8List> getTokenMasterKey();
}
