enum Type {
  START, NORMAL, END
}

class RutePoint {


  double _size = 0.1;
  double _x = 0;
  double _y = 0;
  Type _type = Type.NORMAL;
  Function() notifyParent;


  get x => _x;
  set x(val){
    _x = val;
    if(notifyParent != null) notifyParent();
  }

  get y => _y;
  set y(val) => _y = val;

  get size => _size;
  get type => _type;
  set type(val) => _type = val;

  void incrementSize() {
    if(_size<0.475) {
      _size += 0.025;
      if(notifyParent != null) notifyParent();
    }
  }

  void decrementSize() {
    if(_size > 0.025) {
      _size -= 0.025;
      if(notifyParent != null) notifyParent();
    }
  }


  Map toJson() {
    Map r = Map();
    r["x"] = _x;
    r["y"] = _y;
    r["size"] = _size;
    r["type"] = _type.toString();
    return r;
  }

  RutePoint(this._x, this._y);

  RutePoint.ofSize(this._x, this._y, this._size);

  @override
  String toString() {
    return "Point<[$x,$y] - $size]";
  }

  @override
  bool operator ==(other) {
    return _x == other.x && y == other.y;
  }

  @override
  int get hashCode => (((17 * 31) + _x.hashCode) * 31 + _y.hashCode)*31;

}