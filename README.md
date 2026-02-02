[<img width="400" src="https://github.com/Flourish-savings/flourish_sdk_flutter/blob/main/images/logo_flourish.png?raw=true"/>](https://flourishfi.com)
<br>
<br>
# Flourish SDK Flutter

🇪🇸 [Versión en español](README.es.md)

This flutter plugin will allow the communication between the visual implementation of Flourish functionality.
<br>
<br>

Table of contents
=================

<!--ts-->
   * [Getting Started](#getting-started)
     * [About the SDK](#about-the-sdk)
     * [Using the SDK](#using-the-sdk)
   * [Error Handling](#error-handling)
   * [Events](#events)
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

- partnerId: a unique identifier that will be provided by Flourish
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

First foremost, it is necessary to initialize the SDK providing the variables: `partnerId`, `secret`, `env`, `language` and `customerCode`.

```dart
    Flourish flourish = Flourish(
      partnerId: 'HERE_YOU_WILL_USE_YOUR_PARTNER_ID',
      secret: 'HERE_YOU_WILL_USE_YOUR_SECRET',
      env: Environment.staging,
      language: Language.english,
      customerCode: 'HERE_YOU_WILL_USE_YOUR_CUSTOMER_CODE',
      trackingId: 'HERE_YOU_WILL_USE_YOUR_GOOGLE_ANALYTICS_KEY_THIS_IS_NOT_REQUIRED',
      onError: (context, error) {
        developer.log('Error: ${error.code} - ${error.message}', name: 'MyApp');
        // Navigate to your own error screen or show a dialog
      },
      onAuthError: (context) {
        developer.log('Auth error - redirecting to login', name: 'MyApp');
        // Navigate to your login screen
      },
      onWebViewLoadError: (context, error) {
        developer.log('WebView load error: ${error.description}', name: 'MyApp');
        // Show a retry screen or offline message
      },
    );
```

The `trackingId` variable is used if you want to pass on your Google Analytics Key to be able to monitor the use of our platform by your users.

### 2 - Open Flourish module

Finally we must call the `home()` method.
```dart
  flourish.home();
```

## Error Handling
___

The SDK provides three optional error callbacks that you can pass in the constructor:

| Callback | When it fires | Default behavior |
|---|---|---|
| `onError` | Web app errors (network, business logic, onboarding, maintenance) | Shows a token-refresh error page |
| `onAuthError` | Invalid/expired authentication token | Shows a token-refresh error page |
| `onWebViewLoadError` | Native WebView fails to load (no internet, DNS, timeout) | Shows a connection error page |

All callbacks receive a `BuildContext` so you can navigate to your own screens. If you don't provide a callback, the SDK falls back to its default error pages.

### Error scenarios

There are two layers of errors:

1. **Native WebView errors** — The device cannot reach the server (no internet, DNS failure, timeout, CloudFront 403). Handled by `onWebViewLoadError`.
2. **Web app errors** — The web app loaded but encountered an error (API failures, maintenance mode, onboarding errors). Sent via JavaScript `postMessage` and handled by `onError`.

### Listening to error events

You can also listen to error events via streams for logging purposes:

```dart
flourish.onErrorEvent((ErrorEvent event) {
  developer.log(
    'Error: ${event.code} - ${event.message}',
    name: 'MyApp',
    level: 1000,
  );
});
```

## EVENTS
___

You can also register for some events to know when something happens within our platform.

You can listen to a specific already mapped event, an unmapped event, or all events if you prefer.

### Listen our mapped events

We have some events already mapped that you can listen to separately

For example, if you need know when ou Trivia feature finished, you can listen to the "TriviaGameFinishedEvent"

```dart
flourish.onTriviaGameFinishedEvent((TriviaGameFinishedEvent response) {
  developer.log('${response.name} - data: ${jsonEncode(response.data.toJson())}', name: 'MyApp');
});
```
you can find our all mapped events here:
https://github.com/Flourish-savings/flourish_sdk_flutter/tree/main/lib/events/types/v2

### Listen our unmapped events
Even if our platform starts sending new unmapped events, it will not be necessary to update the SDK version to consume them.

Just start listening to the generic events

```dart
flourish.onGenericEvent((GenericEvent response) {
  developer.log('${response.name} - data: ${jsonEncode(response.data.toJson())}', name: 'MyApp');
});
```

### Listen all events
But if you want to listen all the events, we also have that for you.

```dart
flourish.onAllEvent((Event response) {
  developer.log('Event: ${response.name}', name: 'MyApp');
});
```

### Events to listen
here you have all events we will return

| Event name      | Description                                                                         |
|-----------------|-------------------------------------------------------------------------------------|
| BACK_BUTTON_PRESSED | When you need to know when the user clicks on the back menu button on our platform. |
| TRIVIA_GAME_FINISHED  | When you need to know when the user finishes a Trivia game on our platform.         |
| TRIVIA_CLOSED  | When you need to know when the user closed the Trivia game on our platform.         |
| REFERRAL_COPY          | When you need to know when the user copy the referral code to the clipboard area.   |
| GIFT_CARD_COPY  | When you need to know when the user copy the Gift code to the clipboard area.       |
| HOME_BANNER_ACTION      | When you need to know when the user clicks on the home banner.                      |
| MISSION_ACTION     | When you need to know when the user clicks on a mission card                        |
| ERROR      | When you need to know when a error happened.                                        |


## Examples
Inside this repository, you have an example app to show how to integrate with us:

https://github.com/Flourish-savings/flourish_sdk_flutter/tree/main/example
<br>