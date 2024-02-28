[<img width="400" src="https://github.com/Flourish-savings/flourish-sdk-flutter/blob/main/images/logo_flourish.png?raw=true"/>](https://flourishfi.com)
<br>
<br>
# Flourish SDK Flutter

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

- access_token: a string that represents a token that you will retrieve from our API
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
After adding our module, it is necessary to retrieve an access token from our API, and we strongly recommend that it be done through a backend because the request needs your credentials and it's good to avoid the harmful environment of the web.

Initialize the SDK providing the variables: `token`, `env`, `language` and `customerCode`.

```dart
  Flourish flourish = Flourish(
     token: 'HERE_YOU_WILL_USE_THE_RETRIEVED_API_TOKEN',
     env: Environment.staging,
     language: Language.english,
     customerCode: 'HERE_YOU_WILL_USE_YOUR_CUSTOMER_CODE'
  );
```

Finally we must call the `home()` method.
```dart
  flourish.home();
```


There is a more elaborate example inside the sdk repository,
you can access it by [clicking here](https://github.com/Flourish-savings/flourish-sdk-flutter/tree/main/example).

---


## EVENTS
___

You can also register for some events to know when something happens within our platform.

You can listen to a specific already mapped event, an unmapped event, or all events if you prefer.

### Listen our mapped events

We have some events already mapped that you can listen to separately

For example, if you need know when ou Trivia feature finished, you can listen to the "TriviaFinishedEvent"

```
flourish.onTriviaGameFinishedEvent((TriviaGameFinishedEvent response) {
  print("Event name: ${response.name}");
  print("Event data: ${jsonEncode(response.data.toJson())}");
});
```
you can find our all mapped events here:
https://github.com/Flourish-savings/flourish-sdk-flutter/tree/main/lib/events/types

### Listen our unmapped events
Even if our platform starts sending new unmapped events, it will not be necessary to update the SDK version to consume them.

Just start listening to the generic events

```
flourish.onGenericEvent((GenericEvent response) {
  print("Event name: ${response.name}");
  print("Event data: ${jsonEncode(response.data.toJson())}");
});
```

### Listen all events
But if you want to listen all the events, we also have that for you.

```
flourish.onAllEvent((Event response) {
  print("Event name: ${response.name}");
});
```

### Events to listen
here you have all events we will return

| Event name           | Description                                                                         |
|----------------------|-------------------------------------------------------------------------------------|
| BACK_BUTTON_PRESSED  | When you need to know when the user clicks on the back menu button on our platform. |
| TRIVIA_GAME_FINISHED | When you need to know when the user finishes a Trivia game on our platform.         |
| TRIVIA_CLOSED        | When you need to know when the user closed the Trivia game on our platform.         |
| REFERRAL_COPY        | When you need to know when the user copy the referral code to the clipboard area.   |
| GIFT_CARD_COPY       | When you need to know when the user copy the Gift code to the clipboard area.       |
| HOME_BANNER_ACTION   | When you need to know when the user clicks on the home banner.                      |
| MISSION_ACTION       | When you need to know when the user clicks on a mission card                        |
| INVALID_TOKEN        | When you need to know when then token expired.                                      |

