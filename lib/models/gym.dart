import 'dart:convert';
import 'dart:async';
import 'package:timer/models/user.dart';
import 'package:timer/util.dart';
import 'package:timer/webapi.dart';

class Gym {
  DateTime _created;
  DateTime _edit;
  String _name;
  int _nrRutes = 0;

  get nrRutes => _nrRutes;

  User _admin;
  get admin => _admin;
  get name => _name;
  set name(val) {
    _name = val;
    save();
  }
  String _uuid;
  get uuid => _uuid;
  Set<String> _sectors = Set<String>();
  get sectors => _sectors;
  List<String> _tags = List<String>();
  static List<Function> _listeners = List<Function>();

  static void addListener(Function f) {
    _listeners.add(f);
  }


  static Gym unknown = Gym._internal("unknown-gym", "Unknown Gym", DateTime(1), DateTime(1), Set<String>(), []);


  static final Map<String, Gym> _cache = <String, Gym>{unknown.uuid: unknown};


  Gym._internal(this._uuid, this._name, this._created, this._edit, this._sectors, this._tags);



  static Future<void> refreshGyms() async {

    _listeners.forEach((f) => f());
  }

  static Gym fromName(String name) {
    Gym result;
    _cache.forEach((key, value) {if(value.name == name) result = value;});

    return result;
  }


  static Gym fromUUID(String uuid) {
    if(!_cache.containsKey(uuid)) return Gym.unknown;
    return _cache[uuid];
  }

  Gym.fromJson(Map map) {
    _uuid = map["uuid"];
    _name = map["name"];
    _admin = User.fromUUID(map["admin"]);

    if(map["sectors"] != null) {
      if(map["sectors"] is List<dynamic>) {
        List<dynamic> list = map["sectors"];
        _sectors.addAll(list.map((d) => d.toString()));
      }
      else {
        json.decode(map["sectors"]).forEach((s) => _sectors.add(s));
      }
    }
    if(map["tags"] != null) {
      try {
        json.decode(map["tags"]).forEach((s) => _tags.add(s));
      }
      catch(e) {
        // I guess we didn't work - we assume there are none
      }
    }
    _created = parse(map["date"]);
    _edit = map.containsKey("edit") ? _edit = parse(map["edit"]) : _created;
    _nrRutes = map["n_rutes"];
  }

  Map<String, Object> toJson() {
    Map<String, Object> map = Map();
    map["uuid"] = _uuid;
    map["name"] = _name;
    map["admin"] = _admin.uuid;
    map["sectors"] = _sectors.toList();
    map["tags"] = _tags;
    map["date"] = format(_created);
    map["edit"] = format(_edit);
    map["n_rutes"] = _nrRutes;
    return map;
  }

  void save() {
    WebAPI.saveGym(this);
  }


  void addSector(String sector) {
    sectors.add(sector);
    save();
  }

  void removeSector(String sector) {
    sectors.remove(sector);
    save();
  }

  @override
  String toString() {
    return "Gym<$_name - $_uuid>";
  }


  bool operator == (o) => o is Gym && o.uuid == uuid;
  int get hashCode => uuid.hashCode;
}