import 'package:Expense/UI/shared/color.dart';
import 'package:Expense/UI/shared/loading.dart';
import 'package:Expense/UI/views/Authentication/sign_in_page.dart';
import 'package:Expense/core/services/api.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinChangeScreen extends StatefulWidget {
  @override
  _PinChangeScreenState createState() => _PinChangeScreenState();
}

class _PinChangeScreenState extends State<PinChangeScreen> {
  final _formKey = GlobalKey<FormState>();

  int userId;
  int profileId;
  String currentPin = '';
  String newPin = '';
  String confirmPin = '';

  String success = '';
  String error = '';
  bool loading = false;
  int _defaultPinLength = 6;

  /// Control whether show the obscureCode.
  bool _obscureEnable = true;

  var userData;

  @override
  void initState() {
    _getUserInfo();
    super.initState();
  }

  void _getUserInfo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    var user = json.decode(userJson);
    if (this.mounted) {
      setState(() {
        userData = user[0];
        userId = userData['id'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).accentColor),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'CHANGE PIN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'NOTE: You will be signed out after successful PIN change.',
                    style: TextStyle(color: corange, fontSize: 13.0),
                  ),
                ),
              ],
            ),
          ),
          Form(
            key: _formKey,
            autovalidate: true,
            child: profileFormInterface(),
          ),
        ],
      ),
    );
  }

  String validatePin(String value) {
    if (value.length < 8) {
      return 'Pin is required';
    } else {
      return null;
    }
  }

  String validateNewPin(String confirmNewPin) {
    if (newPin != confirmNewPin) {
      return 'PINS do not match';
    } else {
      return null;
    }
  }

  // Form User Interface
  Widget profileFormInterface() {
    return loading
        ? Loading()
        : Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Current PIN: ',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                PinInputTextField(
                  pinLength: _defaultPinLength,
                  autoFocus: true,
                  decoration: BoxLooseDecoration(
                    obscureStyle: ObscureStyle(
                      isTextObscure: _obscureEnable,
                      obscureText: '*',
                    ),
                    enteredColor: Theme.of(context).primaryColor,
                    strokeColor: Theme.of(context).textSelectionColor,
                    textStyle: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).textSelectionColor),
                  ),
                  onChanged: (pin) {
                    currentPin = pin;
                  },
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'New PIN: ',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                PinInputTextField(
                  pinLength: _defaultPinLength,
                  autoFocus: true,
                  decoration: BoxLooseDecoration(
                    obscureStyle: ObscureStyle(
                      isTextObscure: _obscureEnable,
                      obscureText: '*',
                    ),
                    enteredColor: Theme.of(context).primaryColor,
                    strokeColor: Theme.of(context).textSelectionColor,
                    textStyle: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).textSelectionColor),
                  ),
                  onChanged: (pin) {
                    newPin = pin;
                  },
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Confirm New PIN: ',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                PinInputTextField(
                  pinLength: _defaultPinLength,
                  autoFocus: true,
                  decoration: BoxLooseDecoration(
                    obscureStyle: ObscureStyle(
                      isTextObscure: _obscureEnable,
                      obscureText: '*',
                    ),
                    enteredColor: Theme.of(context).primaryColor,
                    strokeColor: Theme.of(context).textSelectionColor,
                    textStyle: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).textSelectionColor),
                  ),
                  onChanged: (pin) {
                    confirmPin = pin;
                  },
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, top: 5.0, right: 8.0),
                  child: error != ''
                      ? Text(
                          error,
                          style: TextStyle(color: cred),
                        )
                      : Text(''),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).accentColor,
                    onPressed: _handleSaveChanges,
                    child: Text(
                      "Save Changes".toUpperCase(),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  // Handle Sign Out
  Future _handleSignOut() async {
    // Log out from server
    try {
      // Make API call
      var res = await CallApi().getData('signout');
      var body = json.decode(res.body);
      if (body['success']) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.remove('token');
        localStorage.remove('user');
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignInPage(),
            ));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Handle Profile Saving
  void _handleSaveChanges() async {
    if (_formKey.currentState.validate()) {
      setState(() => loading = true);

      var data = {
        'old_pin': currentPin,
        'new_pin': newPin,
        'confirm_new_pin': confirmPin,
      };

      // Make API call
      var endPoint = 'user/pin/change';
      var result = await CallApi().putAuthData(data, endPoint);
      if (result.statusCode == 201) {
        // Log user out
        _handleSignOut();
      } else {
        if (this.mounted) {
          setState(() {
            error = 'Update failed, do try again and supply only valid data';
            loading = false;
          });
        }
      }
    }
  }
}
