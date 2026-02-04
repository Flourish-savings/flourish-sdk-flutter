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
import 'dart:developer' as developer;

import 'package:provider/provider.dart';


class Home extends StatefulWidget {
  final String customerCode;

  Home({Key? key, required this.customerCode}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Flourish flourish;

  @override
  void initState() {
    super.initState();
    flourish = Provider.of<Flourish>(
      context,
      listen: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    buildPerformFlourishEvents();
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
                    ])),
            Padding(
              padding: const EdgeInsets.only(
                  top: 50, left: 50, right: 50, bottom: 200),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xff2f7f86),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize:
                      Size(MediaQuery.of(context).size.width / 1.12, 55),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RewardsScreen(flourish: flourish)
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
    flourish.onAllEvent((Event response) {
      developer.log('Event: ${response.name}', name: 'FlourishExample');
    });

    flourish.onGenericEvent((GenericEvent response) {
      if (response.name == "TRIVIA_GAME_FINISHED") {
        developer.log('${response.name} - data: ${jsonEncode(response.data.toJson())}', name: 'FlourishExample');
      }
    });

    flourish.onWebViewLoadedEvent((WebViewLoadedEvent response) {
      developer.log(response.name, name: 'FlourishExample');
    });

    flourish.onAutoPaymentEvent((AutoPaymentEvent response) {
      developer.log(response.name, name: 'FlourishExample');
    });

    flourish.onPaymentEvent((PaymentEvent response) {
      developer.log(response.name, name: 'FlourishExample');
    });

    flourish.onTriviaFinishedEvent((TriviaFinishedEvent response) {
      developer.log('${response.name} - data: ${jsonEncode(response.data.toJson())}', name: 'FlourishExample');
    });

    flourish.onBackEvent((BackEvent response) {
      developer.log('${response.name} - data: ${jsonEncode(response.data.toJson())}', name: 'FlourishExample');
    });

    flourish.onBackButtonPressedEvent((BackButtonPressedEvent response) {
      developer.log('${response.name} - data: ${jsonEncode(response.data.toJson())}', name: 'FlourishExample');
    });

    flourish.onTriviaGameFinishedEvent((TriviaGameFinishedEvent response) {
      developer.log('${response.name} - data: ${jsonEncode(response.data.toJson())}', name: 'FlourishExample');
    });

    flourish.onTriviaCloseEvent((TriviaCloseEvent response) {
      developer.log('${response.name} - data: ${jsonEncode(response.data.toJson())}', name: 'FlourishExample');
    });

    flourish.onReferralCopyEvent((ReferralCopyEvent response) {
      developer.log('${response.name} - data: ${jsonEncode(response.data.toJson())}', name: 'FlourishExample');
    });

    flourish.onGiftCardCopyEvent((GiftCardCopyEvent response) {
      developer.log('${response.name} - data: ${jsonEncode(response.data.toJson())}', name: 'FlourishExample');
    });

    flourish.onHomeBannerActionEvent((HomeBannerActionEvent response) {
      developer.log('${response.name} - data: ${jsonEncode(response.data.toJson())}', name: 'FlourishExample');
    });

    flourish.onMissionActionEvent((MissionActionEvent response) {
      developer.log('${response.name} - data: ${jsonEncode(response.data.toJson())}', name: 'FlourishExample');
    });

    flourish.onErrorEvent((ErrorEvent response) {
      developer.log('Error: ${response.code} - ${response.message}', name: 'FlourishExample', level: 1000);
    });
  }
}
