import 'dart:convert';

import 'package:timer/models/gym.dart';
import 'package:timer/models/rute.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer/providers/database.dart';
import 'package:timer/providers/webdatabase.dart';

class StateManager {
  static final StateManager _singleton = new StateManager._internal();

  factory StateManager() {
    return _singleton;
  }

  final Database db = WebDatabase();

  StateManager._internal();

  Gym _gym = Gym.unknown;
  Rute _lastRute;
  get lastRute => _lastRute;
  set lastRute(val) => _lastRute = val;

  get gym => _gym;

  set gym(val) {
    print("[StateManager] Setting default gym to ${val.toString()}");
    SharedPreferences.getInstance().then((sp) {
      sp.setString("gym", json.encode(val.toJson()));
    });
    _gym = val;
  }

  Future<void> init() async {
    print("[StateManager] Initializing StateManger()");
    await db.init();
    SharedPreferences sp = await SharedPreferences.getInstance();

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