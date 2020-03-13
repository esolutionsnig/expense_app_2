import 'dart:convert';

import 'package:Expense/UI/views/Authentication/sign_in_page.dart';
import 'package:Expense/UI/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuilderPage extends StatefulWidget {
  @override
  _BuilderPageState createState() => _BuilderPageState();
}

class _BuilderPageState extends State<BuilderPage> {
  var userData;

  @override
  void initState() {
    _getUserInfo();
    super.initState();
  }

  void _getUserInfo() async {
    var user;
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    if (userJson != null) {
      user = json.decode(userJson);

      setState(() {
        userData = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // return either the Home or Authenticate widget
    if (userData == null) {
      return SignInPage();
    } else {
      return HomePage();
    }
  }
}
