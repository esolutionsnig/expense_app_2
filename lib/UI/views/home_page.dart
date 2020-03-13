import 'dart:async';

import 'package:Expense/authentication_state.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamController<AuthenticationState> _streamController;
  signOut() {
    _streamController.add(AuthenticationState.signedOut());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
      body: Center(
        child: RaisedButton(
          child: Text('Sign Out'),
          onPressed: signOut,
        ),
      ),
    );
  }
}