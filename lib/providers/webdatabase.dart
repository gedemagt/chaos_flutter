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
  Future<Rute> createRute(String name, String sector, String imageUUID) async {
    int r = await WebAPI.uploadImage(imageUUID);
    if(r == 413) {
      print("Problems!");
      throw Exception("File too big");
    }
    if(r >= 500) {
      throw Exception("Server error: $r");
    }
    if(r >= 400) {
      throw Exception("Authentication error: $r");
    }

    String uuid = await WebAPI.createRute(getUUID("rute"), name, imageUUID, StateManager().loggedInUser, sector, StateManager().gym, 0);
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
    Gym cached = getCachedGym(uuid);
    if(cached == null) {
      return Gym.unknown;
    }
    return cached;
  }

  @override
  Future<Rute> getRute(String uuid) async {
    Rute cached = getCachedRute(uuid);
    return cached;
  }

  @override
  Future<User> getUser(String uuid) async {
    User cached = getCachedUser(uuid);
    if(cached == null) {
      return WebAPI.getUser(uuid);
    }
    return User.unknown;
  }

  @override
  Future<void> refreshGyms() async {
    List<Gym> gyms = await WebAPI.downloadGyms();
    gymCache.clear();
    gyms.forEach((g) => gymCache[g.uuid] = g);
    gymStream.sink.add(getGyms());
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
    List<User> users = await WebAPI.downloadUsers(StateManager().gym);
    userCache.clear();
    users.forEach((u) => userCache[u.uuid] = u);
    userStream.sink.add(getUsers());
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

}