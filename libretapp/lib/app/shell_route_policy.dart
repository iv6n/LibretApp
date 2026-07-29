/// app › shell_route_policy — route-based shell chrome visibility.
library;

const _directoryOverlaySections = <String>{'animales', 'lotes', 'ubicaciones'};

/// Returns whether [uri] represents a route that must hide the shell chrome.
///
/// Matching complete path segments avoids accidental substring matches while
/// keeping detail and form descendants covered.
bool shouldHideShellChrome(Uri uri) {
  final segments = uri.pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList(growable: false);
  if (segments.isEmpty) return false;

  if (segments.first == 'registro') return true;

  if (segments.first == 'agenda') {
    return segments.length > 1;
  }

  return segments.length > 2 &&
      segments.first == 'directorio' &&
      _directoryOverlaySections.contains(segments[1]);
}
