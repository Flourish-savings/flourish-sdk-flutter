import 'dart:async';
import 'dart:developer' as developer;

import 'package:flourish_flutter_sdk/events/types/v2/back_button_pressed_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/gift_card_copy_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/home_banner_action_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/mission_action_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/open_external_url_event.dart';
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
  final List<StreamSubscription> _subscriptions = [];
  final TextEditingController _storeIdController = TextEditingController();
  Flourish? _flourish;

  @override
  void initState() {
    super.initState();
    unawaited(initFlourishSdk());
  }

  // Local-dev flags (compile-time). Defaults target staging with normal auth —
  // what integrators get. See README for usage.
  static const bool _useDev = bool.fromEnvironment('FLOURISH_DEV');
  static const String _devHost =
      String.fromEnvironment('FLOURISH_DEV_HOST', defaultValue: 'localhost:5173');
  static const String _devToken = String.fromEnvironment('FLOURISH_DEV_TOKEN');

  Future<void> initFlourishSdk() async {
    final credential = await CredentialFactory().fromEnv();
    final flourish = await Flourish.create(
      uuid: credential.partnerId,
      secret: credential.secretId,
      env: _useDev ? Environment.development : Environment.staging,
      language: Language.spanish,
      customerCode: widget.customerCode,
      // Debug-only: point the SDK at the local web app, optionally with a
      // static token (skips auth). Ignored unless FLOURISH_DEV is set.
      debugBaseUrl: _useDev ? 'http://$_devHost' : null,
      debugStaticToken: _useDev && _devToken.isNotEmpty ? _devToken : null,
      onError: (context, errorEvent) {
        // Called when the web app sends an ERROR event
        // (network, business logic, onboarding, maintenance errors)
        developer.log(
          'Web app error - code: ${errorEvent.code}, message: ${errorEvent.message}',
          name: 'FlourishExample',
          level: 1000,
        );
      },
      onAuthError: (context) {
        // Called when the web app sends an INVALID_TOKEN event (401)
        // Use this to refresh the token or redirect to your login screen
        developer.log('Auth error - token invalid or expired', name: 'FlourishExample', level: 1000);
      },
      onWebViewLoadError: (context, error) {
        // Called when the WebView fails to load (no internet, DNS, timeout)
        // error.errorCode, error.errorType, error.description are available
        developer.log(
          'WebView load error - code: ${error.errorCode}, '
          'type: ${error.errorType}, description: ${error.description}',
          name: 'FlourishExample',
          level: 1000,
        );
      },
    );
    // Update the state with fetched data only if the screen is still mounted
    if (!mounted) return;
    setState(() {
      _flourish = flourish;
      subscribeToFlourishEvents(flourish);
    });
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _storeIdController.dispose();
    super.dispose();
  }

  void _openModule({String? redirectTo, String? resourceId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RewardsScreen(
          flourish: _flourish!,
          redirectTo: redirectTo,
          resourceId: resourceId,
        ),
      ),
    );
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
                bottom: 24,
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
                onPressed: () => _openModule(),
                child: Text(
                  'Open Flourish module'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Optional deep-link demo: open the module directly on a specific
            // partner store (e.g. mirroring a push notification that carries a
            // store id). Empty input falls back to the default entry point.
            Padding(
              padding: const EdgeInsets.only(left: 50, right: 50, bottom: 12),
              child: TextField(
                controller: _storeIdController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Store ID',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50, right: 50, bottom: 100),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xff2f7f86),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: Size(
                    MediaQuery.sizeOf(context).width / 1.12,
                    55,
                  ),
                ),
                onPressed: () {
                  final storeId = _storeIdController.text.trim();
                  _openModule(
                    redirectTo: 'PARTNER_STORE_DETAIL',
                    resourceId: storeId.isEmpty ? null : storeId,
                  );
                },
                child: Text(
                  'Open specific store'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
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

  void subscribeToFlourishEvents(Flourish flourish) {
    _subscriptions.addAll([
      flourish.onErrorEvent((ErrorEvent response) {
        developer.log("Error event - code: ${response.code}, message: ${response.message}", name: 'FlourishExample');
      }),
      flourish.onAllEvent((Event response) {
        developer.log("Event: ${response.name}", name: 'FlourishExample');
      }),
      flourish.onGenericEvent((GenericEvent response) {
        if (response.name == Event.TRIVIA_GAME_FINISHED) {
          developer.log("${response.name} - data: ${jsonEncode(response.data?.toJson())}", name: 'FlourishExample');
        }
      }),
      flourish.onWebViewLoadedEvent((WebViewLoadedEvent response) {
        developer.log("Event: ${response.name}", name: 'FlourishExample');
      }),
      flourish.onAutoPaymentEvent((AutoPaymentEvent response) {
        developer.log("Event: ${response.name}", name: 'FlourishExample');
      }),
      flourish.onPaymentEvent((PaymentEvent response) {
        developer.log("Event: ${response.name}", name: 'FlourishExample');
      }),
      flourish.onTriviaFinishedEvent((TriviaFinishedEvent response) {
        developer.log("${response.name} - data: ${jsonEncode(response.data.toJson())}", name: 'FlourishExample');
      }),
      flourish.onBackEvent((BackEvent response) {
        developer.log("${response.name} - data: ${jsonEncode(response.data.toJson())}", name: 'FlourishExample');
      }),
      flourish.onBackButtonPressedEvent((BackButtonPressedEvent response) {
        developer.log("${response.name} - data: ${jsonEncode(response.data.toJson())}", name: 'FlourishExample');
      }),
      flourish.onTriviaGameFinishedEvent((TriviaGameFinishedEvent response) {
        developer.log("${response.name} - data: ${jsonEncode(response.data.toJson())}", name: 'FlourishExample');
      }),
      flourish.onTriviaCloseEvent((TriviaCloseEvent response) {
        developer.log("${response.name} - data: ${jsonEncode(response.data.toJson())}", name: 'FlourishExample');
      }),
      flourish.onReferralCopyEvent((ReferralCopyEvent response) {
        developer.log("${response.name} - data: ${jsonEncode(response.data.toJson())}", name: 'FlourishExample');
      }),
      flourish.onGiftCardCopyEvent((GiftCardCopyEvent response) {
        developer.log("${response.name} - data: ${jsonEncode(response.data.toJson())}", name: 'FlourishExample');
      }),
      flourish.onHomeBannerActionEvent((HomeBannerActionEvent response) {
        developer.log("${response.name} - data: ${jsonEncode(response.data.toJson())}", name: 'FlourishExample');
      }),
      flourish.onMissionActionEvent((MissionActionEvent response) {
        developer.log("${response.name} - data: ${jsonEncode(response.data.toJson())}", name: 'FlourishExample');
      }),
      // The SDK already opens the URL in the device browser; this is just to
      // observe the navigation (e.g. for analytics).
      flourish.onOpenExternalUrlEvent((OpenExternalUrlEvent response) {
        developer.log("${response.name} - data: ${jsonEncode(response.data.toJson())}", name: 'FlourishExample');
      }),
    ]);
  }
}
