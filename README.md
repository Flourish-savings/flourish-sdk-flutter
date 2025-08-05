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
      trackingId: 'HERE_YOU_WILL_USE_YOUR_GOOGLE_ANALYTICS_KEY_THIS_IS_NOT_REQUIRED'
    );
```

The `trackingId` variable is used if you want to pass on your Google Analytics Key to be able to monitor the use of our platform by your users.

### 2 - Open Flourish module

Finally we must call the `home()` method.
```dart
  flourish.home();
```

## EVENTS
___

You can also register for some events to know when something happens within our platform.

You can listen to a specific already mapped event, an unmapped event, or all events if you prefer.

### Listen our mapped events

We have some events already mapped that you can listen to separately

For example, if you need know when ou Trivia feature finished, you can listen to the "TriviaGameFinishedEvent"

```
flourish.onTriviaGameFinishedEvent((TriviaGameFinishedEvent response) {
 print("Event name: ${response.name}");
 print("Event data: ${jsonEncode(response.data.toJson())}");
});
```
you can find our all mapped events here:
https://github.com/Flourish-savings/flourish-sdk-flutter/tree/main/lib/events/types/v2

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
| ERROR                          | When you need to know when a not mapped error happened.                                                           |


## Examples
Inside this repository, you have an example app to show how to integrate with us:

https://github.com/Flourish-savings/flourish-sdk-flutter/tree/main/example
<br>
