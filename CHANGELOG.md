# Changelog
All notable changes to this plugin will be documented in this file.

## [2.9.14] - 04/02/2026

## [2.9.13] - 02/02/2026
### Added
- `onError` callback on `Flourish` constructor for handling web app errors (network, business logic, onboarding, maintenance)
- `onAuthError` callback on `Flourish` constructor for handling authentication/token errors
- `onWebViewLoadError` callback on `Flourish` constructor for handling native WebView load errors
- `onErrorEvent` listener method for subscribing to `ErrorEvent` via streams
- `ErrorEvent.fromJson` factory for parsing ERROR events from the web app
- Structured logging with `dart:developer` `log()` across the SDK (replaces `print()`)
- Doc comments on all public event listener methods
- `ERROR_BACK_BUTTON_PRESSED` and `AUTHENTICATION_FAILURE` event constants

### Fixed
- 403 WebView error now performs early return, preventing duplicate error handling
- `mounted` check added to `handleAuthError` to prevent setState after dispose
- ERROR events from web app now create `ErrorEvent` instead of `GenericEvent`

### Changed
- Migrated all `print()` calls to `dart:developer` `log()` for production-safe logging
- WebView JavaScript message handling refactored into dedicated `_handleJavaScriptMessage` method

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

[Unreleased]: https://github.com/Flourish-savings/flourish_sdk_flutter/tree/main
[1.0.8]: https://github.com/Flourish-savings/flourish_sdk_flutter/releases/tag/1.0.8
[1.0.7]: https://github.com/Flourish-savings/flourish_sdk_flutter/releases/tag/1.0.7
[1.0.6]: https://github.com/Flourish-savings/flourish_sdk_flutter/releases/tag/1.0.6
[1.0.4]: https://github.com/Flourish-savings/flourish_sdk_flutter/releases/tag/1.0.4
[1.0.3]: https://github.com/Flourish-savings/flourish_sdk_flutter/releases/tag/1.0.3
[1.0.2]: https://github.com/Flourish-savings/flourish_sdk_flutter/releases/tag/1.0.2
[1.0.1]: https://github.com/Flourish-savings/flourish_sdk_flutter/releases/tag/1.0.1
[1.0.0]: https://github.com/Flourish-savings/flourish_sdk_flutter/releases/tag/1.0.0