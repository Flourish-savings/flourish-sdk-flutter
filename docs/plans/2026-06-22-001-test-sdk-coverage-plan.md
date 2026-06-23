# test: Comprehensive test coverage for the Flourish Flutter SDK

**Date:** 2026-06-22
**Type:** test
**Depth:** Standard
**Origin:** docs/brainstorms/2026-06-22-test-coverage-requirements.md

---

## Summary

Raise the SDK (`lib/`, ~1,982 lines / 29 files) from 37 logic-focused tests to comprehensive behavior coverage: event parsing, config, the full `Flourish` public API (auth/refresh/event-dispatch with a mocked `ApiService`), `webview_container` JS-channel routing and error handling, and widget tests for the error pages. Add `mocktail` (dev-only) for test doubles and a CI workflow that runs `flutter test --coverage` and fails below an 85% line floor. `example/` is excluded.

Mocks are injected through existing public seams (`flourish.service`, `debugStaticToken`, `@visibleForTesting` helpers) rather than refactoring production code. Bugs the tests expose are flagged, not fixed here.

---

## Problem Frame

The SDK ships to partner apps but its highest-risk surface is untested. The current suite covers pure helpers well (logger redaction, debug overrides, `buildInitialLink`, `resolveExternalUrl`, `resolveErrorPresentation`, `ErrorEvent`/`OpenExternalUrlEvent` parsing) but leaves the public `Flourish` API, the auth/refresh network flow, WebView message dispatch, and every error UI path unverified. `test/flourish_flutter_sdk_test.dart` is a vestigial placeholder asserting nothing. Without coverage and a CI gate, regressions in these paths reach `pub.dev` publish unguarded — the repo currently has only a publish-on-tag workflow, no test CI.

---

## Scope

**In scope:** unit + widget tests for all of `lib/`; `mocktail` dev dependency; a test+coverage CI workflow with an 85% line floor.

**Out of scope / non-goals:**
- Any tests under `example/` (`example/test/widget_test.dart` stays as-is).
- End-to-end / integration tests against a live Flourish backend.
- Production behavior changes. Bugs surfaced by tests are recorded as follow-ups, not fixed here. Per project rule, a test is never weakened nor a feature downgraded to make it pass.

### Deferred to Follow-Up Work
- Fixing the `GIFT_CARD_COPY` dispatch bug (`lib/events/event.dart:74-75` returns `ReferralCopyEvent` instead of `GiftCardCopyEvent`). The test for it (U2) is written to assert the intended behavior and will fail until a separate PR fixes the source line.
- Coverage for `ApiService.signIn` if it is dead code — confirm usage before investing; otherwise cover alongside `authenticate`.

---

## Key Technical Decisions

**KTD1 — `mocktail` for test doubles (dev-only).** Added to `dev_dependencies`; never shipped to SDK consumers. Chosen over `mockito` because it needs no codegen/`build_runner`, matching the repo's zero-build-step test setup. Used to mock `ApiService` (auth flow) and the `webview_flutter` platform interface (widget mounting).

**KTD2 — Inject mocks through existing seams, not new production code.** `Flourish.service` is a public mutable field and `Flourish._` is reachable via `Flourish.create(..., debugStaticToken: ...)` which skips the network. So auth-flow tests construct a `Flourish` with a static token (no network in `create`), replace `flourish.service` with a `MockApiService`, and call `authenticate()` / `refreshToken()` directly. No production change required.

**KTD3 — WebView container: fake the platform, don't refactor.** `WebviewContainerState.initState` builds a real `WebViewController`, which throws in a plain test. Default approach: set a mocktail fake as `WebViewPlatform.instance` so the real widget mounts in `testWidgets`, exercising JS-message routing and error navigation end-to-end. **Fallback (execution-time):** if the platform fake proves brittle, extract the `_handleJavaScriptMessage` routing switch into a small `@visibleForTesting` free function and test it directly — a minimal seam, decided during implementation only if needed (see U6 execution note).

**KTD4 — 85% line-coverage floor, native-callback lines excluded.** CI parses `coverage/lcov.info` and fails under 85%. Lines that are inherently unhittable without a real WebView engine (e.g. `runJavaScriptReturningResult` callbacks inside `onPageFinished`) are excluded from the denominator via `// coverage:ignore-line` / `coverage:ignore-start|end` markers so the floor reflects reachable code. Floor is configurable in the workflow.

**KTD5 — Mirror `lib/` under `test/`, one file per unit.** Continues the existing convention (`test/web_view/...`, `test/events/...`). House style: `group()` + `test()`/`testWidgets()` with plain `expect()`.

---

## Implementation Units

Ordered by dependency and ascending risk: tooling first, then pure logic, then mocked API, then widget/WebView, then CI.

### U1. Add `mocktail` dev dependency and test scaffolding

