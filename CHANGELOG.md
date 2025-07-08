# Changelog
All notable changes to this plugin will be documented in this file.

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