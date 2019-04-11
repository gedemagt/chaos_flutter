import 'dart:convert';
import 'dart:io';

import 'package:flutter/src/widgets/image.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/models/gym.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/models/user.dart';
import 'package:timer/providers/database.dart';
import 'package:timer/util.dart';
import 'package:timer/webapi.dart';

class WebDatabase extends Database {

  @override
  Future<Gym> createGym(String name, User admin, {List<String> sectors, List<String> tags}) async {
    String uuid = await WebAPI.createGym(name, sectors.toSet(), admin);
    await refreshGyms();
    return getGym(uuid);
  }

  @override
  Future<Rute> createRute(String name, String sector, String imageUUID, File image) async {
    await WebAPI.uploadImage(imageUUID, image: image);
    String uuid = getUUID("rute");
    await WebAPI.createRute(uuid, name, imageUUID, getLoggedInUser(), sector, StateManager().gym, 0);
    await refreshRutes();
    return getRute(uuid);
  }
  
  @override
  Future<User> createUser(String name, String email, String password) async {
    String uuid = await WebAPI.createUser(name, email, password);
    await refreshUsers();
    return getUser(uuid);
  }

  @override
  Future<void> deleteGym(Gym gym) {
    throw Exception("Not implemented!");
  }

  @override
  Future<void> deleteRute(Rute rute) async {
    WebAPI.deleteRute(rute);
    ruteCache.remove(rute);
    ruteStream.sink.add(getRutes());
  }

  @override
  Future<Gym> getGym(String uuid) async {
    if(gymCache != null && gymCache.length==0) {
      print("[WebDatabase] Gym cache seems empty - refreshing...");
      await refreshGyms();
    }
    Gym cached = gymCache[uuid];
    if(cached == null) {
      return Gym.unknown;
    }
    return cached;
  }

  @override
  Future<Rute> getRute(String uuid) async {
    Rute cached = ruteCache[uuid];
    return cached;
  }

  @override
  Future<User> getUser(String uuid) async {
    if(uuid == User.unknown.uuid) return User.unknown;
    if(userCache != null && userCache.length==0) {
      print("[WebDatabase] User cache seems empty - refreshing...");
      await refreshUsers();
    }

    User result = User.unknown;
    if(!userCache.containsKey(uuid)) {
      print("[WebDatabase] User $uuid not in cache. We try to download..");
      result = await WebAPI.getUser(uuid);
      if(result != User.unknown) userCache[uuid] = result;
    }
    else {
      result = userCache[uuid];
    }


    return result;
  }

  @override
  Future<void> refreshGyms() async {
    try {
      List<Gym> gyms = await WebAPI.downloadGyms();
      print(gyms);
      gymCache.clear();
      gyms.forEach((g) => gymCache[g.uuid] = g);
      gymStream.sink.add(getGyms());
    }
    catch (o) {
      gymStream.sink.addError(o);
    }
  }

  @override
  Future<void> refreshRutes() async {
    try {
      List<Rute> rutes = await WebAPI.downloadRutes(StateManager().gym);
      ruteCache.clear();
      rutes.forEach((r) => ruteCache[r.uuid] = r);
      ruteStream.sink.add(getRutes());
    } catch(o) {
      ruteStream.sink.addError(o);
    }

  }

  @override
  Future<void> refreshUsers() async {
    try {
      List<User> users = await WebAPI.downloadUsers(StateManager().gym);
      userCache.clear();
      users.forEach((u) => userCache[u.uuid] = u);
      userStream.sink.add(getUsers());
    } catch(o) {
      userStream.sink.addError(o);
    }
  }

  @override
  Future<Gym> saveGym(Gym gym) async {
    WebAPI.saveGym(gym);
    return gym;
  }

  @override
  Future<Rute> saveRute(Rute rute) async {
    WebAPI.saveRute(rute);
    return rute;
  }

  @override
  Future<User> saveUser(User user) async {
    throw Exception("Not implemented yet");
  }

  @override
  Future<void> init() async {
    await WebAPI.init();
    SharedPreferences sp = await SharedPreferences.getInstance();
    String loggedInUUID = sp.getString("loggedIn");
    if(loggedInUUID != null) {
      _loggedin = User.fromJson(json.decode(loggedInUUID));
      print("[WebDatabase] Loaded loggedInUser: $_loggedin");
    }
  }

  @override
  Future<Complete> complete(User u, Rute r, int tries) async {
    WebAPI.complete(u, r, tries);
    return Complete(u, r, tries, DateTime.now());
  }

  @override
  User getLoggedInUser() {
    return _loggedin;
  }

  @override
  bool isLoggedIn() {
    return WebAPI.hasBeenLoggedIn() && _loggedin != null && _loggedin != User.unknown;
  }
  
  User _loggedin;

  void rememberLoggedIn(User u) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("loggedIn", u != null ? json.encode(u.toJson()): null);
  }

  @override
  Future<User> login(String username, String password) async {
    _loggedin = await WebAPI.login(username, password);
    rememberLoggedIn(_loggedin);
    print("[WebDatabase] New logged in user: $_loggedin");
    return _loggedin;
  }

  @override
  Future<void> logout() async {
    await WebAPI.logout();
    print("[WebDatabase] Logged out $_loggedin");
    _loggedin = null;
    rememberLoggedIn(null);
  }

  static Map<String, Image> _cache = Map<String, Image>();

  @override
  Future<Image> getImage(String uuid) async {
    if(!_cache.containsKey(_cache)) {
      final d = await getApplicationDocumentsDirectory();
      String newPath = join(d.path, "$uuid.jpg");
      File f = new File(newPath);
      if(await f.exists()) _cache[uuid] = Image.file(f);
      else _cache[uuid] = WebAPI.downloadImage(uuid);
    }

    return _cache[uuid];
  }

}