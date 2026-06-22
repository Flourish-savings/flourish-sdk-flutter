/// Outcome of validating an `OPEN_EXTERNAL_URL` request before launching.
///
/// Decoupled from the widget so the empty-guard + scheme allowlist can be
/// unit-tested without `url_launcher` or a live [WebViewController].
enum ExternalUrlDecision {
  /// URL is present and uses an allowed scheme; safe to hand to the launcher.
  launch,

  /// URL is missing/empty; ignore the request.
  empty,

  /// URL uses a scheme outside the http(s) allowlist; reject the request.
  disallowedScheme,
}

/// Schemes the SDK is willing to hand to the external (browser) launcher.
const Set<String> allowedExternalUrlSchemes = {'http', 'https'};

/// Decides whether an `OPEN_EXTERNAL_URL` [url] should be opened externally.
///
/// Defense-in-depth: the web content is trusted, but we still refuse anything
/// outside [allowedExternalUrlSchemes] so a compromised or injected page can't
/// drive arbitrary app-to-app deep links (`tel:`, `mailto:`, `market:`, custom
/// schemes, etc.) through [LaunchMode.externalApplication].
ExternalUrlDecision resolveExternalUrl(String url) {
  if (url.isEmpty) return ExternalUrlDecision.empty;

  final uri = Uri.tryParse(url);
  if (uri == null ||
      !allowedExternalUrlSchemes.contains(uri.scheme.toLowerCase())) {
    return ExternalUrlDecision.disallowedScheme;
  }

  return ExternalUrlDecision.launch;
}
