import 'package:flourish_flutter_sdk/endpoint.dart';
import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flourish_flutter_sdk/event.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk_example/client_enum.dart';
import 'package:flourish_flutter_sdk_example/credential_factory.dart';
import 'package:flourish_flutter_sdk_example/endpoint.dart';
import 'package:flourish_flutter_sdk_example/home.dart';
import 'package:flourish_flutter_sdk_example/language.dart';
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
  ClientEnum _clientValue = ClientEnum.bancosol;
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

  Widget _buildClientDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Client',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Color(0xFFf47621),
            ),
            child: DropdownButtonFormField<ClientEnum>(
              value: _clientValue,
              items: ClientEnum.values.map((e) {
                return DropdownMenuItem<ClientEnum>(
                  child: Text(e.name),
                  value: e,
                );
              }).toList(),
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  _clientValue = value!;
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.verified_user,
                  color: Colors.white,
                ),
                hintText: 'Select the Client',
                hintStyle: kHintTextStyle,
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnvDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Environment',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Color(0xFFf47621),
            ),
            child: DropdownButtonFormField<Environment>(
              value: _envValue,
              items: Environment.values.map((e) {
                return DropdownMenuItem<Environment>(
                  child: Text(e.name),
                  value: e,
                );
              }).toList(),
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  _envValue = value!;
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.verified_user,
                  color: Colors.white,
                ),
                hintText: 'Select the Environment',
                hintStyle: kHintTextStyle,
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Language',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Color(0xFFf47621),
            ),
            child: DropdownButtonFormField<Language>(
              value: _langValue,
              items: Language.values.map((e) {
                return DropdownMenuItem<Language>(
                  child: Text(e.name.toUpperCase()),
                  value: e,
                );
              }).toList(),
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  _langValue = value!;
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.verified_user,
                  color: Colors.white,
                ),
                hintText: 'Select the language',
                hintStyle: kHintTextStyle,
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () async {
          print('Login Button Pressed');
          print(_customerCodeController.text);

          if (_customerCodeController.text.trim().isEmpty) {
            _sendToast("Customer code is required");
            return;
          }

          Credential credential = await CredentialFactory(
                  clientEnum: _clientValue, environment: _envValue)
              .credential();

          if (credential.empty()) {
            _sendToast("No credentials for ${_clientValue.name.toUpperCase()} on ${_envValue.name.toUpperCase()}.\n\nTry to call the development team to add this configurations");
            return;
          }

          WidgetsFlutterBinding.ensureInitialized();
          bool hasNotification = false;

          Endpoint endpoint = EndpointFactory(
            clientEnum: credential.clientEnum,
            environment: credential.environment,
            language: _langValue,
          ).build();

          Flourish flourish = Flourish.initialize(
            partnerId: credential.parterId,
            secret: credential.secretId,
            env: credential.environment,
            endpoint: endpoint,
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
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
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
        fontSize: 16.0
    );
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
                      SizedBox(height: 30.0),
                      _buildClientDropdown(),
                      SizedBox(height: 30.0),
                      _buildEnvDropdown(),
                      SizedBox(height: 30.0),
                      _buildLanguageDropdown(),
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
