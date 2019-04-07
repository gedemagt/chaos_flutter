import 'package:flutter/material.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/pages/loginpage.dart';
import 'package:timer/pages/homepage.dart';
import 'package:timer/webapi.dart';
import 'package:timer/models/gym.dart';
import 'package:timer/pages/gymspage.dart';

Future main() async {

  await WebAPI.init();
  await StateManager().init();

  Widget _default;

  if(!WebAPI.hasBeenLoggedIn()) {
    _default = LoginPage();
  }
  else if(StateManager().gym == Gym.unknown) {
    _default = GymsPage();
  }
  else {
    _default = RuteListPage();
  }


  runApp(MaterialApp(
    home: _default
  ));
}



