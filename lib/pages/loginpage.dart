import 'dart:io';

import 'package:flutter/material.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/models/gym.dart';
import 'package:timer/pages/gymspage.dart';
import 'package:timer/pages/homepage.dart';
import 'package:timer/pages/registeruser.dart';
import 'package:timer/webapi.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoggingIn = false;

  bool invalid = false;

  GlobalKey<ScaffoldState> ss = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final emailField = TextField(
      obscureText: false,
      style: style,
      controller: usernameController,

      decoration: InputDecoration(
        errorText: invalid ? "Invalid credentials" : null,
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Username/email",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),

    );

    final passwordField = TextField(
      obscureText: true,
      style: style,
      controller: passwordController,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );


    Widget loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {

          setState(() {
            _isLoggingIn = true;
          });
          WebAPI.login(usernameController.text, passwordController.text).then((u) {
            if(StateManager().gym == Gym.unknown)
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GymsPage()));
            else
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RuteListPage()));
          }, onError: (k) {
            print(k.toString());
            String text = "Wrong credentials";
            if(k is SocketException)
              text = "Internet problems...";
            setState(() {
              _isLoggingIn = false;
              ss.currentState.showSnackBar(SnackBar(content: Text(text)));
            });
          });
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    Widget register = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterUserPage()));
        },
        child: Text("Register new user",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    if(_isLoggingIn) {
      loginButon = Center(
        child: CircularProgressIndicator()
      );
      register = Container();
    }

    return Scaffold(
      key: ss,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 45.0),
                emailField,
                SizedBox(height: 25.0),
                passwordField,
                SizedBox(
                  height: 35.0,
                ),
                loginButon,
                SizedBox(
                  height: 25.0,
                ),
                register,
                SizedBox(
                  height: 45.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}