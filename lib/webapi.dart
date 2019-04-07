import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:convert' as conv;

import 'package:async/async.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/models/gym.dart';
import 'package:timer/providers/webdatabase.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:timer/util.dart';
import 'package:timer/pages/exceptions.dart';


class WebAPI {

  static const String HOST = "195.201.200.125/chaos";
  //static const String HOST = "10.0.2.2:5000";

  static String _cookie = "";

  static bool hasBeenLoggedIn() {
    return _cookie != null && _cookie != "";
  }

  static void handleRequest(BaseResponse r) {
    Exception e;
    if(r.statusCode >= 500)
      e = ServerException("Server error: ${r.statusCode}");
    else if(r.statusCode == 401 || r.statusCode == 403)
      e = AuthenticationException("Unauthorized: ${r.statusCode}");
    else if(r.statusCode == 413 )
      e = InvalidContentException("Content to large: ${r.statusCode}");
    else if(r.statusCode >= 400)
      e = InvalidContentException("Bad request: ${r.statusCode}");

    if(e != null) {
      print("Throwing exception from request '${r.request.url}' based on status code ${r.statusCode}");
      throw e;
    }
  }

  static bool _hasBeenInitialized = false;

  static Future<void> init() async {
  
    print("Initializing WebAPI");

    if(_hasBeenInitialized) {
      print("Trying to reinitialize WebAPI");
      return;
    }
    SharedPreferences sp  = await SharedPreferences.getInstance();
    String cookie = sp.getString("cookie");
    _cookie = cookie != null ? cookie : "";
    _hasBeenInitialized = true;
    print("WebAPI cookie: $cookie");
  }


  static Future<User> login(String username, String password) async {
    User result;
    Response r = await _postJson("login",
        body: {"username": username, "password": password}
    );

    print("WebAPI: Logging in user '$username'");

    String rawCookie = r.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      String cookie =
      (index == -1) ? rawCookie : rawCookie.substring(0, index);
      _cookie = cookie;
      print("WebAPI: new session cookie: $cookie");
    }

    result = await getUser(r.body);

    StateManager().loggedInUser = result;

    SharedPreferences.getInstance().then((sp) {
      sp.setString("cookie", _cookie);
    });