**Goal:** Make test doubles available and establish shared test helpers.
**Requirements:** Enables KTD1, KTD2, KTD3.
**Dependencies:** none.
**Files:**
- `pubspec.yaml` (add `mocktail` under `dev_dependencies`)
- `test/helpers/test_doubles.dart` (shared `MockApiService`, `MockDio`/`Response` builders, a `flourishWithStaticToken(...)` factory helper, and `registerFallbackValue` setup)
**Approach:** Add `mocktail` (latest stable on pub.dev as of 2026-06). Create a helpers file with reusable mocks and a factory that builds a `Flourish` via `create(debugStaticToken: 'tok', ...)` then swaps in a mock service. Run `flutter pub get`.
**Patterns to follow:** existing import style in `test/flourish_debug_override_test.dart`.
**Test scenarios:** `Test expectation: none -- scaffolding/dependency only; exercised transitively by U3-U7.`
**Verification:** `flutter pub get` succeeds; `flutter test` still green; helpers import cleanly.

### U2. Event dispatch and event-type (de)serialization tests

**Goal:** Cover `Event.fromJson` routing and every event type's `from`/`fromJson`/`toJson`.
**Requirements:** "To add — pure / logic" (see origin).
**Dependencies:** U1 (none strictly; pure logic).
**Files:**
- `lib/events/event.dart` (read-only)
- `lib/events/types/**` incl. `v2/**` (read-only)
- `test/events/event_dispatch_test.dart` (new)
- `test/events/event_types_test.dart` (new)
- extend `test/events/error_event_test.dart`, `test/events/open_external_url_event_test.dart` only if gaps remain
**Approach:** Table-style cases mapping each `eventName` constant to its expected concrete type. Round-trip each event type's data class. Keep `ErrorEvent`/`OpenExternalUrlEvent` (already covered) out unless edges are missing.
**Patterns to follow:** `test/events/error_event_test.dart` dispatch-assertion style.
**Test scenarios:**
- Happy path: each `eventName` (`GoToAutoPayment`, `GoToPayment`, `TriviaFinished`, `RetryLogin`, `GoBack`, `BACK_BUTTON_PRESSED`, `TRIVIA_GAME_FINISHED`, `TRIVIA_CLOSED`, `REFERRAL_COPY`, `HOME_BANNER_ACTION`, `MISSION_ACTION`, `OPEN_EXTERNAL_URL`, `ERROR`) routes `Event.fromJson` to its expected concrete type.
- Edge: unknown / missing `eventName` → `GenericEvent`.
- **Covers the bug:** `GIFT_CARD_COPY` → asserts result is `GiftCardCopyEvent` (intended). This test FAILS against current source (`event.dart:74-75` returns `ReferralCopyEvent`) and documents the deferred fix. Mark with a comment linking the follow-up.
- Edge: each event type's `from`/`fromJson` with missing field, null field, wrong-typed field (string coercion / defaults), and a `toJson` round-trip preserving `name` + data.
**Verification:** all pass except the one intentionally-failing `GIFT_CARD_COPY` assertion, which is marked `skip:` with a reason referencing the follow-up so CI stays green while documenting intent.

### U3. EventManager and config tests

**Goal:** Cover the event stream broker and config value objects.
**Requirements:** "EventManager" and "Config" (see origin).
**Dependencies:** U1.
**Files:**
- `lib/events/event_manager.dart`, `lib/config/endpoint.dart`, `lib/config/language.dart`, `lib/config/environment_enum.dart`, `lib/config/configuration.dart` (read-only)
- `test/events/event_manager_test.dart` (new)
- `test/config/endpoint_test.dart`, `test/config/language_test.dart` (new)
**Approach:** Use `async`/`expectLater` + `emits` for the stream; assert `Endpoint` URLs per `Environment` and `Language` codes.
**Test scenarios:**
- `EventManager.notify` publishes the event on `onEvent`; multiple subscribers each receive it; ordering preserved across sequential notifies.
- `Endpoint.getBackend()` returns the correct URL for each `Environment` (development / staging / production as defined).
- `Language` exposes the expected `code` for english/spanish/portugues.
**Verification:** all green; coverage report shows config + event_manager hit.

### U4. `Flourish` authentication and token-flow tests (mocked ApiService)

