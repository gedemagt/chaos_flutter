import 'package:timer/StateManager.dart';
import 'package:timer/providers/imageprovider.dart';
import 'package:timer/providers/provider.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/webapi.dart';

class WebRuteProvider extends Provider<Rute> {

  Map<String, Rute> _cache = Map<String, Rute>();

  UUIDImageProvider provider = UUIDImageProvider();

  @override
  Future<void> init() async {
    WebAPI.init();
  }

  @override
  Future<void> add(Rute t) async {
    WebAPI.createRute(t).then((v) {
      WebAPI.uploadImage(t.imageUUID);
      _cache[t.uuid] = t;
      fireListeners();
    });
  }

  @override
  Future<void> refresh() async{
    _cache.clear();
    (await WebAPI.downloadRutes(StateManager().gym)).forEach((r) {
      _cache[r.uuid] = r;
    });
    fireListeners();
  }


  @override
  Future<void> delete(Rute t) async {
    WebAPI.deleteRute(t).then((v) {
      _cache.remove(t.uuid);
      fireListeners();
    });


  }

  @override
  Future<void> save(Rute t, {Function callback}) async {
    WebAPI.saveRute(t).then((v) {
      if(callback != null) callback();
    });
  }

  @override
  List<Rute> provide() {
    return _cache.values.toList();
  }

}