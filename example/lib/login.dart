import 'package:flourish_flutter_sdk_example/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _customerCodeController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _customerCodeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

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
              color: Color(0xff2f7f86),
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.supervised_user_circle,
                color: Color(0xff2f7f86),
              ),
              hintText: 'Enter your Customer code',
              hintStyle: kHintTextStyle,
            ),
            controller: _customerCodeController,
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          margin: const EdgeInsets.only(top: 10.0),
          height: 60.0,
          child: TextField(
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Color(0xff2f7f86),
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.supervised_user_circle,
                color: Color(0xff2f7f86),
              ),
              hintText: 'Enter your Category',
              hintStyle: kHintTextStyle,
            ),
            controller: _categoryController,
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
          backgroundColor: Color(0xff2f7f86),
          textStyle: const TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        onPressed: () async {
          print('Login Button Pressed');
          print(_customerCodeController.text);
          print(_categoryController.text);

          if (_customerCodeController.text.trim().isEmpty) {
            return _sendToast("Customer code is required");
          }

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Home(
                customerCode: _customerCodeController.text,
              ),
            ),
          );
        },
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Future<void> _sendToast(message) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 40.0,
          vertical: 120.0,
        ),
        child: Column(
          children: [
            Text(
              'Sign In',
              style: TextStyle(
                color: Color(0xff2f7f86),
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
    );
  }
}
