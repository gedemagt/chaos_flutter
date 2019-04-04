import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timer/webapi.dart';
import 'package:path/path.dart';
class UUIDImageProvider {

  static Map<String, Image> _cache = Map<String, Image>();


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