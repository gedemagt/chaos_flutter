import 'package:timer/util.dart';

enum Role {
  USER, ADMIN
}

class User {
  Role _role;
  DateTime _created;
  DateTime _edit;
  String _name;
  String _uuid;

  static User unknown = User._internal("unknown-user", "Unknown User", DateTime(1), DateTime(1));

  get role => _role;
  get name => _name;
  get uuid => _uuid;


  User._internal(this._uuid, this._name, this._created, this._edit);


  Role getRole(String s) {
    if(s.contains("ADMIN")) return Role.ADMIN;
    return Role.USER;
  }

  User.fromJson(Map map) {
    _uuid = map["uuid"];
    _name = map["name"];
    _role = getRole(map["role"]);
    _created = parse(map["date"]);
    _edit = map["edit"] != null ? parse(map["edit"]) : _created;
  }

  Map toJson() {
    Map<String, Object> result = Map();
    result["uuid"] = _uuid;
    result["name"] = _name;
    result["role"] = _role == Role.ADMIN ? "ADMIN" : "USER";
    result["edit"] = format(_edit);
    result["date"] = format(_created);
    return result;
  }

  @override
  String toString() {
    return "User<$_name ($role) - $_uuid>";
  }


  bool operator == (o) => o is User && o.uuid == uuid;
  int get hashCode => uuid.hashCode;

}