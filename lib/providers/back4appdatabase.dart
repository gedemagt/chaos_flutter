import 'dart:io';

import 'package:timer/models/gym.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/models/user.dart';
import 'package:timer/providers/database.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class Back4AppDatabase extends Database {

  static final Back4AppDatabase _singleton = new Back4AppDatabase._internal();

  factory Back4AppDatabase() {
    return _singleton;
  }

  Back4AppDatabase._internal();

  @override
  Future<Complete> complete(User u, Rute r, int tries) {
    // TODO: implement complete
    return null;
  }

  @override
  Future<Gym> createGym(String name, User admin, {List<String> sectors, List<String> tags}) {
    // TODO: implement createGym
    return null;
  }

  @override
  Future<Rute> createRute(String name, String sector, String imageUUID, File image) {
    // TODO: implement createRute
    return null;
  }

  @override
  Future<User> createUser(String name, String email, String password) {
    // TODO: implement createUser
    return null;
  }

  @override
  Future<void> deleteGym(Gym gym) {
    // TODO: implement deleteGym
    return null;
  }

  @override
  Future<void> deleteRute(Rute rute) {
    // TODO: implement deleteRute
    return null;
  }

  @override
  Future<Gym> getGym(String uuid) {
    // TODO: implement getGym
    return null;
  }

  @override
  Future<Rute> getRute(String uuid) {
    // TODO: implement getRute
    return null;
  }

  @override
  Future<User> getUser(String uuid) {
    // TODO: implement getUser
    return null;
  }

  ParseUser _loggedIn;

  @override
  Future<void> init() async {
    Parse().initialize(
        "6Cq6SlSs1lE7eVHx7Gh7GndJ2SvYYqcyd7tpUonT",
        "https://chaos.back4app.io",
    masterKey: "3UMKaun5WFjB7tnab4HpzYUiIhFGv5LUM3brTdpH");
    var response = await ParseUser("jesper", "p","").getAll();
    print(response.count);

    //for(var r in response.result){
    //  print(r);
    //}
    return null;
  }

  @override
  Future<void> refreshGyms() {
    // TODO: implement refreshGyms
    return null;
  }

  @override
  Future<void> refreshRutes() {
    // TODO: implement refreshRutes
    return null;
  }

  @override
  Future<void> refreshUsers() {
    // TODO: implement refreshUsers
    return null;
  }

  @override
  Future<Gym> saveGym(Gym gym) {
    // TODO: implement saveGym
    return null;
  }

  @override
  Future<Rute> saveRute(Rute rute) {
    // TODO: implement saveRute
    return null;
  }

  @override
  Future<User> saveUser(User user) {
    // TODO: implement saveUser
    return null;
  }

}