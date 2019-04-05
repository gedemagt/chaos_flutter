import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/providers/imageprovider.dart';
import 'package:timer/models/point.dart';
import 'package:timer/providers/provider.dart';
import 'dart:async';
import 'package:timer/util.dart';
import 'package:timer/models/gym.dart';

import 'package:timer/models/user.dart';

class Rute {
  DateTime _created;
  DateTime _edit;
  String _name;
  String _uuid;
  String _sector;
  String _tag;
  User _author = User.unknown;
  List<RutePoint> _points;
  int _grade = 0;
  Gym _gym;
  Image _image;
  String _imageUUID;

  UUIDImageProvider prov = UUIDImageProvider();
  Provider<Rute> _myProvider;

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

  set grade(val) {
    _grade = val;
    save();
  }

  Rute._internal(this._uuid, this._name, this._created, this._edit, this._author, this._points, this._grade, this._myProvider);

  Rute.create(String name, String sector, String imageUUID, Provider<Rute> provider)  {

    _myProvider = provider;
    _uuid = getUUID("rute");
    _created = DateTime.now();
    _edit = _created;
    _author = StateManager().loggedInUser;
    _points = List<RutePoint>();
    _grade = 0;
    _imageUUID = imageUUID;
    _gym = StateManager().gym;
    _name = name;
    _sector = sector;
    _tag = "";

    provider.add(this);
  }


  void addPoint(RutePoint p) {
    _points.add(p);
    save();
  }

  void removePoint(RutePoint p) {
    _points.remove(p);
    save();
  }

  void save() {
    _myProvider.save(this);
  }

  void delete() {
    _myProvider.delete(this);
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

  Rute.fromJson(Map map, Provider<Rute> prov) {

    _myProvider = prov;

    _imageUUID = map["image"];
    _uuid = map["uuid"];
    _name = map["name"];
    _gym = Gym.fromUUID(map["gym"]);
    _sector = map["sector"];
    _tag = map["tag"];
    _name = map["name"];
    _author = User.fromUUID(map["author"]);
    try {
      _grade = int.parse(map["grade"]);
    } catch (e) {
      _grade = 0;
    }
    _created = map.containsKey("date") ? DateTime.parse(map["date"]) : DateTime(1970);
    _edit = map.containsKey("edit") ? DateTime.parse(map["edit"]) : _created;

    String coordinates = map["coordinates"];
    // Hacky, yes
    if(coordinates != null && coordinates != "[]") {
      coordinates = map["coordinates"].replaceAll(new RegExp(r'f'), '').replaceAll(RegExp("}{"), "},{");
      if(!coordinates.endsWith("}]")) {
        coordinates = coordinates.replaceAll(RegExp("]"), "}]");
      }
    }

    _points = List<RutePoint>();
    if(coordinates != null) {
      json.decode(coordinates).forEach((val) {
        RutePoint rp = RutePoint.ofSize(val["x"], val["y"], val["size"]);
        rp.type = stringToType(val["type"]);
        _points.add(rp);
      });

    }
  }

  @override
  String toString() {
    return "Rute<$_name - $_uuid>";
  }


  bool operator == (o) => o is Rute && o.uuid == uuid;
  int get hashCode => uuid.hashCode;

}