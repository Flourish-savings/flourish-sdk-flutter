import 'dart:async';

import 'package:flourish_flutter_sdk/events/types/v2/back_button_pressed_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/gift_card_copy_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/home_banner_action_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/mission_action_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/referral_copy_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/trivia_close_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/trivia_game_finished_event.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk_example/reward.dart';
import 'package:flutter/material.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/types/auto_payment_event.dart';
import 'package:flourish_flutter_sdk/events/types/back_event.dart';
import 'package:flourish_flutter_sdk/events/types/generic_event.dart';
import 'package:flourish_flutter_sdk/events/types/payment_event.dart';
import 'package:flourish_flutter_sdk/events/types/trivia_finished_event.dart';
import 'package:flourish_flutter_sdk/events/types/web_view_loaded_event.dart';
import 'dart:convert';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk_example/credential_factory.dart';

class Home extends StatefulWidget {
  final String customerCode;

  const Home({
    super.key,
    required this.customerCode,
  });

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Flourish flourish;

  @override
  void initState() {
    super.initState();
    unawaited(initFlourishSdk());
  }

  Future<void> initFlourishSdk() async {
    final credential = await CredentialFactory().fromEnv();

    final _flourish = await Flourish.create(
      partnerId: credential.partnerId,
      secret: credential.secretId,
      env: Environment.staging,
      language: Language.portugues,
      customerCode: this.widget.customerCode,
    );

    // Update the state with fetched data
    setState(() {
      flourish = _flourish;
      buildPerformFlourishEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 50, right: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Flourish App Example',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 50,
                left: 50,
                right: 50,
                bottom: 200,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xff2f7f86),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: Size(
                    MediaQuery.sizeOf(context).width / 1.12,
                    55,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RewardsScreen(flourish: flourish),
                    ),
                  );
                },
                child: Text(
                  'Open Flourish module'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void buildPerformFlourishEvents() {
    flourish.onErrorEvent((ErrorEvent response) {
      print("Event name: ${response.name}");
    });

    flourish.onAllEvent((Event response) {
      print("Event name: ${response.name}");
    });

    flourish.onGenericEvent((GenericEvent response) {
      if (response.name == Event.TRIVIA_GAME_FINISHED) {
        print("Event name: ${response.name}");
        print("Event data: ${jsonEncode(response.data?.toJson())}");
      }
    });

    flourish.onWebViewLoadedEvent((WebViewLoadedEvent response) {
      print("Event name: ${response.name}");
    });

    flourish.onAutoPaymentEvent((AutoPaymentEvent response) {
      print("Event name: ${response.name}");
    });

    flourish.onPaymentEvent((PaymentEvent response) {
      print("Event name: ${response.name}");
    });

    flourish.onTriviaFinishedEvent((TriviaFinishedEvent response) {
      print("Event name: ${response.name}");
      print("Event data: ${jsonEncode(response.data.toJson())}");
    });

    flourish.onBackEvent((BackEvent response) {
      print("Event name: ${response.name}");
      print("Event data: ${jsonEncode(response.data.toJson())}");
    });

    flourish.onBackButtonPressedEvent((BackButtonPressedEvent response) {
      print("Event name: ${response.name}");
      print("Event data: ${jsonEncode(response.data.toJson())}");
    });

    flourish.onTriviaGameFinishedEvent((TriviaGameFinishedEvent response) {
      print("Event name: ${response.name}");
      print("Event data: ${jsonEncode(response.data.toJson())}");
    });

    flourish.onTriviaCloseEvent((TriviaCloseEvent response) {
      print("Event name: ${response.name}");
      print("Event data: ${jsonEncode(response.data.toJson())}");
    });

    flourish.onReferralCopyEvent((ReferralCopyEvent response) {
      print("Event name: ${response.name}");
      print("Event data: ${jsonEncode(response.data.toJson())}");
    });

    flourish.onGiftCardCopyEvent((GiftCardCopyEvent response) {
      print("Event name: ${response.name}");
      print("Event data: ${jsonEncode(response.data.toJson())}");
    });

    flourish.onHomeBannerActionEvent((HomeBannerActionEvent response) {
      print("Event name: ${response.name}");
      print("Event data: ${jsonEncode(response.data.toJson())}");
    });

    flourish.onMissionActionEvent((MissionActionEvent response) {
      print("Event name: ${response.name}");
      print("Event data: ${jsonEncode(response.data.toJson())}");
    });
  }
}
