import 'dart:developer' as developer;

/// Centralized logging for the Flourish SDK.
///
/// Wraps `dart:developer` `log()` with a consistent source name and severity
/// levels, and redacts sensitive data before it reaches device/production logs.
/// Filter by the `FlourishSDK` name in DevTools to see only SDK logs.
class FlourishLog {
  FlourishLog._();

  static const String _name = 'FlourishSDK';

  // dart:developer log levels (mirrors package:logging Level values).
  static const int _infoLevel = 0;
  static const int _warningLevel = 900;
  static const int _severeLevel = 1000;

  static void info(String message) =>
      developer.log(message, name: _name, level: _infoLevel);

  static void warning(String message) =>
      developer.log(message, name: _name, level: _warningLevel);

  static void severe(String message, {Object? error}) =>
      developer.log(message, name: _name, level: _severeLevel, error: error);

  /// Masks sensitive query params (e.g. the auth token) in a URI so it can be
  /// logged without leaking secrets. Returns the URI as a string with the
  /// `token`/`apiToken` values replaced by `[REDACTED]`.
  static String redactUri(Uri uri) {
    if (uri.queryParameters.isEmpty) return uri.toString();
    final sanitized = Map<String, String>.from(uri.queryParameters);
    for (final key in const ['token', 'apiToken']) {
      if (sanitized.containsKey(key)) sanitized[key] = '[REDACTED]';
    }
    return uri.replace(queryParameters: sanitized).toString();
  }
}
