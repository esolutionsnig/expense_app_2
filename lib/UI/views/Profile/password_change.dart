import 'package:Expense/UI/shared/color.dart';
import 'package:Expense/UI/shared/loading.dart';
import 'package:Expense/UI/views/Authentication/sign_in_page.dart';
import 'package:Expense/core/services/api.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordChangeScreen extends StatefulWidget {
  @override
  _PasswordChangeScreenState createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final _formKey = GlobalKey<FormState>();

  int userId;
  int profileId;
  String currentPassword = '';
  String newPassword = '';
  String confirmPassword = '';

  String success = '';
  String error = '';
  bool loading = false;
  bool editPassword = false;

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
      decoration:
          BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'CHANGE PASSOWRD',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'NOTE: You will be signed out after successful password change.',
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

  String validatePassword(String value) {
    if (value.length < 8) {
      return 'Password is required';
    } else {
      return null;
    }
  }

  String validateNewPassword(String confirmNewPassword) {
    if (newPassword != confirmNewPassword) {
      return 'Passwords do not match';
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
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.lock,
                      color: Theme.of(context).textSelectionColor,
                    ),
                    hintText: 'Enter Your New Password',
                    labelText: 'New Password',
                    labelStyle:
                        TextStyle(color: Theme.of(context).textSelectionColor),
                  ),
                  obscureText: true,
                  validator: validatePassword,
                  onChanged: (val) {
                    setState(() => newPassword = val);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.lock,
                      color: Theme.of(context).textSelectionColor,
                    ),
                    hintText: 'Enter Your New Password Again',
                    labelText: 'Confirm New Password',
                    labelStyle:
                        TextStyle(color: Theme.of(context).textSelectionColor),
                  ),
                  obscureText: true,
                  validator: validateNewPassword,
                  onChanged: (val) {
                    setState(() => confirmPassword = val);
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
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: SizedBox(
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
      if (this.mounted) {
        setState(() => loading = true);
      }
      var data = {
        'new_password': newPassword,
        'confirm_new_password': confirmPassword,
      };

      // Make API call
      var endPoint = 'user/change-password';
      var result = await CallApi().postAuthData(data, endPoint);
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
