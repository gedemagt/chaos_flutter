import 'dart:convert';

import 'package:timer/models/gym.dart';
import 'package:timer/models/rute.dart';
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
  Rute _lastRute;
  get lastRute => _lastRute;
  set lastRute(val) => _lastRute = val;

  get gym => _gym;
  get loggedInUser => _loggedInUser;

  set gym(val) {
    print("[StateManager] Setting default gym to ${val.toString()}");
    SharedPreferences.getInstance().then((sp) {
      sp.setString("gym", json.encode(val.toJson()));
    });
    _gym = val;
  }

  set loggedInUser(val) {
    print("[StateManager] Setting logged in user to ${val.toString()}");
    SharedPreferences.getInstance().then((sp) {
      sp.setString("loggedIn", val != null ? json.encode(val.toJson()): null);
    });
    _loggedInUser = val;
  }

  Future<void> init() async {
    print("[StateManager] Initializing StateManger()");
    SharedPreferences sp = await SharedPreferences.getInstance();
    String loggedInUUID = sp.getString("loggedIn");
    print(loggedInUUID);
    if(loggedInUUID != null) {
      _loggedInUser = User.fromJson(json.decode(loggedInUUID));
      print("[StateManager] Loaded loggedInUser: $_loggedInUser");
    }

    String rememberedGym = sp.get("gym");
    try {
      _gym = await Gym.fromJson(json.decode(rememberedGym));
      print("[StateManager] Loaded gym: $gym");
    } catch(e) {
      print("[StateManager] Error loading gym - defaulting to gym.unknown");
      print(e.toString());
      _gym = Gym.unknown;
    }
  }

}