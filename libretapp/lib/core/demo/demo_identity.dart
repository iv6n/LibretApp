/// core › demo › demo_identity — deterministic identifiers for demo data.
///
/// Every record the demo scenario creates has to be recognizable as
/// "belonging to the demo" and has to be stable across repeated installs —
/// running [DemoScenarioService.install] twice must produce byte-identical
/// ids, never new random ones. `Random`/`Random.secure()` are therefore never
/// used here: [demoId] is a pure function of its inputs, built on `sha1`
/// (already a project dependency via `package:crypto`).
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Marks an id as belonging to the demo scenario.
///
/// This is the whole ownership rule: anything carrying it was written by
/// `DemoScenarioService` and may be reset or torn down; anything without it
/// is the breeder's and must survive both. Uninstalling relies on it, so it
/// lives here rather than being spelled out at each call site.
const String demoIdPrefix = 'demo-';

/// Whether [id] belongs to the demo scenario.
bool isDemoId(String? id) => id != null && id.startsWith(demoIdPrefix);

/// Deterministic, UUID-v4-shaped identifier, always prefixed with `demo-` so
/// any record carrying it is trivially recognizable as scenario-owned.
///
/// [category] groups the id space (e.g. `'animal'`, `'location'`, `'lote'`,
/// `'care-record'`); [slug] identifies the specific thing within that
/// category (e.g. `'prieta'`, `'potrero-norte'`). The same pair always
/// produces the same string — that is what lets every builder in
/// `lib/core/demo/builders/` call `demoId('animal', 'prieta')` independently
/// and agree on the result without a shared registry.
///
/// The hash is reshaped to look like a real UUID (version nibble forced to
/// `4`, variant nibble forced into the `8`/`9`/`a`/`b` range) purely so it
/// behaves like any other uuid string the app already stores — it carries no
/// randomness and is not meant to satisfy RFC 4122 uniqueness guarantees,
/// only human-recognizability and a stable shape.
String demoId(String category, String slug) {
  final digest = sha1.convert(utf8.encode('demo::$category::$slug'));
  final hex = digest.toString();
  final chars = hex.substring(0, 32).split('');
  chars[12] = '4';
  final variantNibble = (int.parse(chars[16], radix: 16) & 0x3) | 0x8;
  chars[16] = variantNibble.toRadixString(16);
  final h = chars.join();
  return 'demo-${h.substring(0, 8)}-${h.substring(8, 12)}-'
      '${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20, 32)}';
}
