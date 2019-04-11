import 'dart:convert';
import 'package:timer/StateManager.dart';
import 'package:timer/models/user.dart';
import 'package:timer/util.dart';

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

  static Gym unknown = Gym._internal("unknown-gym", "Unknown Gym", User.unknown, DateTime(1), DateTime(1), Set<String>(), [], 0);


  Gym._internal(this._uuid, this._name, this._admin, this._created, this._edit, this._sectors, this._tags, this._nrRutes);


  static Future<Gym> fromJson(Map map) async {
    String _uuid = map["uuid"];
    String _name = map["name"];
    User _admin = await StateManager().db.getUser(map["admin"]);
    Set<String> _sectors = Set();
    List<String> _tags = List();
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
    DateTime _created = parse(map["date"]);
    DateTime _edit = map.containsKey("edit") ? parse(map["edit"]) : _created;
    int _nrRutes = map["n_rutes"];
    return Gym._internal(_uuid, _name, _admin, _created, _edit, _sectors, _tags, _nrRutes);
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
    StateManager().db.saveGym(this);
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