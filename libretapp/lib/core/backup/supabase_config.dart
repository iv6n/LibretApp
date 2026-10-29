/// Optional Supabase settings supplied with `--dart-define`.
library;

import 'package:libretapp/core/platform/release_features.dart';

class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured =>
      !ReleaseFeatures.offlinePilot && url.isNotEmpty && anonKey.isNotEmpty;
}
