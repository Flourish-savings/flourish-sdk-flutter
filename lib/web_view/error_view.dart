import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ErrorView extends StatefulWidget {

  ErrorView({
    Key? key,
    required this.flourish,
  }) : super(key: key);

  final ErrorViewState _wcs = new ErrorViewState();
  final Flourish flourish;

  @override
  ErrorViewState createState() {
    _wcs.config(flourish);
    return _wcs;
  }
}

class ErrorViewState extends State<ErrorView> {
  late Flourish _flourish;

  void config(Flourish flourish) {
    this._flourish = flourish;
  }

  Widget _buildLoading() {
    return SpinKitThreeBounce(color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    _flourish.refreshToken()
        .then((value) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>_flourish.home()
            ),
          );
        }).catchError((er) {
          print(er);
        });
    return Scaffold(
      body: Stack(
        children: <Widget> [
          Container(
            height: double.infinity,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 120.0,
              ),
              child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                    Text(
                      'Too long out. Renewing your experience',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 32.0,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    _buildLoading(),
                ],
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
