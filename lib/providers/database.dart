import 'dart:async';

import 'package:timer/models/gym.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/models/user.dart';

abstract class Database {

  Future<User> saveUser(User user);
  Future<User> getUser(String uuid);
  Future<User> createUser(String name, String email, String password);

  Future<void> deleteRute(Rute rute);
  Future<Rute> saveRute(Rute rute);
  Future<Rute> getRute(String uuid);
  Future<Rute> createRute(String name, String sector, String imageUUID);

  Future<void> deleteGym(Gym gym);
  Future<Gym> saveGym(Gym gym);
  Future<Gym> getGym(String uuid);
  Future<Gym> createGym(String name, User admin, {List<String> sectors, List<String> tags});

  Future<void> refreshGyms();
  Future<void> refreshRutes();
  Future<void> refreshUsers();

  Future<void> refresh() async {
    await refreshUsers();
    await refreshGyms();
    await refreshRutes();
  }

  Map<String, Rute> ruteCache = Map();
  Map<String, User> userCache = Map();
  Map<String, Gym> gymCache = Map();

  Rute getCachedRute(String uuid) {
    return ruteCache[uuid];
  }

  Gym getCachedGym(String uuid) {
    return gymCache[uuid];
  }

  User getCachedUser(String uuid) {
    return userCache[uuid];
  }


  List<Rute> getRutes() {
    return ruteCache.values.toList();
  }

  List<User> getUsers() {
    return userCache.values.toList();
  }

  List<Gym> getGyms() {
    return gymCache.values.toList();
  }

  StreamController<List<Rute>> ruteStream = StreamController();
  StreamController<List<User>> userStream = StreamController();
  StreamController<List<Gym>>  gymStream = StreamController();

  void dispose() {
    ruteStream.close();
    userStream.close();
    gymStream.close();
  }

}