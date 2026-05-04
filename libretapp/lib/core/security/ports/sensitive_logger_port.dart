/// core › security › ports › sensitive_logger_port — port for security-aware logging.
library;

import 'package:libretapp/core/security/models/security_types.dart';

/// Port for security-aware logging with PII redaction.
abstract class SensitiveLoggerPort {
  void info(String message, {String? tag});

  void warn(String message, {String? tag});

  void error(String message, {String? tag, StackTrace? stackTrace});

  String redact(String raw, {PiiKind kind = PiiKind.generic});
}
