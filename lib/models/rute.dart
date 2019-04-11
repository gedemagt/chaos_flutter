import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:timer/providers/database.dart';
import 'package:timer/providers/imageprovider.dart';
import 'package:timer/models/point.dart';
import 'dart:async';
import 'package:timer/util.dart';
import 'package:timer/models/gym.dart';

import 'package:timer/models/user.dart';

class Complete {
  final User u;
  final Rute r;
  final int retries;
  final DateTime date;

  Complete(this.u, this.r, this.retries, this.date);

  @override
  String toString() {
    return "Complete<${u.name} - ${r.name} - $retries>}";
  }

  @override
  bool operator ==(other) {
    return u == other.u && r == other.r;
  }

  @override
  int get hashCode => u.hashCode * 3 * r.hashCode;
}

class Rute {
  String _name;
  String _uuid;
  DateTime _created;
  DateTime _edit;
  User _author = User.unknown;
  List<RutePoint> _points;
  int _grade = 0;
  Database _myProvider;
  String _sector;
  String _imageUUID;
  Gym _gym;

  Set<Complete> _completes = Set();

  String _tag;
  Image _image;

  UUIDImageProvider prov = UUIDImageProvider();


  get image => _image;
  get name => _name;
  get uuid => _uuid;
  get points => _points;
  get author => _author;
  get grade => _grade;
  get gym => _gym;
  get sector => _sector;
  get date => _created;
  get edit => _edit;
  get imageUUID => _imageUUID;
  get completes => _completes;

  set grade(val) {
    _grade = val;
    save();
  }

  Rute._internal(
      this._uuid,
      this._name,
      this._created,
      this._edit,
      this._author,
      this._points,
      this._grade,
      this._myProvider,
      this._sector,
      this._imageUUID,
      this._gym,
      this._tag);

  Future<void> complete(User u, int tries) async {
    Complete c = await _myProvider.complete(u, this, tries);
    _completes.add(c);
  }

  bool hasCompleted(User u) {
    return _completes.any((c) => c.u==u);
  }

  void addPoint(RutePoint p) {
    _points.add(p);
    save();
  }

  void removePoint(RutePoint p) {
    print("To remove " + p.toString());
    print(_points);
    _points.remove(p);
    save();
  }

  void save() {
    _myProvider.saveRute(this);
  }

  void delete() {
    _myProvider.deleteRute(this);
  }

  Future<Image> getImage() async {
    return prov.getImage(_imageUUID);
  }

  Map toJsonMap() {
    return {
      "uuid": _uuid,
      "name": _name,
      "gym": _gym.uuid,
      "image": _imageUUID,
      "sector": _sector,
      "tag": _tag,
      "author": _author.uuid,
      "grade": _grade
    };
  }

  static Future<Rute> fromJson(Map map, Database prov) async {


    String _imageUUID = map["image"];
    String _uuid = map["uuid"];
    String _name = map["name"];
    Gym _gym = await prov.getGym(map["gym"]);
    String _sector = map["sector"];
    String _tag = map["tag"];
    User _author = await prov.getUser(map["author"]);
    int _grade = 0;
    try {
      _grade = int.parse(map["grade"]);
    } catch (e) {
      _grade = 0;
    }
    DateTime _created = map.containsKey("date") ? DateTime.parse(map["date"]) : DateTime(1970);
    DateTime _edit = map.containsKey("edit") ? DateTime.parse(map["edit"]) : _created;

    String coordinates = map["coordinates"];
    // Hacky, yes
    if(coordinates != null && coordinates != "[]") {
      coordinates = map["coordinates"].replaceAll(new RegExp(r'f'), '').replaceAll(RegExp("}{"), "},{");
      if(!coordinates.endsWith("}]")) {
        coordinates = coordinates.replaceAll(RegExp("]"), "}]");
      }
    }

    List _points = List<RutePoint>();
    if(coordinates != null) {
      json.decode(coordinates).forEach((val) {
        RutePoint rp = RutePoint.ofSize(val["x"], val["y"], val["size"]);
        rp.type = stringToType(val["type"]);
        _points.add(rp);
      });

    }

    var rute = Rute._internal(_uuid, _name, _created, _edit, _author, _points, _grade, prov, _sector, _imageUUID, _gym, _tag);

    List completes = map["completes"];
    for(var k in completes) {
      Complete c = Complete(await prov.getUser(k["user"]), rute, k["tries"], parse(map["date"]));
      rute._completes.add(c);
    }

    return rute;
  }

  @override
  String toString() {
    return "Rute<$_name - $_uuid>";
  }


  bool operator == (o) => o is Rute && o.uuid == uuid;
  int get hashCode => uuid.hashCode;

}