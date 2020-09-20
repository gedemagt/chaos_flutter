import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/pages/loginpage.dart';
import 'package:timer/pages/homepage.dart';
import 'package:timer/models/gym.dart';
import 'package:timer/pages/gymspage.dart';

Future main() async {



  WidgetsFlutterBinding.ensureInitialized();
  await StateManager().init();

//  var docs = await Firestore.instance.collection('gyms').getDocuments();
//
//  var admin = await docs.documents[0].data["admin"].get();
//  print(admin.toString());

  Widget _default;

//  if(!StateManager().db.isLoggedIn()) {
  _default = LoginPage();
//  }
//  else if(StateManager().gym == Gym.unknown || StateManager().gym == null) {
//    _default = GymsPage();
//  }
//  else {
//    _default = RuteListPage();
//  }


  runApp(MaterialApp(
    home: _default
  ));
}



