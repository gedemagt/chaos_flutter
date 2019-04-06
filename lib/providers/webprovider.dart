import 'package:timer/StateManager.dart';
import 'package:timer/providers/imageprovider.dart';
import 'package:timer/providers/provider.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/util.dart';
import 'package:timer/webapi.dart';

class WebRuteProvider extends Provider<Rute> {

  Map<String, Rute> _cache = Map<String, Rute>();

  UUIDImageProvider provider = UUIDImageProvider();

  @override
  Future<void> init() async {
    WebAPI.init();
  }

  @override
  Future<Rute> add(String name, String sector, String imageUUID) async {
    int r = await WebAPI.uploadImage(imageUUID);
    if(r == 413) {
      print("Problems!");
      throw Exception("File too big");
    }
    Rute rute = Rute.create(name, sector, imageUUID, this);
    await WebAPI.createRute(getUUID("rute"), name, imageUUID, StateManager().loggedInUser, sector, StateManager().gym, 0);

    _cache[rute.uuid] = rute;
    fireListeners();
    return rute;
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