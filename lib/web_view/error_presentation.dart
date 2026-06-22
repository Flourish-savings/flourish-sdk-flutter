/// How the SDK should surface an error to the user.
///
/// Decoupled from the widget so the decision can be unit-tested without a
/// live [WebViewController] or [BuildContext].
enum ErrorPresentation {
  /// The widget is no longer mounted; do nothing.
  none,

  /// The integrator provided a callback; hand control over and suppress the
  /// SDK's default navigation.
  invokeCallback,

  /// No callback provided; navigate to the SDK's fallback error page.
  navigateToFallback,
}

/// Resolves how an error should be presented.
///
/// Shared by `handleAuthError` and `handleWebAppError` so both follow the same
/// contract: a disposed widget short-circuits to [ErrorPresentation.none]; an
/// integrator callback takes precedence over default navigation.
ErrorPresentation resolveErrorPresentation({
  required bool isMounted,
  required bool hasCallback,
}) {
  if (!isMounted) return ErrorPresentation.none;
  return hasCallback
      ? ErrorPresentation.invokeCallback
      : ErrorPresentation.navigateToFallback;
}
