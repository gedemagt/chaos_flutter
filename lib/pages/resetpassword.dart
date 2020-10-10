import 'package:flutter/material.dart';
import 'package:timer/webapi.dart';

class ResetPasswordPage extends StatefulWidget {
  ResetPasswordPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RegisterUserPageState createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<ResetPasswordPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  final email = TextEditingController();

  bool _isRegistering = false;

  var _icon;

  GlobalKey<ScaffoldState> ss = GlobalKey();

  @override
  Widget build(BuildContext context) {

    final emailField = TextField(
      style: style,
      controller: email,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          suffixIcon: _icon
      ),
    );



    Widget button = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          setState(() {
            _isRegistering = true;
          });
          WebAPI.resetPassword(email.text).then((value){
            setState(() {
              _isRegistering = false;
              _icon = Icon(Icons.check_circle, color: Colors.green);
            });
          }).catchError((errir) {
            setState(() {
              _isRegistering = false;
              _icon = Icon(Icons.error, color: Colors.red);
              ss.currentState.showSnackBar(SnackBar(content: Text(errir.cause)));
            });
          });
        },
        child: Text("Reset",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    if(_isRegistering) {
      button = Center(
        child: CircularProgressIndicator()
      );
    }

    return Scaffold(
      key: ss,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 25.0),
                emailField,
                SizedBox(
                  height: 35.0,
                ),
                button,
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}