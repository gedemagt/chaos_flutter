import 'dart:async';

abstract class Provider<T> {


  Future<void> init() async {}

  Future<void> refresh() async {}

  List<T> provide();

  Future<void> delete(T t) async {}

  Future<T> add(String name, String sector, String imageUUID);

  Future<void> save(T t) async {}

  void fireListeners() {
   stream.sink.add(provide());
  }

  final StreamController<List<T>> stream = StreamController();

  void close() {
    stream.close();
  }
}