import 'dart:convert';

import 'package:Expense/UI/shared/color.dart';
import 'package:Expense/UI/shared/general.dart';
import 'package:Expense/UI/shared/loading.dart';
import 'package:Expense/UI/views/home_page.dart';
import 'package:Expense/blocs/sign_in_bloc.dart';
import 'package:Expense/core/services/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool loading = false;
  bool em = false;
  bool pa = false;

  String email = '';
  String password = '';
  String error = '';

  // Handle Sign In
  void _handleSignIn() async {
    setState(() => loading = true);

    var data = {'email': email, 'password': password};

    // Make API call
    var result = await CallApi().postData(data, 'login');
    var body = json.decode(result.body);
    if (body['success']) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', json.encode(body['token']));
      localStorage.setString('user', json.encode(body['user']));
      localStorage.setString('userRoles', json.encode(body['roles']));
      localStorage.setString('userProfile', json.encode(body['profile']));
      // Navigate to HomeScreen()
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      setState(() {
        error = 'Authentication failed, please supply valid credential';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final signInBloc = SignInBloc();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: viewportConstraints.maxHeight),
            child: IntrinsicHeight(
              child: loading
                  ? Loading()
                  : Material(
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            ClipPath(
                              clipper: MyClipper(),
                              child: header("assets/heda.png"),
                            ),
                            title(context),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0, top: 20.0),
                              child: Text(
                                error,
                                style: TextStyle(
                                  color: cred,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  top: 35.0, left: 20.0, right: 20.0),
                              child: Column(
                                children: <Widget>[
                                  StreamBuilder<String>(
                                    stream: signInBloc.email,
                                    builder: (context, snapshot) => TextField(
                                      onChanged: (s) {
                                        signInBloc.emailChanged.add(s);
                                        if (s.length > 7) {
                                          setState(() {
                                            em = true;
                                            email = s;
                                          });
                                        } else {
                                          setState(() {
                                            em = false;
                                          });
                                        }
                                      },
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: "Enter email address",
                                        labelStyle: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: cgrey,
                                        ),
                                        errorText: snapshot.error,
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: cgrey),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  StreamBuilder<String>(
                                    stream: signInBloc.password,
                                    builder: (context, snapshot) => TextField(
                                      onChanged: (s) {
                                        signInBloc.passwordChanged.add(s);
                                        if (s.length > 7) {
                                          setState(() {
                                            pa = true;
                                            password = s;
                                          });
                                        } else {
                                          setState(() {
                                            pa = false;
                                          });
                                        }
                                      },
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        labelText: "Password",
                                        labelStyle: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: cgrey,
                                        ),
                                        errorText: snapshot.error,
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: cgrey),
                                        ),
                                      ),
                                      obscureText: true,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 40.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  color: Theme.of(context).primaryColor,
                                  textColor: Theme.of(context).accentColor,
                                  onPressed: em
                                      ? pa
                                          ? () async {
                                              _handleSignIn();
                                            }
                                          : null
                                      : null,
                                  child: Text(
                                    "Sign In".toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "New to iCMS?",
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Text(
                                    "Contact HR For Account Settup",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.lineTo(size.width, 0.0);
    p.lineTo(size.width, size.height * 0.85);
    p.arcToPoint(Offset(0.0, size.height * 0.85),
        radius: const Radius.elliptical(50.0, 10.0), rotation: 0.0);
    p.lineTo(0.0, 0.0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
