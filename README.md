[<img width="400" src="https://github.com/Flourish-savings/flourish-sdk-flutter/blob/main/images/logo_flourish.png?raw=true"/>](https://flourishfi.com)
<br>
<br>
# Flourish SDK Flutter

> **[Leer en Espa&ntilde;ol](README.es.md)**

This flutter plugin will allow the communication between the visual implementation of Flourish functionality.
<br>
<br>

Table of contents
=================

<!--ts-->
   * [Getting Started](#getting-started)
     * [About the SDK](#about-the-sdk)
     * [Using the SDK](#using-the-sdk)
   * [Events](#events)
   * [Error Handling](#error-handling)
   * [Examples](#examples)
<!--te-->
<br>

## Getting Started
___

### Adding Flourish to your project

In your project's `pubspec.yaml` file, add the last version of Flourish Flutter SDK to your dependencies.
```yaml
# pubspec.yaml

dependencies:
  flourish_flutter_sdk: ^<latest version>
```

### SDK internal requirements

To use this SDK, you will need these elements:

- uuid: a unique identifier that will be provided by Flourish
- secret: a string that represents a key, also provided by Flourish
- costumer_code: a string that represents an identifier of yourself

This plugin can be run in two different environments:

- staging: In this environment, you can test the functionality without impacting any real data
- production: this environment is for running the app with the real data
<br>
<br>

### About the SDK

The integration with us works as follows, the client authenticates himself in our backend
and we return an access token that allows him to load our webview, given that,
the sdk serves to encapsulate and help in loading this webview.

### Using the SDK
___

### 1 - Initialization

##<span style="color:red;">IMPORTANT❗</span>


<div style="border: 1px solid grey; padding: 10px;">

**For the flow to work correctly and for us to have the metrics correctly to show our value, it is extremely important to initialize our SDK when opening your App, for example at startup or on the home screen. The most important thing is that it is not initialized at the same time as opening our module.**

</div>

___

First foremost, it is necessary to initialize the SDK providing the variables: `uuid`, `secret`, `env`, `language` and `customerCode`.

```dart
    Flourish flourish = await Flourish.create(
      uuid: 'HERE_YOU_WILL_USE_YOUR_PARTNER_ID',
      secret: 'HERE_YOU_WILL_USE_YOUR_SECRET',
      env: Environment.staging,
      language: Language.english,
      customerCode: 'HERE_YOU_WILL_USE_YOUR_CUSTOMER_CODE',
      trackingId: 'HERE_YOU_WILL_USE_YOUR_GOOGLE_ANALYTICS_KEY_THIS_IS_NOT_REQUIRED',
      onError: (context, errorEvent) {
        // Called when the web app sends an ERROR event (network, business logic, maintenance errors)
        developer.log('Error: ${errorEvent.code} - ${errorEvent.message}', name: 'MyApp', level: 1000);
      },
      onAuthError: (context) {
        // Called when the web app sends an INVALID_TOKEN event (401 auth failure)
        // Use this to refresh the token or redirect to login
      },
      onWebViewLoadError: (context, error) {
        // Called when the WebView fails to load (no internet, DNS failure, timeout)
        // Use this to show a custom native error screen
      },
    );
```

The `trackingId` variable is used if you want to pass on your Google Analytics Key to be able to monitor the use of our platform by your users.

The error callbacks (`onError`, `onAuthError`, `onWebViewLoadError`) are all optional. If not provided, the SDK shows default error pages. See [Error Handling](#error-handling) for details.

### 2 - Open Flourish module

Finally we must call the `home()` method.
```dart
  flourish.home();
```

#### Deep-linking to a specific page (optional)

`home()` accepts two optional parameters that let you open the module directly
on a specific page instead of the default entry point. A common use case is a
**push notification** that takes the user straight to a specific partner store:

```dart
  flourish.home(
    redirectTo: 'PARTNER_STORE_DETAIL', // the target page key
    resourceId: '123',                  // the resource id (e.g. the store id)
  );
```

- `redirectTo` — the page key to open. Omit it (or pass `null`) for the default
  behavior.
- `resourceId` — the id for pages that target a specific resource (such as a
  store). Only needed for pages that require one.

These values are forwarded to the web app, which validates them and safely
falls back to its default page if they are unknown or invalid.

## EVENTS
___

You can also register for some events to know when something happens within our platform.

You can listen to a specific already mapped event, an unmapped event, or all events if you prefer.

### Listen our mapped events

We have some events already mapped that you can listen to separately

For example, if you need know when ou Trivia feature finished, you can listen to the "TriviaGameFinishedEvent"

```dart
flourish.onTriviaGameFinishedEvent((TriviaGameFinishedEvent response) {
  developer.log("${response.name} - data: ${jsonEncode(response.data.toJson())}", name: 'MyApp');
});
```
you can find our all mapped events here:
https://github.com/Flourish-savings/flourish-sdk-flutter/tree/main/lib/events/types/v2

### Listen our unmapped events
Even if our platform starts sending new unmapped events, it will not be necessary to update the SDK version to consume them.

Just start listening to the generic events

```dart
flourish.onGenericEvent((GenericEvent response) {
  developer.log("${response.name} - data: ${jsonEncode(response.data?.toJson())}", name: 'MyApp');
});
```

### Listen all events
But if you want to listen all the events, we also have that for you.

```dart
flourish.onAllEvent((Event response) {
  developer.log("Event: ${response.name}", name: 'MyApp');
});
```

### Events to listen
here you have all events we will return

| Event name                     | Description                                                                                                       |
|--------------------------------|-------------------------------------------------------------------------------------------------------------------|
| BACK_BUTTON_PRESSED            | When you need to know when the user clicks on the back menu button on our platform.                               |
| ERROR_BACK_BUTTON_PRESSED      | When you need to know when the user clicks on the back menu button on our error page.                             |
| HOME_BACK_BUTTON_PRESSED       | When you need to know when the user clicks on the back menu button when on the home screen of our platform.       |
| ONBOARDING_BACK_BUTTON_PRESSED | When you need to know when the user clicks on the back menu button when on the onboarding screen of our platform. |
| TERMS_ACCEPTED                 | When you need to know when the user clicks to accept the terms.                                                   |
| TRIVIA_GAME_FINISHED           | When you need to know when the user finishes a Trivia game on our platform.                                       |
| TRIVIA_CLOSED                  | When you need to know when the user closed the Trivia game on our platform.                                       |
| REFERRAL_COPY                  | When you need to know when the user copy the referral code to the clipboard area.                                 |
| REFERRAL_FINISHED              | When you need to know when the referral finished.                                                                 |
| REFERRAL_REWARD_REDEEMED       | When you need to know when the user redeem the referral rewards.                                                  |
| REFERRAL_REWARD_SKIPPED        | When you need to know when the user slipped the referral rewards.                                                 |
| GIFT_CARD_COPY                 | When you need to know when the user copy the Gift code to the clipboard area.                                     |
| HOME_BANNER_ACTION             | When you need to know when the user clicks on the home banner.                                                    |
| MISSION_ACTION                 | When you need to know when the user clicks on a mission card.                                                     |
| AUTHENTICATION_FAILURE         | When you need to know when the Authentication failed.                                                             |
| ERROR                          | When an error occurs in the web application (network, business logic, onboarding, maintenance).                   |
| INVALID_TOKEN                  | When the session token is invalid or expired (401). Dispatched before ERROR.                                      |

## Error Handling
___

The SDK handles errors at two levels: **native WebView errors** (before the web app loads) and **web app errors** (sent via JavaScript postMessage after the page loads).

### Native WebView Errors

These occur when the WebView itself fails to load the page (e.g., no internet, DNS failure, timeout). The SDK detects these via `onWebResourceError` and shows a default "No internet connection" page.

| Error | Cause | Default Page |
|-------|-------|-------------|
| `WebResourceErrorType.connect` | TCP connection failed (server unreachable, port blocked) | `WebViewLoadErrorPage` |
| `WebResourceErrorType.timeout` | Request timed out (common in high-latency regions) | `WebViewLoadErrorPage` |
| `WebResourceErrorType.hostLookup` | DNS resolution failed | `WebViewLoadErrorPage` |
| Error code `-1009` | iOS: device has no internet connection | `WebViewLoadErrorPage` |
| Error code `403` | CloudFront access denied / signed URL expired | `FlourishTokenErrorPage` |

To provide a custom UI for these errors:

```dart
Flourish flourish = await Flourish.create(
  // ...
  onWebViewLoadError: (context, error) {
    // error.errorCode, error.errorType, error.description are available
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyCustomErrorPage()),
    );
  },
);
```

### Web App Errors

These occur after the WebView loads the page. The web app communicates errors back to the SDK via `postMessage` through the JavaScript channel.

| Event | Cause | Default Behavior |
|-------|-------|-----------------|
| `INVALID_TOKEN` | Token expired or invalid (HTTP 401) | Shows `AuthErrorPage` (auto-refreshes token) |
| `ERROR` | Network error, business logic error (422), onboarding failure, maintenance data failure | Shows `FlourishTokenErrorPage` |
| `ERROR_BACK_BUTTON_PRESSED` | User pressed back on the error page | Dispatches `GenericEvent` |

**Important:** `INVALID_TOKEN` is dispatched **before** `ERROR` by the web app. If you handle `INVALID_TOKEN` (e.g., refreshing the token), the subsequent `ERROR` event can be safely ignored.

To handle web app errors:

```dart
Flourish flourish = await Flourish.create(
  // ...
  onAuthError: (context) {
    // Handle INVALID_TOKEN: refresh token and reload, or redirect to login
  },
  onError: (context, errorEvent) {
    // Handle ERROR: errorEvent.code and errorEvent.message contain details
    developer.log('Error: ${errorEvent.code} - ${errorEvent.message}', name: 'MyApp', level: 1000);
  },
);
```

You can also listen to error events via the stream:

```dart
flourish.onErrorEvent((ErrorEvent event) {
  developer.log('Error: ${event.code} - ${event.message}', name: 'MyApp', level: 1000);
});
```

### Debug Logging

The SDK uses `dart:developer` `log()` for structured, production-safe logging. All SDK logs use the name `FlourishSDK`, which allows filtering in Flutter DevTools.

To view SDK logs in DevTools, filter by `FlourishSDK` in the Logging tab.

Example output for a WebView load error:
```
[FlourishSDK] WebView Load Error - code: -1009, type: WebResourceErrorType.hostLookup, description: net::ERR_NAME_NOT_RESOLVED, isForMainFrame: true
```

Log levels used:
- **Default** (info): URL loading, JS messages, sign-in success
- **900** (warning): Missing referral code, network connectivity errors
- **1000** (error): WebView load errors, token refresh failures

In your own app, use `dart:developer` `log()` instead of `print()`:
```dart
import 'dart:developer' as developer;

flourish.onErrorEvent((ErrorEvent event) {
  developer.log(
    'Error: ${event.code} - ${event.message}',
    name: 'MyApp',
    level: 1000,
  );
});
```

## Examples
Inside this repository, you have an example app to show how to integrate with us:

https://github.com/Flourish-savings/flourish-sdk-flutter/tree/main/example
<br>
