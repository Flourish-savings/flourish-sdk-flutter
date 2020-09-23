import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flourish_flutter_sdk/event.dart';
import 'package:flourish_flutter_sdk_example/home.dart';
import 'package:flutter/material.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Flourish flourish = Flourish.initialize(
    apiKey: '',
    env: Environment.production,
  );
  await flourish.authenticateAndOpenDashboard(
      userId: 'z4vWWiOXrmMvl70URIPR', secretKey: 'b');
  flourish.on('points_earned', (PointsEarnedEvent e) {
    print('points_earned: $e');
  });
  flourish.on('webview_loaded', (WebviewLoadedEvent e) {
    print('webview_loaded: $e');
  });
  flourish.on('notifications', (doc) {
    print(doc.data()['hasNotificationAvailable']);
  });
  runApp(
    MultiProvider(
      providers: [
        Provider<Flourish>.value(value: flourish),
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
      home: Home(
        title: 'Activities',
      ),
    );
  }
}