**Goal:** Cover `authenticate`, `refreshToken`, `isTokenValid`, and debug overrides via a mock `ApiService`.
**Requirements:** "flourish.dart public API" (see origin).
**Dependencies:** U1.
**Files:**
- `lib/flourish.dart` (read-only)
- `test/flourish_auth_test.dart` (new) — replaces vestigial `test/flourish_flutter_sdk_test.dart` (delete that file)
**Approach:** Per KTD2: build `Flourish` with `debugStaticToken` to keep `create` offline, then swap `flourish.service` for `MockApiService` and drive `authenticate()` directly. Stub `service.authenticate(...)` to return a `Response` with `session_token`/`url`, or to throw `DioException`.
**Execution note:** when asserting `AUTHENTICATION_FAILURE`, subscribe to `flourish.onEvent` before calling `authenticate`.
**Test scenarios:**
- Happy: successful `authenticate` sets `token` and `url` from response data; returns the token.
- Error: `service.authenticate` throws `DioException` → an `AUTHENTICATION_FAILURE` `GenericEvent` is published and `authenticate` returns `""`.
- `refreshToken` re-invokes `authenticate` with the stored `customerCode`/`category` and updates `token`.
- `isTokenValid`: true for non-empty token, false for empty.
- Debug static token: `debugStaticToken` non-empty in debug → backend skipped, token used directly.
- Debug base URL: non-empty `debugBaseUrl` rewrites `url` to its authority and sets `useHttp` from scheme (http→true, https→false). (Release-mode suppression is documented but not unit-testable without a release build — note as a comment.)
**Verification:** all green; `lib/flourish.dart` auth lines covered; old placeholder file removed.

### U5. `Flourish` event-subscription and `home()` tests

**Goal:** Cover the ~15 `onXxxEvent` stream filters, `onAllEvent`/`onGenericEvent`, and `home()` widget selection.
**Requirements:** "flourish.dart public API" — stream subscriptions + `home()` (see origin).
**Dependencies:** U1, U4.
**Files:**
- `lib/flourish.dart` (read-only)
- `test/flourish_events_test.dart` (new)
- `test/flourish_home_test.dart` (new)
**Approach:** Build a `Flourish` (static-token factory), push events through `eventManager.notify(...)`, and assert each `onXxxEvent` callback fires only for its matching type. For `home()`, assert widget type returned.
**Test scenarios:**
- Each `onXxxEvent` (auto-payment, payment, trivia-finished v1, back v1, back-button v2, trivia-game-finished, trivia-close, referral-copy, gift-card-copy, home-banner, mission-action, open-external-url, web-view-loaded, error) invokes its callback for the matching event and NOT for a non-matching event.
- `onAllEvent` fires for every event; `onGenericEvent` fires only for `GenericEvent`.
- Note: `onGiftCardCopyEvent` coverage interacts with the U2 `GIFT_CARD_COPY` bug — assert it fires when a real `GiftCardCopyEvent` is notified directly (independent of the `fromJson` mis-route).
- `home()` returns the token-error widget when `!isTokenValid`; returns a `WebviewContainer` when valid; returns `onTokenErrorWidget` when that override is provided; threads `redirectTo`/`resourceId` into the container.
**Verification:** all green; subscription + `home` branches covered.

### U6. `webview_container` message-routing and error-handling tests

**Goal:** Cover `_handleJavaScriptMessage` routing, `handleAuthError`, `handleWebAppError`, `handleLoadingPageError`, `_handleOpenExternalUrl`, `_handleReferralCopy`.
**Requirements:** "webview_container.dart (logic + widget)" (see origin).
**Dependencies:** U1.
**Files:**
- `lib/web_view/webview_container.dart` (read-only unless KTD3 fallback is taken)
- `test/web_view/webview_container_test.dart` (new)
- `test/helpers/test_doubles.dart` (extend with a fake `WebViewPlatform`)
**Approach:** Per KTD3, register a mocktail fake `WebViewPlatform.instance` so `testWidgets` can pump `WebviewContainer`, then drive handlers and assert navigation / callback / event-stream outcomes. Stub `url_launcher` and `Clipboard`/`Share` platform channels via `TestDefaultBinaryMessengerBinding`.
**Execution note:** KTD3 fallback — if mounting via the platform fake is too brittle, extract the routing switch into a `@visibleForTesting` function and test it directly. Decide at implementation time; prefer the no-production-change path.
**Test scenarios:**
- Routing: a JS message with `eventName` `REFERRAL_COPY` / `OPEN_EXTERNAL_URL` / `INVALID_TOKEN` / `ERROR` / unknown reaches the correct handler; malformed JSON is caught and logged (no throw).
- `handleAuthError`: callback present → invokes `onAuthError` and does NOT navigate; no callback + mounted → navigates to `AuthErrorPage`; unmounted → no-op.
- `handleWebAppError`: `ErrorEvent` is ALWAYS published on the stream; then callback present → `onError(context, event)` and no navigation; no callback → navigates to `FlourishTokenErrorPage`.
- `handleLoadingPageError`: `errorCode == 403` → token error page; `errorType` in {connect, timeout, hostLookup} or `errorCode == -1009` → `onWebViewLoadError` callback if present else `WebViewLoadErrorPage`; other errors → no navigation.
- `_handleOpenExternalUrl`: empty url → not published, not launched; non-http(s) scheme → not published, not launched; valid http(s) → event published AND launch attempted; launcher throwing → caught (no escape).
- `_handleReferralCopy`: null `referralCode` → warn + no clipboard/share; present → clipboard set + share invoked.
**Verification:** all green; container handler branches covered; any `runJavaScriptReturningResult` callback lines that can't be reached are marked `coverage:ignore`.

