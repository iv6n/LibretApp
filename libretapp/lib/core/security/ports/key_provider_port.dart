/// core › security › ports › key_provider_port — abstract cryptographic key provider.
library;

import 'dart:typed_data';

abstract class KeyProviderPort {
  Future<Uint8List> getTokenMasterKey();
}
