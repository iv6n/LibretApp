import 'dart:convert';
import 'dart:typed_data';

import 'package:libretapp/core/security/ports/key_provider_port.dart';

class DefaultKeyProviderService implements KeyProviderPort {
  static const _envMasterKey = String.fromEnvironment(
    'LIBRET_TOKEN_MASTER_KEY',
    defaultValue: 'dev-token-master-key-change-me',
  );

  @override
  Future<Uint8List> getTokenMasterKey() async {
    return Uint8List.fromList(utf8.encode(_envMasterKey));
  }
}