### U7. Error-page widget tests

**Goal:** Render and interact with the three error pages.
**Requirements:** "widget tests" (see origin).
**Dependencies:** U1.
**Files:**
- `lib/web_view/flourish_token_error_page.dart`, `lib/web_view/auth_error_page.dart`, `lib/web_view/webview_load_error_page.dart` (read-only)
- `test/web_view/error_pages_test.dart` (new)
**Approach:** `testWidgets` + `pumpWidget(MaterialApp(home: <page>(flourish: ...)))` using the static-token factory. Assert localized copy per `Language` and that the back/retry action notifies the right event or invokes the right `Flourish` hook.
**Test scenarios:**
- Each page renders without exception inside a `MaterialApp` (the missing `page_error.png` asset renders its error-builder, not a test failure).
- `FlourishTokenErrorPage` shows the correct localized `title`/`description` for english, spanish, portugues.
- Tapping the AppBar back button on `FlourishTokenErrorPage` notifies `ERROR_BACK_BUTTON_PRESSED` on `flourish.eventManager`.
- `AuthErrorPage` / `WebViewLoadErrorPage`: render + their primary action emits the expected event or invokes the expected `Flourish` hook (confirm exact behavior from source during implementation).
**Verification:** all green; widget files covered.

### U8. CI test + coverage-gate workflow

**Goal:** Run tests with coverage on PRs/pushes and fail below the 85% floor.
**Requirements:** "Enforcement" decision (see origin).
**Dependencies:** U1-U7 (gate is meaningful only once coverage exists).
**Files:**
- `.github/workflows/test.yml` (new — does not touch the existing publish-on-tag workflow)
**Approach:** Use a standard Flutter Action setup on an Ubuntu runner: `flutter pub get`, `flutter test --coverage`, then a coverage-floor check that parses `coverage/lcov.info` (LH/LF) and exits non-zero under 85%. Trigger on `pull_request` and pushes to `main`. The floor value is a single editable constant/env in the workflow.
**Execution note:** confirm `flutter test --coverage` runs cleanly on a Linux runner; widget tests must not require a display.
**Test scenarios:** `Test expectation: none -- CI config. Validated by the workflow itself passing on a real PR, and by locally reproducing the lcov-floor parse against the generated coverage/lcov.info.`
**Verification:** workflow runs green on a PR; deliberately lowering coverage (locally) trips the gate; existing publish workflow unchanged.

---

## System-Wide Impact

- **SDK consumers:** none — `mocktail` is dev-only; no `lib/` behavior changes.
- **Contributors:** new PRs must keep coverage ≥85% (new guardrail). The `test.yml` workflow adds required CI time.
- **Maintainers:** the documented `GIFT_CARD_COPY` follow-up and the marked unhittable-coverage lines become visible debt to track.

---

## Risks & Dependencies

- **WebView platform fake brittleness** (KTD3) — mitigated by the documented seam-extraction fallback in U6.
- **Coverage instrumentation quirks** — Flutter only instruments files reachable from tests; the 85% floor and `coverage:ignore` markers (KTD4) account for genuinely unhittable native-callback lines. Re-measure after U6/U7 before locking the floor.
- **`mocktail` version** — pin a current stable version; dev-only, low blast radius.
- **Dependency:** adding `mocktail` and the test CI workflow are both pre-approved (see origin Dependencies / Assumptions).

---

## Verification Strategy

- `flutter test` is fully green (the one intentionally-failing `GIFT_CARD_COPY` assertion is `skip:`-marked with a follow-up reference, so the suite stays green while documenting intent).
- `flutter test --coverage` reports `lib/` line coverage ≥85% with the public API, event dispatch, and error-handling paths meaningfully covered (not merely constructed).
- The `test.yml` workflow passes on a PR and trips when coverage is forced below the floor.
- `example/` remains untouched by this work.
- No `lib/` production behavior changed; the `GIFT_CARD_COPY` fix is recorded as a separate follow-up.

---

## Open Questions

- **Coverage floor confirmation:** 85% is the working target; revisit after U6/U7 measure real reachable coverage.
- **`ApiService.signIn`:** confirm whether it is live or dead code before deciding to cover it (see Deferred).
- **CI runner specifics:** which Flutter setup action and SDK channel/version to pin — resolve at U8 implementation against the repo's local Flutter version (`>=3.22.0`).