    return result;
  }

  static Future<User> getUser(String uuid) async {
    Response r = await _get("get_user/$uuid");
    Map m = json.decode(r.body);
    User u = User.fromJson(m.values.first);
    print("WebAPI: Downloading user $uuid: '$u'");
    return u;

  }

  static Future <List<User>> downloadUsers(Gym gym) async {
    List<User> users = List<User>();
    var result = await _get("get_users");
    Map j = json.decode(result.body);
    for(var entry in j.entries) {
      users.add(User.fromJson(entry.value));
    }
    print("WebAPI: Downloading users '${users.length} ($gym)'");
    return users;
  }

  static Future<List<Gym>> downloadGyms() async {
    List<Gym> gyms = List<Gym>();
    var result = await _get("get_gyms");
    Map j = json.decode(result.body);
    for(var entry in j.entries) {
      gyms.add(await Gym.fromJson(entry.value));
    }
    print("WebAPI: Downloading gyms '${gyms.length}'");
    return gyms;
  }

  static Future<Gym> downloadGym(String uuid) async {
    Gym gym = Gym.unknown;
    var result = await _get("get_gym/$uuid");
    Map j = json.decode(result.body);
    gym = await Gym.fromJson(j[uuid]);
    print("WebAPI: Downloading gym $uuid: '$gym'");
    return gym;
  }

  static Image downloadImage(String imageUUID) {
    print("WebAPI: Downloading image '$imageUUID'");
    return Image.network("http://" + HOST + "/download/$imageUUID", headers: {"cookie": _cookie});
  }

  static Future<void> uploadImage(String imageUUID, {File image}) async {

      if(image == null) {
        final d = await getApplicationDocumentsDirectory();
        String newPath = join(d.path, "$imageUUID.jpg");
        File f = new File(newPath);
        image = f;
        print("Found image '$newPath' locally");
      }

      var stream = new http.ByteStream(DelegatingStream.typed(image.openRead()));
      print(getURI(HOST, "/add_image/$imageUUID"));
      var req = http.MultipartRequest("POST", getURI(HOST, "add_image/$imageUUID"));
      req.headers["cookie"] = _cookie;
      var multipartFile = new http.MultipartFile('data', stream, await image.length(),
          filename: basename(image.path));
      req.files.add(multipartFile);
      var response = await req.send();
      handleRequest(response);
      print("WebAPI: Uploading image '$imageUUID'");
  }


  static Future<List<Rute>> downloadRutes(Gym gym) async {
    List<Rute> rutes = List<Rute>();
    var result = await _get("get_rutes",
        headers: {"gym": gym.uuid});
    Map j = json.decode(result.body);

    for(var entry in j.entries) {

      var val = entry.value;
      if (!(val is Map)) {
        //print("Could not parse $val");
      }
      else if(val["status"] == 1) {
        //print("Skipping deleted rute");
      }
      else{
        rutes.add(await Rute.fromJson(val, WebDatabase()));
      }
    }
    print("WebAPI: Downloading rutes ${rutes.length} (filter=$gym)");
    return rutes;
  }

  static Future<String> createUser(String username, String email, String password) async {
    String uuid = getUUID("user");

    await _postJson("add_user",
      body: {
        "username": username,
        "password": password,
        "email": email,
        "uuid": uuid
      }
    );
    print("[WebAPI] Creating user '$username ($uuid - $email)'");
  }

  static Future<void> createRute(String uuid, String name, String imageUUID, User author, String sector, Gym g, int grade) async {
    DateTime now = DateTime.now();
    await _postJson("add_rute",
      body: {
        "uuid": uuid,
        "name": name,
        "image": imageUUID,
        "author": author.uuid,
        "sector": sector,
        "gym": g.uuid,
        "grade": grade,
        "tag": "",
        "date": format(now),
        "edit": format(now)
      }
    );
    print("[WebAPI] Creating rute '$name ($uuid - $imageUUID - $author - $g)'");
    return uuid;
  }

  static Future<void> saveRute(Rute t) async {
    DateTime now = DateTime.now();
    await _postJson("save_rute",
      body: {
        "uuid": t.uuid,
        "name": t.name,
        "sector": t.sector,
        "gym": t.gym.uuid,
        "grade": t.grade,
        "tag": "",
        "coordinates": json.encode(t.points),
        "edit": format(now)
      }
    );
    print("[WebAPI] Saving rute '$t'");
  }

  static Future<void> saveGym(Gym g) async {
    DateTime now = DateTime.now();
    await _postJson("save_gym",
      body: {
        "uuid": g.uuid,
        "name": g.name,
        "sectors": json.encode(g.sectors.toList()),
        "tags": "[]",
        "edit": format(now)
      }
    );
    print("[WebAPI] Saving gym '$g'");
  }

  static Future<void> deleteRute(Rute t) async {
    await _get("delete/" + t.uuid);
    print("[WebAPI] Deleting rute $t");
  }

  static Future<void> logout() async {
    StateManager().loggedInUser = null;
    _cookie = "";
    await _get("logout");
    print("[WebAPI] Logging out");
  }

  static Future<String> createGym(String text, Set<String> sectors, User admin) async {
    String uuid = getUUID("gym");

    await _postJson("add_gym",
      body: {
        "uuid": uuid,
        "name": text,
        "sectors": json.encode(sectors.toList()),
        "tags": "[]",
        "admin": admin.uuid
      }
    );

    print("[WebAPI] Creating gym '$text ($uuid)'");

    return uuid;
  }


  // Encodes body if json is true and body is not a string
  static Future<Response> _post(String dest, {Map<String, String> headers, dynamic body, Encoding encoding}) async {
    if(headers == null)
      headers = Map<String, String>();

    headers["cookie"] = _cookie;

    Response r = await http.post(getURI(HOST, dest), headers:headers, body:body, encoding: encoding);
    handleRequest(r);
    return r;

  }

  // Encodes body if json is true and body is not a string
  static Future<Response> _postJson(String dest, {Map<String, String> headers, Map body, Encoding encoding}) async {
    if(headers == null)
      headers = Map<String, String>();

    headers["content-type"] = 'application/json';

    String payload = conv.json.encode(body);

    headers["cookie"] = _cookie;

    return _post(dest, headers:headers, body:payload, encoding: encoding);
  }


  static Future<Response> _get(String dest, {Map<String, String> headers}) async {
    if(headers == null)
      headers = Map<String, String>();

    headers["cookie"] = _cookie;

    Response r = await http.get(getURI(HOST, dest), headers:headers);
    handleRequest(r);
    return r;

  }

  static Uri getURI(String host, String dest) {
    if(dest.startsWith("/")) dest = dest.replaceFirst("/", "");

    if (host.contains("/")) {
      List<String> parts = split(host);
      host = parts[0];
      List<String> last = parts.getRange(1, parts.length).toList();
      last.addAll(split(dest));
      dest = joinAll(last);
    }
    return Uri.http(host, dest);
  }

}