[<img width="363" height="90" src="images/flourishfi_logo_white.png"/>](https://flourishfi.com)
<br>
<br>
# Flourish SDK Flutter

This flutter plugin will allow the communication between the visual implementation of Flourish functionality.
<br>
<br>

Table of contents
=================

<!--ts-->
   * [Installation](#installation)
      * [Requirements](#requirements)
      * [Configuration](#configuration)
   * [Getting Started](#getting-started)
  * [Features](#features)
   * [Releases](#releases)
   * [Examples](#examples)
<!--te-->
<br>
<br>

## Installation

### Requirements
___
* Flutter
* Dart
<br>
<br>

### Configuration
___

Add the plugin as a dependency in your file pubsec.yaml as follows:

```
 flourish_flutter_sdk:
    git:
      url: git@github.com:Flourish-savings/flourish-sdk-flutter.git
      ref: 1.0.0
```
<br>
<br>

## Getting Started
___
To use this plugin, you will need these elements:

- partnerId: a unique identifier that will be provided by Flourish
- secret: a string that represents a key, also provided by Flourish

This plugin can be run in two different environments:

- staging: In this environment, you can test the functionality without impacting any real data
- production: this environment is for running the app with the real data
<br>
<br>

## Initializing the SDK
___

In the main file of your application, you need to call the method initilize providing the partnerId and the secret.

You should also allow the plugin to communicate the notifications that we need to send.

```
  Flourish flourish = Flourish.initialize(
    partnerId: '34b53d94-5d35-4b50-99ab-9a7c650b5111',
    secret: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCY',
    env: Environment.staging,
    language: Language.english,
  );

  flourish.on('notifications', (NotificationAvailable response) {
    // apply other logic here
    // print("hasNotificationAvailable: ${response.hasNotificationAvailable}");
    // hasNotification = response.hasNotificationAvailable;
  });

  flourish.on('share', (ShareEvent response) {
    // Add Native share functionlity of flutte
    // Response will have a title and description property

    print("Native Share");
  });
```

You can also register to other events like:

```
  // Event sent when the Plugin needs the App to go to the Savings/Home page
  flourish.on('go_to_savings', (Event response) {
    // apply other logic here
    // go to savings page
    // print("Go to savings");
  });

  // Event sent when the Plugin needs the App to go to the Winners page
  flourish.on('go_to_winners', (Event response) {
    // apply other logic here
    // go to savings page
    // print("Go to winners");
  });
```

## Authentication with the customerCode

`customerCode` is the element that identifies the final user of the bank, the person who is the client of the bank. Regarding what this element is called in your system you need to pass this information to the plugin via the authenticate method.

```
  flourish.authenticate(customerCode: '123').then((value) {
    // apply other logic here
  });
```

## Displaying the webview

All the functionality of Flourish is displayed via a webview, you can initialize this webview using this:

```
  flourish.home()
```

After a successful rendering, you should see something like this.

<img width="363" src="images/flourish_home.png"/>
<br>
<br>
<img width="363" src="images/flourish_wheel.png"/>
<br>
<br>

### Examples
Inside this repository, you have an example app to show how to integrate with us:

https://github.com/Flourish-savings/flourish-sdk-flutter/tree/main/<br>
<br>
<br>

### example
___

This will simulate your Flutter App calling our application inside a Flutter web-view component
<br>
<br>
<img width="363" src="images/example_login.png"/>
<br>
<br>
<img width="363" src="images/example_home.png"/>
<br>
<br>
<img width="363" src="images/flourish_home.png"/>