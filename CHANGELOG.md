# Changelog
All notable changes to this plugin will be documented in this file.

## [4.0.0] - 30/01/2026
### Breaking Changes
- `ErrorEvent` now uses named arguments: `ErrorEvent({required code, message})` (was positional `ErrorEvent(code, message)`)
- `ErrorEvent.name` changed from `'ErrorEvent'` to `'ERROR'` (`Event.ERROR`)

### Added
- New `onError` callback in `Flourish.create()` for custom handling of web app ERROR events
- `ErrorEvent.fromJson()` factory for parsing ERROR postMessage events from the web app
- Structured logging via `dart:developer` `log()` across the entire SDK, filterable by `FlourishSDK` name in DevTools
- `ERROR` case in JavaScript message handler — web app ERROR events now properly dispatched

### Fixed
- Bug where 403 error handling did not return early, potentially executing both 403 and network error handlers
- `ErrorEvent` class was defined but never instantiated — now properly created for ERROR events
- `onErrorEvent` listener was defined but never received events — now works as intended

### Changed
- ERROR events from web app now create `ErrorEvent` (with `code` and `message`) instead of `GenericEvent`
- Replaced all `print()` calls with `dart:developer` `log()` for production-safe, structured logging
  - SDK logs use `name: 'FlourishSDK'` — filter in DevTools to see only SDK logs
  - Error logs use `level: 1000`, warnings use `level: 900`, info uses default level
  - Error objects passed via `error` parameter for structured inspection in DevTools
  - The auth token query param is redacted in URL logs, and JS messages log only the event name (no raw payload) to avoid leaking secrets/PII in production logs

### Error Scenarios Reference

#### Native WebView Errors (`handleLoadingPageError`)
| Error | Cause | Page |
|-------|-------|------|
| `errorCode == 403` | CloudFront access denied / token error | `FlourishTokenErrorPage` |
| `WebResourceErrorType.connect` | TCP connection failed | `WebViewLoadErrorPage` |
| `WebResourceErrorType.timeout` | Request timed out (common in high-latency regions) | `WebViewLoadErrorPage` |
| `WebResourceErrorType.hostLookup` | DNS resolution failed | `WebViewLoadErrorPage` |
| `errorCode == -1009` | iOS: no internet connection | `WebViewLoadErrorPage` |

#### Web App Errors (JavaScript postMessage)
| Event | Cause | Default Behavior |
|-------|-------|-----------------|
| `INVALID_TOKEN` | 401 auth failure | `AuthErrorPage` or custom `onAuthError` |
| `ERROR` | Network, business logic (422), onboarding, maintenance errors | `FlourishTokenErrorPage` or custom `onError` |
| `ERROR_BACK_BUTTON_PRESSED` | User pressed back on error page | `GenericEvent` dispatched |

### Migration Guide
No migration required. To add custom error handling:

```dart
import 'dart:developer' as developer;

final flourish = await Flourish.create(
  uuid: uuid,
  secret: secret,
  env: Environment.production,
  language: Language.spanish,
  customerCode: customerCode,
  onError: (context, errorEvent) {
    developer.log('Error: ${errorEvent.code} - ${errorEvent.message}', name: 'MyApp', level: 1000);
  },
);

// Or via stream listener
flourish.onErrorEvent((ErrorEvent event) {
  developer.log('Error: ${event.code} - ${event.message}', name: 'MyApp', level: 1000);
});
```

## [3.0.0] - 20/06/2025
### Changed
- **BREAKING**: Refactored Language enum to use getter instead of nullable method
- **BREAKING**: Replaced String-based URL handling with Uri objects in Endpoint class
- **BREAKING**: Centralized event names - moved from individual EVENT_NAME constants to Event class constants
- **BREAKING**: Removed unused native Android and iOS platform plugins
- Improved WebviewContainer URL building with proper Uri manipulation
- Enhanced JavaScript message handling with better error handling and separation of concerns
- Fixed StatefulWidget anti-pattern in WebviewContainer, GenericErrorPageView, and LoadPageErrorView
- Removed field-level state instances that caused memory leaks
- Added proper didUpdateWidget lifecycle handling
- Improved code readability and maintainability across all view components
### Fixed
- Memory leaks from improper state management
- Inconsistent error handling in web resource errors
- Type safety issues with language code handling


## [1.0.8] - 10/05/2023
### Updated
- Adding event documentation

## [1.0.7] - 27/04/2023
### Updated
- Bump Kotlin plugin version to 1.5.20

## [1.0.6] - 31/01/2023
### Updated
- Updating request to Flourish API with `category` field

## [1.0.4] - 27/12/2022
### Updated
- Updating README.MD

## [1.0.3] - 27/12/2022
### Updated
- Formatting Changelog

## [1.0.2] - 26/12/2022
### Updated
- Removing loading_indicator library

## [1.0.1] - 13/12/2022
### Updated
- Update README.MD

## [1.0.0] - 24/11/2022
### Added
- Setup of the sdk

[Unreleased]: https://github.com/Flourish-savings/flourish-sdk-flutter/tree/main
[1.0.8]: https://github.com/Flourish-savings/flourish-sdk-flutter/releases/tag/1.0.8
[1.0.7]: https://github.com/Flourish-savings/flourish-sdk-flutter/releases/tag/1.0.7
[1.0.6]: https://github.com/Flourish-savings/flourish-sdk-flutter/releases/tag/1.0.6
[1.0.4]: https://github.com/Flourish-savings/flourish-sdk-flutter/releases/tag/1.0.4
[1.0.3]: https://github.com/Flourish-savings/flourish-sdk-flutter/releases/tag/1.0.3
[1.0.2]: https://github.com/Flourish-savings/flourish-sdk-flutter/releases/tag/1.0.2
[1.0.1]: https://github.com/Flourish-savings/flourish-sdk-flutter/releases/tag/1.0.1
[1.0.0]: https://github.com/Flourish-savings/flourish-sdk-flutter/releases/tag/1.0.0