# Test Coverage for the Flourish Flutter SDK — Requirements

**Date:** 2026-06-22
**Status:** Ready for planning
**Scope:** Standard / Deep-feature

## Problem & Goal

The SDK (`lib/`, ~1,982 lines / 29 files) ships to partner apps but is thinly tested. The current suite (8 files, 37 tests, all passing) covers pure helpers well — logger redaction, debug overrides, `buildInitialLink`, `resolveExternalUrl`, `resolveErrorPresentation`, and `ErrorEvent`/`OpenExternalUrlEvent` parsing — but the highest-risk surface is untested: the public `Flourish` API, the auth/refresh network flow, the WebView JS-channel routing, and every error UI path.

**Goal:** raise the SDK to comprehensive, behavior-level coverage so regressions in the public API, event dispatch, and error handling are caught before publish — and keep it there with a CI gate. `example/` is explicitly excluded.

## Decisions (resolved in brainstorm)

1. **Test doubles:** add `mocktail` to `dev_dependencies` (test-only; never shipped to SDK consumers). Unlocks mocking `Dio`/`ApiService` and the WebView controller.
2. **Depth:** full — pure logic + event types + `flourish.dart` auth/refresh/event-dispatch + `webview_container` message routing + widget tests for the error pages.
3. **Enforcement:** add a GitHub Actions workflow that runs `flutter test --coverage` on PRs and fails below an agreed line-coverage floor (target **85%**).

## Non-Goals

- No tests for anything under `example/`.
- No end-to-end / integration tests against a live Flourish backend.
- No production behavior changes as part of this work. Bugs surfaced by tests (see below) are **flagged, not silently fixed** — fixing is a separate, explicitly-approved change. Per project rule, a test must never be weakened or a feature downgraded to make it pass.

## Coverage Inventory

### Already covered (keep, extend at edges)
- `utils/logger.dart` (redaction), `flourish_debug_override` (debug base URL / static token), `web_view/error_presentation.dart`, `web_view/external_url_resolution.dart`, `web_view/initial_link` (`buildInitialLink`), `events/error_event`, `events/open_external_url_event`.
- Replace the vestigial `test/flourish_flutter_sdk_test.dart` (a placeholder with everything commented out, asserting nothing) with real `Flourish` tests.

### To add — pure / logic (no widget tree)
- **Event dispatch** (`events/event.dart` `Event.fromJson`): one case per `eventName` routes to the correct type; unknown → `GenericEvent`; the `ERROR` fallback case. **Expose-the-bug:** `GIFT_CARD_COPY` currently returns `ReferralCopyEvent`, not `GiftCardCopyEvent` (`event.dart:74-75`) — assert the *intended* type so the test documents the bug for a separate fix.
- **Event types** (`events/types/**`, incl. `v2/**`): `fromJson`/`from`/`toJson` round-trips, missing/null/wrong-type field handling, name constants. Covers `back`, `retry_login`, `generic`, `trivia_finished`, and all v2 events (back-button, trivia close/finished, gift-card copy, referral copy, home-banner, mission-action).
- **EventManager** (`events/event_manager.dart`): `notify` publishes to `onEvent` stream; multiple subscribers; ordering.
- **Config**: `Endpoint` (URL per `Environment`), `Language` (codes), `Environment` enum, `Configuration`.

### To add — `flourish.dart` public API (mocked `ApiService`/`Dio`)
- `authenticate`: success sets `token` + `url`; `DioException` notifies `AUTHENTICATION_FAILURE` and returns `""`; debug static-token path skips the backend; debug base-URL override rewrites `url` and sets `useHttp` from scheme (and is **not** applied in release).
- `refreshToken`: re-authenticates with the stored `customerCode`/`category`.
- `isTokenValid`: empty vs non-empty token.
- `home(...)`: returns the token-error widget when invalid; returns a `WebviewContainer` (with deep-link `redirectTo`/`resourceId` threaded through) when valid; honors `onTokenErrorWidget`.
- The `onXxxEvent` stream subscriptions (~15): each filters to its own event type and forwards via callback; `onAllEvent` forwards everything; `onGenericEvent` only `GenericEvent`.

### To add — `webview_container.dart` (logic + widget)
- `_handleJavaScriptMessage` routing: `REFERRAL_COPY`, `OPEN_EXTERNAL_URL`, `INVALID_TOKEN`, `ERROR`, and default → generic; malformed JSON is caught and logged (no throw).
- `handleAuthError`: callback-present → invoke callback (no nav); no callback + mounted → `AuthErrorPage`; unmounted → none.
- `handleWebAppError`: `ErrorEvent` **always** published on the stream; then callback-present → callback, else → `FlourishTokenErrorPage`.
- `handleLoadingPageError`: 403 → token error page; connectivity error types (`connect`/`timeout`/`hostLookup`/`-1009`) → `onWebViewLoadError` callback or `WebViewLoadErrorPage`.
- `_handleOpenExternalUrl`: empty/disallowed-scheme URL ignored & not published; valid URL published + launched; launcher failure caught.
- `_handleReferralCopy`: null `referralCode` → warn & no-op; present → clipboard + share.

### To add — widget tests
- `auth_error_page.dart`, `flourish_token_error_page.dart`, `webview_load_error_page.dart`: render without error, show expected copy/asset, and the retry/back action emits the correct event / invokes the right `Flourish` hook.

## Approach

- **Test doubles:** `mocktail` for `ApiService` (and `Dio.Response` shapes) and `WebViewController` where the platform layer must be stubbed. Prefer testing through existing `@visibleForTesting` seams and injectable fields (e.g. `flourish.service`) over adding new ones; add a seam only where a path is otherwise unreachable, and keep it minimal.
- **Structure:** mirror `lib/` under `test/` (already the convention). One test file per source unit.
- **Widget tests:** `flutter_test`'s `testWidgets` + `pumpWidget`; stub the WebView platform channel where construction would otherwise touch native code.
- **CI:** add `.github/workflows/test.yml` running on PRs/pushes — `flutter test --coverage`, then a coverage-floor check (parse `coverage/lcov.info`, fail under 85%). Sits alongside the existing publish-on-tag workflow; does not alter publishing.

## Success Criteria

- All new and existing tests pass via `flutter test`.
- Line coverage of `lib/` ≥ **85%** (measured by `flutter test --coverage`), with the public API, event dispatch, and error-handling paths meaningfully covered (not just constructed).
- CI fails a PR that drops coverage below the floor.
- No production behavior changed; any bug found is recorded as a separate follow-up.
- `example/` remains untested by this work.

## Open Questions

- **Coverage floor:** 85% is the working target. Confirm, or set higher/lower. (Some lines — e.g. native WebView callbacks — may be impractical to hit; the floor should account for that.)
- **`GIFT_CARD_COPY` bug:** confirm the intended behavior (`GiftCardCopyEvent`) so the test asserts the right thing, and whether the one-line fix rides along or stays a separate PR.
- **CI runner:** confirm `flutter test --coverage` is acceptable in Actions (Linux runner, `subosito/flutter-action` or similar). Coverage-floor check via a small script vs an existing action — planner's call.

## Dependencies / Assumptions

- Adding `mocktail` (dev-only) is approved.
- Adding a test CI workflow is approved; it must not modify the existing publish workflow or any ports/infra.
- The repo currently has no test CI — only publish-on-tag.
