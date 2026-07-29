/// core › sync › supabase_config — cloud backup connection settings.
///
/// Values are supplied at build time with `--dart-define`, e.g.:
/// `flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co
/// --dart-define=SUPABASE_ANON_KEY=eyJ...`
///
/// Cloud backup is entirely optional: the app must keep working fully
/// offline when these are left unset, so every call site checks
/// [isConfigured] before touching Supabase.
library;

class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
