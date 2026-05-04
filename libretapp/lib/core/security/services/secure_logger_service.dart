/// core › security › services › secure_logger_service — logger that redacts sensitive data.
library;

import 'package:libretapp/core/security/models/models.dart';
import 'package:libretapp/core/security/ports/ports.dart';
import 'package:libretapp/core/services/logger_service.dart';

class SecureLoggerService implements SensitiveLoggerPort {
  static final _uuidRegex = RegExp(
    r'\b[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}\b',
  );
  static final _emailRegex = RegExp(r'\b[^\s@]+@[^\s@]+\.[^\s@]+\b');
  static final _phoneRegex = RegExp(r'\+?\d[\d\s\-]{7,}\d');

  @override
  void info(String message, {String? tag}) {
    LoggerService.i(redact(message), tag: tag ?? 'Secure');
  }

  @override
  void warn(String message, {String? tag}) {
    LoggerService.w(redact(message), tag: tag ?? 'Secure');
  }

  @override
  void error(String message, {String? tag, StackTrace? stackTrace}) {
    LoggerService.e(
      redact(message),
      tag: tag ?? 'Secure',
      stackTrace: stackTrace,
    );
  }

  @override
  String redact(String raw, {PiiKind kind = PiiKind.generic}) {
    var output = raw;
    if (kind == PiiKind.generic || kind == PiiKind.uuid) {
      output = output.replaceAll(_uuidRegex, '[REDACTED_UUID]');
    }
    if (kind == PiiKind.generic || kind == PiiKind.email) {
      output = output.replaceAll(_emailRegex, '[REDACTED_EMAIL]');
    }
    if (kind == PiiKind.generic || kind == PiiKind.phone) {
      output = output.replaceAll(_phoneRegex, '[REDACTED_PHONE]');
    }
    return output;
  }
}
