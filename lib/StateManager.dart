import 'dart:convert';

import 'package:timer/models/gym.dart';
import 'package:timer/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateManager {
  static final StateManager _singleton = new StateManager._internal();

  factory StateManager() {
    return _singleton;
  }

  StateManager._internal();

  Gym _gym = Gym.unknown;
  User _loggedInUser = User.unknown;


  get gym => _gym;
  get loggedInUser => _loggedInUser;

  set gym(val) {
    print("Setting default gym to ${val.toString()}");
    SharedPreferences.getInstance().then((sp) {
      sp.setString("gym", json.encode(val.toJson()));
    });
    _gym = val;
  }

  set loggedInUser(val) {
    print("Setting logged in user to ${val.toString()}");
    SharedPreferences.getInstance().then((sp) {
      sp.setString("loggedIn", val != null ? json.encode(val.toJson()): null);
    });
    _loggedInUser = val;
  }

  void init() async {
    print("Initializing StateManger()");
    SharedPreferences sp = await SharedPreferences.getInstance();
    String loggedInUUID = sp.getString("loggedIn");
    if(loggedInUUID != null) {
      print("Loaded loggedInUser: $_loggedInUser");
      _loggedInUser = User.fromJson(json.decode(loggedInUUID));
    }
    print("Loaded gym: $_loggedInUser");
    String rememberedGym = sp.get("gym");
    try {
      _gym = Gym.fromJson(json.decode(rememberedGym));
    } catch(e) {
      print("Error loading gym");
      print(e.toString());
      _gym = Gym.unknown;
    }
  }

}