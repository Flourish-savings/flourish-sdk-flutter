# flourish_flutter_plugin

This flutter plugin will allow the communication between the visual implementation of Flourish functionality with Flourish Backend.
 
## Getting Started

To use this plugin, you will need these elements: 
* partnerId: a unique identifier that will be provided by Flourish
* secret: a string that represents a key, also provided by Flourish

This plugin can be run in two different environments:
* staging: In this environment, you can test the functionality without impacting any real data
* production: this environment is for running the app with the real data


## How to install

To install the last officially released version please add the plugin as a dependency in your file pubsec.yaml as follows:
```
 flourish_flutter_sdk:
    git:
      url: git://github.com/Flourish-savings/flourish_flutter_sdk.git
      ref: 1.0.0
```
The current stable version of the plugin is 1.0.0, at the moment you will need to update the plugin according to the most updated release version. You can see the releases in this page https://github.com/Flourish-savings/flourish_flutter_sdk/releases. 

## Initializing the  SDK

In the main file of your application, you need to call the method initilize providing the partnerId and the secret.

You should also allow the plugin to communicate the notifications that we need to send.

```
  Flourish flourish = Flourish.initialize(
    partnerId: '34b53d94-5d35-4b50-99ab-9a7c650b5111',
    secret: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCY',
    env: Environment.staging,
  );

  flourish.on('notifications', (doc) {
    // apply logic to handle notifications
  });
```

##  Authentification with the userId
`userId` is the element that identifies the final user of the bank, the person who is the client of the bank. Regarding what this element is called in your system you need to pass this information to the plugin via the authenticate method.  

```
  flourish.authenticate(userId: '123').then((value) {
    // apply other logic here
  });
```


## Displaying the webview

All the functionality of Flourish is displayed via a webview, you can initialize this webview using this:

```
  flourish.home()
```

After a successful rendering, you should see something like this.

![Demo image](https://github.com/Flourish-savings/flourish_flutter_sdk/blob/master/Homepage.png?raw=true)

## Demo of the app 

Under this demo, in the `example` folder, you can see an implementation of this pluging running in a real application for Android and iOS, You can see how this is implemented, the parnerId, secret and userId are fake.



## Learning resources
For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
