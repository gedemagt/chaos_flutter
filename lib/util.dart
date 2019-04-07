import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timer/StateManager.dart';

import 'package:timer/models/point.dart';
import 'package:timer/models/user.dart';

int typeToInt(Type type) {
  if(type == Type.START) return 1;
  if(type == Type.NORMAL) return 2;
  if(type == Type.END) return 3;
  return 0;
}

Type stringToType(String i) {
  if(i == "START" || i=="Type.START") return Type.START;
  if(i == "END" || i=="Type.END") return Type.END;
  return Type.NORMAL;
}

Type intToType(int i) {
  if(i == 1) return Type.START;
  if(i == 3) return Type.END;
  return Type.NORMAL;
}

bool canEdit(User u) {
  if(StateManager().loggedInUser.role == Role.ADMIN) return true;
  if(u == null) return false;
  if(u == User.unknown) return false;
  return StateManager().loggedInUser == u;
}

var colormap = {
  "grå": Colors.grey,
  "lilla": Colors.deepPurpleAccent,
  "gul": Colors.yellowAccent,
  "sort": Colors.black54,
  "grøn": Colors.greenAccent,
  "rød": Colors.redAccent
};

Color getColor(String s) {
  s = s.toLowerCase();
  Color result = Colors.blue;
  colormap.forEach((key,val) {
    if(s.contains(key)) result = val;
  });
  return result;
}

String getText(String s) {
  String result = "";
  if(s == null || s.isEmpty) {
    result = "NN";
  }
  else if(s.contains(" ")) {
    List<String> ss = s.split(" ");
    result = ss[0][0] + ss[1][0];
  }
  else {
    result = s[0] + s[s.hashCode % s.length];
  }

  return result.toUpperCase();
}

String getUUID(String prefix) {
  int i = DateTime.now().millisecondsSinceEpoch;
  var random =  new Random().nextInt(1000000);
  return "$prefix-$i-$random";
}

String numberToGrade(int number) {
  List<String> grades = [
    "4",
    "5",
    "5\u207A",
    "6a",
    "6a\u207A",
    "6b",
    "6b\u207A",
    "6c",
    "6c\u207A",
    "7a",
    "7a\u207A",
    "7b",
    "7b\u207A",
    "7c",
    "7c\u207A",
    "8a",
    "8a\u207A",
    "8b",
    "8b\u207A",
    "8c",
    "8c\u207A"
  ];
  return grades[number];
}

DateFormat _format = DateFormat("yyyy-MM-dd kk:mm:ss");

String format(DateTime dt) {
  return _format.format(dt);
}

DateTime parse(String s) {
  return _format.parse(s);
}


class MyVerticalDivider extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 30.0,
      width: 1.0,
      color: Colors.grey
    );
  }
}

