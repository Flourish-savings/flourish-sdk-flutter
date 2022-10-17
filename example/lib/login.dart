import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flourish_flutter_sdk/event.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk/language.dart';
import 'package:flourish_flutter_sdk_example/credential_factory.dart';
import 'package:flourish_flutter_sdk_example/home.dart';
import 'package:flourish_flutter_sdk_example/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _customerCodeController = TextEditingController();
  Environment _envValue = Environment.staging;
  Language _langValue = Language.spanish;

  Widget _buildCustomerCodeTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Customer Code',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.supervised_user_circle,
                color: Colors.white,
              ),
              hintText: 'Enter your Customer code',
              hintStyle: kHintTextStyle,
            ),
            controller: _customerCodeController,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(15.0),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          backgroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        onPressed: () async {
          print('Login Button Pressed');
          print(_customerCodeController.text);

          if (_customerCodeController.text.trim().isEmpty) {
            _sendToast("Customer code is required");
            return;
          }

          Credential credential =
              await CredentialFactory().fromEnv();

          if (credential.empty()) {
            _sendToast(
                "Empty Credentials. Set .env file with partner and secret ID");
            return;
          }

          WidgetsFlutterBinding.ensureInitialized();
          bool hasNotification = false;

          Flourish flourish = Flourish.initialize(
            partnerId: credential.partnerId,
            secret: credential.secretId,
            env: Environment.staging,
            language: Language.english,
          );

          flourish.on('notifications', (NotificationAvailable response) {
            print(
                "hasNotificationAvailable: ${response.hasNotificationAvailable}");
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

          flourish.on('share', (ShareEvent response) {
            // go to savings page
            print("Native Share");
          });

          flourish
              .authenticate(customerCode: _customerCodeController.text)
              .then((value) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiProvider(
                  providers: [
                    Provider<Flourish>.value(
                      value: flourish,
                    ),
                    Provider<bool>.value(
                      value: hasNotification,
                    )
                  ],
                  child: Home(title: "Activities"),
                ),
              ),
            );
          }).catchError((er) {
            print(er);
          });
        },
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  void _sendToast(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFf47621),
                      Color(0xFFf58b45),
                      Color(0xFFf58b45),
                      Color(0xFFf47621),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30.0),
                      _buildCustomerCodeTF(),
                      _buildLoginBtn(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
