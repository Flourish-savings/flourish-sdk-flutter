import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flourish_flutter_sdk/event.dart';
import 'package:flourish_flutter_sdk_example/login.dart';
import 'package:flutter/material.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  bool hasNotification = false;
  Flourish flourish = Flourish.initialize(
    partnerId: dotenv.env['PARTNER_ID'],
    secret: dotenv.env['PARTNER_SECRET'],
    env: Environment.preproduction,
  );

  flourish.on('notifications', (NotificationAvailable response) {
    print("hasNotificationAvailable: ${response.hasNotificationAvailable}");
    hasNotification = response.hasNotificationAvailable;
  });

  flourish.on('go_to_savings', (Event response) {
    // go to savings page
    print("Go to savings");
  });

  flourish.on('go_to_winners', (Event response) {
    // go to savings page
    print("Go to winners");
  });

  runApp(
    MultiProvider(
      providers: [
        Provider<Flourish>.value(
          value: flourish,
        ),
        Provider<bool>.value(
          value: hasNotification,
        )
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: Color(0xffF47621),
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Login(),
    );
  }
}
