import 'package:flutter/material.dart';
import 'package:timer/pages/gymspage.dart';
import 'package:timer/webapi.dart';

class RegisterUserPage extends StatefulWidget {
  RegisterUserPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RegisterUserPageState createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  final usernameController = TextEditingController();
  final email = TextEditingController();
  final passwordController = TextEditingController();

  bool _isRegistering = false;

  int _errorCode = 200;

  @override
  Widget build(BuildContext context) {
    final emailField = TextField(
      style: style,
      controller: email,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          //border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
    );

    final passwordField = TextField(
      obscureText: true,
      style: style,
      controller: passwordController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Password",
      ),
    );

    final usernameField = TextField(
      style: style,
      controller: usernameController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Username",
        errorText: _errorCode == 400 ? "Username already taken" : null
      ),
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
            _isRegistering = true;
          });


          WebAPI.createUser(usernameController.text, email.text, passwordController.text).then((u) {
            WebAPI.login(usernameController.text, passwordController.text).then((u){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GymsPage()));
            });
          }).catchError((statusCode) {
            setState(() {
              _isRegistering = false;
              print("Erro $statusCode");
              _errorCode = statusCode;
            });
          });
        },
        child: Text("Create",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    if(_isRegistering) {
      loginButon = Center(
        child: CircularProgressIndicator()
      );
    }

    return Scaffold(
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
//                SizedBox(
//                  height: 155.0,
//                  child: Image.asset(
//                    "assets/logo.png",
//                    fit: BoxFit.contain,
//                  ),
//                ),
                SizedBox(height: 45.0),
                usernameField,
                SizedBox(height: 25.0),
                emailField,
                SizedBox(height: 25.0),
                passwordField,
                SizedBox(
                  height: 35.0,
                ),
                loginButon,
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