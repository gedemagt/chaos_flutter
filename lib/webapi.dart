import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:async/async.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/models/gym.dart';
import 'package:timer/providers/webprovider.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:timer/util.dart';


class WebAPI {

  static String _cookie = "";

  static bool hasBeenLoggedIn() {
    return _cookie != null && _cookie != "";
  }

  static void init() async {
  SharedPreferences sp  = await SharedPreferences.getInstance();
    String cookie = sp.getString("cookie");
    _cookie = cookie != null ? cookie : "";
  }


  static Future<User> login(String username, String password) async {
    User result;
    Response r = await http.post(Uri.http("10.0.2.2:5000", "/login"),
        body:json.encode({"username": username, "password": password}), headers: {"content-type": 'application/json'}
    );

    String rawCookie = r.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      String cookie =
      (index == -1) ? rawCookie : rawCookie.substring(0, index);
      _cookie = cookie;
    }

    result = await getUser(r.body);

    StateManager().loggedInUser = result;

    SharedPreferences.getInstance().then((sp) {
      sp.setString("cookie", _cookie);
    });

    return result;
  }

  static Future<User> getUser(String uuid) async {
    Response r = await _get(Uri.http("10.0.2.2:5000", "/get_user/$uuid"));
    if(r.statusCode > 299) {
      throw Exception("getUser: Unauthorized");
    }
    else {
      Map m = json.decode(r.body);
      return User.fromJson(m.values.first);
    }
  }

  static Future <List<User>> downloadUsers(Gym gym) async {
    List<User> users = List<User>();
    var result = await _get(Uri.http("10.0.2.2:5000", "/get_users"));
    Map j = json.decode(result.body);
    j.forEach((key, val) {
      User u = User.fromJson(val);
      users.add(u);
    });
    print("Updated users");
    return users;

  }

  static Future<List<Gym>> downloadGyms() async {
    List<Gym> gyms = List<Gym>();
    var result = await _get(Uri.http("10.0.2.2:5000", "/get_gyms"));
    Map j = json.decode(result.body);
    j.forEach((key, val) {
      Gym g = Gym.fromJson(val);
      gyms.add(g);
    });
    print("Updated gyms");
    return gyms;
  }

  static Future<Gym> downloadGym(String uuid) async {
    Gym gym = Gym.unknown;
    var result = await _get(Uri.http("10.0.2.2:5000", "/get_gym/$uuid"));
    Map j = json.decode(result.body);
    gym = Gym.fromJson(j[uuid]);
    return gym;
  }

  static Image downloadImage(String imageUUID) {
    return Image.network("http://10.0.2.2:5000" + "/download/$imageUUID", headers: {"cookie": _cookie});
  }

  static Future<int> uploadImage(String imageUUID, {File image}) async {

      if(image == null) {
        final d = await getApplicationDocumentsDirectory();
        String newPath = join(d.path, "$imageUUID.jpg");
        File f = new File(newPath);
        image = f;
        print("Found file locally");
      }


      var stream = new http.ByteStream(DelegatingStream.typed(image.openRead()));
      var req = http.MultipartRequest("POST", Uri.http("10.0.2.2:5000", "/add_image/$imageUUID"));
      req.headers["cookie"] = _cookie;
      var multipartFile = new http.MultipartFile('file', stream, await image.length(),
          filename: basename(image.path));
      req.files.add(multipartFile);
      var response = await req.send();
      return Future.value(response.statusCode);
  }


  static Future<List<Rute>> downloadRutes(Gym gym) async {
    List<Rute> rutes = List<Rute>();
    try {
      var result = await _get(Uri.http("10.0.2.2:5000", "/get_rutes"),
          headers: {"gym": gym.uuid});
      Map j = json.decode(result.body);
      j.forEach((key, val) {
        if (!(val is Map)) {
        //print("Could not parse $val");
        }
        else if(val["status"] == 1) {
          //print("Skipping deleted rute");
        }
        else{
          rutes.add(Rute.fromJson(val, WebRuteProvider()));
        }

      });
      print("Updated rutes");
    } catch(e) {
      print("Error loading rutes");
      print(e.toString());
    }
    return rutes;
  }

  static Future<String> createUser(String username, String email, String password) async {
    String uuid = getUUID("user");

    Response r = await _post(
      Uri.http("10.0.2.2:5000", "/add_user"),
      body:json.encode({
        "username": username,
        "password": password,
        "email": email,
        "uuid": uuid
      }),
      json: true
    );

    if(r.statusCode > 200)
      return Future.error(r.statusCode);
    else return uuid;
  }

  static Future<String> createRute(Rute t) async {
    DateTime now = DateTime.now();
    Response r = await _post(
      Uri.http("10.0.2.2:5000", "/add_rute"),
      body:json.encode({
        "uuid": t.uuid,
        "name": t.name,
        "image": t.imageUUID,
        "author": t.author.uuid,
        "sector": t.sector,
        "gym": t.gym.uuid,
        "grade": t.grade,
        "tag": "",
        "date": DateFormat("yyyy-MM-dd kk:mm:ss").format(now),
        "edit": DateFormat("yyyy-MM-dd kk:mm:ss").format(now)
      }),
      json: true
    );

    if(r.statusCode > 200)
      return Future.error(r.statusCode);
    else return t.uuid;
  }

  static Future<int> saveRute(Rute t) async {
    DateTime now = DateTime.now();
    Response r = await _post(
      Uri.http("10.0.2.2:5000", "/save_rute"),
      body:json.encode({
        "uuid": t.uuid,
        "name": t.name,
        "sector": t.sector,
        "gym": t.gym.uuid,
        "grade": t.grade,
        "tag": "",
        "coordinates": json.encode(t.points),
        "edit": DateFormat("yyyy-MM-dd kk:mm:ss").format(now)
      }),
      json: true
    );

    if(r.statusCode > 200)
      return Future.error(r.statusCode);
    else return r.statusCode;
  }

  static Future<int> saveGym(Gym g) async {
    DateTime now = DateTime.now();
    Response r = await _post(
      Uri.http("10.0.2.2:5000", "/save_gym"),
      body: json.encode({
        "uuid": g.uuid,
        "name": g.name,
        "sectors": json.encode(g.sectors.toList()),
        "tags": "[]",
        "edit": DateFormat("yyyy-MM-dd kk:mm:ss").format(now)
      }),
      json: true
    );

    if(r.statusCode > 200)
      return Future.error(r.statusCode);
    else return r.statusCode;
  }

  static Future<int> deleteRute(Rute t) async {
    Response r = await _get(
        Uri.http("10.0.2.2:5000",
        "/delete/" + t.uuid),
    );

    if(r.statusCode > 299)
      return Future.error(r.statusCode);
    else return r.statusCode;

  }

  static Future<int> logout() async {
    Response r = await _get(Uri.http("10.0.2.2:5000", "/logout"));


    if(r.statusCode > 299)
      return Future.error(r.statusCode);
    else {
      StateManager().loggedInUser = null;
      _cookie = "";
      return r.statusCode;
    }

  }

  static Future<String> createGym(String text, Set<String> sectors, User admin) async {
    String uuid = getUUID("gym");

    Response r = await _post(
      Uri.http("10.0.2.2:5000", "/add_gym"),
      body: json.encode({
        "uuid": uuid,
        "name": text,
        "sectors": json.encode(sectors.toList()),
        "tags": "[]",
        "admin": admin.uuid
      }),
      json: true
    );

    if(r.statusCode > 299)
      return Future.error(r.statusCode);
    else return uuid;
  }


  static Future<Response> _post(url, {Map<String, String> headers, body, Encoding encoding, bool json=false}) async {
    if(headers == null)
      headers = Map<String, String>();

    if(json)
      headers["content-type"] = 'application/json';

    headers["cookie"] = _cookie;

    return http.post(url, headers:headers, body:body, encoding: encoding);

  }

  static Future<Response> _get(url, {Map<String, String> headers}) async {
    if(headers == null)
      headers = Map<String, String>();

    headers["cookie"] = _cookie;

    return http.get(url, headers:headers);

  }

}