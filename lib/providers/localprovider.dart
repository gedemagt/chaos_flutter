import 'package:localstorage/localstorage.dart';
import 'package:timer/providers/provider.dart';
import 'package:timer/models/rute.dart';

class LocalRuteProvider extends Provider<Rute> {

  Map<String, Rute> _cache = Map<String, Rute>();
  LocalStorage _storage;

  @override
  Future<void> init() async {
    _storage = new LocalStorage('local_rutes');
  }

  @override
  Future<void> add(Rute t) {
    _addOrSave(t);
    fireListeners();
  }

  @override
  Future<void> refresh() {
    _cache.clear();
    var k = _storage.getItem("rutes");
    if(k is List) {
      k.forEach((k) {
        Rute r = Rute.fromJson(k, this);
        _cache[r.uuid] = r;
      });
    }
    fireListeners();
  }

  void _addOrSave(Rute t) {
    var k = _storage.getItem("rutes");
    if(!(k is List)) k = List();
    bool isin = false;
    for(int i=0; i<k.length; i++) {
      if(k[i]["uuid"] == t.uuid) {
        k[i] = t.toJsonMap();
        isin = true;
      }
    }
    if(!isin) {
      k.add(t.toJsonMap());
      _cache[t.uuid] = t;
    }

      _storage.setItem("rutes", k);

  }

  @override
  Future<void> delete(Rute t) {
    var k = _storage.getItem("rutes");
    if(k is List) {
      for(int i=0; i<k.length; i++) {
        if(k[i]["uuid"] == t.uuid) {
          k.removeAt(i);
          break;
        }
      }
    }

    _storage.setItem("rutes", k);
    _cache.remove(t.uuid);
    fireListeners();

  }

  @override
  Future<void> save(Rute t) {
    _addOrSave(t);
    fireListeners();
  }

  @override
  List<Rute> provide() {
    return _cache.values.toList();
  }

}