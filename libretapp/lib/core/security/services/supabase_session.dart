import 'package:libretapp/core/backup/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'secure_session_storage.dart';
import 'package:libretapp/core/backup/wifi_storage_client.dart';
import 'package:http/http.dart' as http;

/// One SDK client and one secure session for phone access and account data.
class SupabaseSession {
  static Future<SupabaseClient>? _pending;
  static SupabaseClient? initializedClient;

  static Future<SupabaseClient> client() => _pending ??= _initialize();

  static Future<SupabaseClient> _initialize() async {
    try {
      final sdk = await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.anonKey,
        httpClient: WifiStorageClient(http.Client()),
        authOptions: FlutterAuthClientOptions(
          localStorage: SecureSessionStorage(
            projectKey: Uri.parse(SupabaseConfig.url).host.split('.').first,
          ),
          detectSessionInUri: false,
        ),
        debug: false,
      );
      initializedClient = sdk.client;
      return sdk.client;
    } catch (_) {
      _pending = null;
      rethrow;
    }
  }
}
