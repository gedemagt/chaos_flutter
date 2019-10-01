import 'package:flutter/material.dart';
import 'package:timer/models/point.dart';
import 'dart:ui';
import 'dart:math';
import 'package:timer/util.dart';
import 'package:timer/pages/widgets/gradepicker.dart';
import 'package:timer/models/rute.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/painting.dart';

class ImageViewer extends StatefulWidget {

  final Rute _rute;
  final Function startEdit, endEdit;

  ImageViewer(this._rute, {this.startEdit, this.endEdit});

  @override
  State<StatefulWidget> createState() {
    return _ImageViewerState();
  }

}


class PointWidget extends StatelessWidget {

  final Size _size;
  final RutePoint _point;
  final Function(RutePoint p) _onSelected;
  final bool _canEdit;
  final Offset _offset;
  final Function onPanUpdate;
  final Function onPanStart;
  final Function onPanEnd;
  final bool selected;

  PointWidget(this._point, this._onSelected, this._size, this._canEdit, this._offset, this.selected, {this.onPanUpdate,this.onPanStart, this.onPanEnd});


  Color typeToColor(Type type) {
    if(type == Type.START) return Colors.green;
    else if(type == Type.END) return Colors.red;
    return Colors.white;
  }


  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (_point.x - _point.size/2.0)*_size.width  + _offset.dx,
      top:  (_point.y - _point.size/2.0)*_size.height + _offset.dy,
      child: GestureDetector(
        onPanEnd: (s) {
          if(_canEdit && onPanEnd != null)
            onPanEnd(s);
        },
          onPanStart: (s) {
            if(_canEdit && onPanStart != null)
              onPanStart(s);
          },
            onPanUpdate: !_canEdit ? null : (details) {
                _point.x += details.delta.dx / _size.width;
                _point.y += details.delta.dy / _size.height;

                if(onPanUpdate != null) onPanUpdate(details);

            },
            onTapDown: !_canEdit ? null :  (details) {
              if(_onSelected != null) _onSelected(_point);
            },
            child: Container(
                height: _point.size*_size.shortestSide,
                width: _point.size*_size.shortestSide,
                child: CustomPaint(
                  painter: CirclePainter(typeToColor(_point.type), selected),
                )
            )
        )
    );
  }

}


class _ImageViewerState extends State<ImageViewer> {


  GlobalKey _keyRed = GlobalKey();
  Size size = Size(0,0);
  Offset pos = Offset(0,0);
  Color col = Colors.blue;

  Rute _rute;

  int _radioValue1 = -1;

  Image _image;
  List<RutePoint> points = List<RutePoint>();
  RutePoint selected;

  bool _canEdit = false;
  bool _editing = false;

  PhotoViewController crtl;

  Offset pvOffset = Offset(0,0);
  double pvScale = 1.0;
  double height;
  double width;



  @override
  void initState() {
    super.initState();

    _canEdit = canEdit(widget._rute.author);

    _rute = widget._rute;
    _image = null;

    widget._rute.getImage().then((image) => setState(() {
      _image = image;
      _image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener((info,__) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          var sH =_keyRed.currentContext.size.height / height;
          var sW =_keyRed.currentContext.size.width / width;
          crtl.scale = min(sH, sW);
        });
        pv = PhotoView(imageProvider:_image.image, controller: crtl, backgroundDecoration: BoxDecoration(color: Colors.white));
        setState(() {
          height = info.image.height.toDouble();
          width = info.image.width.toDouble();
        });
      }));
    }));

    points = _rute.points;
    crtl = PhotoViewController();

    crtl.addIgnorableListener(updateOffsetAndScale);

    print("[ImageViewer] Showing rute $_rute");

  }

  void updateOffsetAndScale() {
    pvOffset = crtl.position;
    pvScale = crtl.scale;
    if(width != null && height != null && pvOffset != null && pvScale != null && _keyRed.currentContext != null) {
      setState(() {
        size = Size(width * pvScale, height * pvScale);
        Size nSize = _keyRed.currentContext.size;

        double extraX = nSize.width - size.width;
        double extraY = nSize.height - size.height;

        pvOffset += Offset(extraX / 2.0, extraY / 2.0);
      });
    }
  }


  void _openAddEntryDialog() async {
    final john = await showDialog<int> (
      context: context,
      builder: (context) => GradePickerDialog(grade: _rute.grade)
    );
    setState(() {
      _rute.grade = john;
    });
  }

  void _handleRatioButton(dynamic val) {
    setState(() {
      _radioValue1 = val;
      selected.type = intToType(val);
    });
  }

  void _handleSelect(RutePoint p) {
    setState(() {
      selected = p;
      _radioValue1 = typeToInt(p.type);
    });

  }

  Widget pv = CircularProgressIndicator();


  @override
  Widget build(BuildContext context) {

    List<Widget> barActions = List<Widget>();
    if (_canEdit) {
      barActions.add(IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            setState(() {
              _rute.delete();
              Navigator.pop(context);
            });
          }));
      barActions.add(IconButton(
        icon: Icon(_editing ? Icons.visibility : Icons.edit),
        onPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            var sH = _keyRed.currentContext.size.height / height;
            var sW = _keyRed.currentContext.size.width / width;
            crtl.scale = min(sH, sW);
            crtl.initial = PhotoViewControllerValue(
                position: crtl.initial.position,
                scale: min(sH, sW),
                rotation: crtl.initial.rotation,
                rotationFocusPoint: crtl.initial.rotationFocusPoint);
            updateOffsetAndScale();
          });
          setState(() => _editing = !_editing);
          if(_editing) {
            if (widget.startEdit != null) widget.startEdit();
          }
          else {
            if(widget.endEdit != null)widget.endEdit();
          }
        }));
  }

    AppBar appbar = AppBar(
      title: Text(numberToGrade(_rute.grade) + " " +_rute.name),
      actions: barActions,
    );


    List<Widget> stuff = List<Widget>();
    Widget imageContainer = Container(child:pv, key:_keyRed);

    if(_editing) {
      imageContainer = GestureDetector(

        onTapDown: (details) {
          setState(() {
            RenderBox rb = _keyRed.currentContext.findRenderObject();
            Offset xy = rb.globalToLocal(details.globalPosition);
            xy -= pvOffset;
            RutePoint p = RutePoint(xy.dx/size.width, xy.dy / size.height);
            _rute.addPoint(p);
            selected = p;
          });
        },
        child: imageContainer
      );
    }

    stuff.add(imageContainer);
    points.forEach(
      (p) => stuff.add(
          PointWidget(p, _handleSelect, size, _editing, pvOffset, p == selected, onPanUpdate: (d) => setState((){}),)
      )
    );

    List<Widget> columnChildren = List<Widget>();
    columnChildren.add(
      //Expanded(
          Expanded(
            child: Stack(
              children: stuff,
            )
        )
      //)
    );

    if(_editing) {
      Widget editRow = Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              color: Colors.blue,
              onPressed: selected == null ? null : () {
                setState(() {
                  _rute.removePoint(selected);
                  selected = null;
                  points = _rute.points;
                });
              },
            ),
            MyVerticalDivider(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Radio(
                  value: 1,
                  groupValue: _radioValue1,
                  onChanged: selected == null ? null : _handleRatioButton,
                  activeColor: Colors.blue,
                ),
                Radio(
                  value: 2,
                  groupValue: _radioValue1,
                  onChanged: selected == null ? null : _handleRatioButton,
                  activeColor: Colors.blue,
                ),
                Radio(
                  value: 3,
                  groupValue: _radioValue1,
                  onChanged: selected == null ? null : _handleRatioButton,
                  activeColor: Colors.blue,
                )
              ],
            ),
            MyVerticalDivider(),
            IconButton(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              icon: Text(numberToGrade(_rute.grade)),
              onPressed: () {
                setState(() {
                  _openAddEntryDialog();
                });
              },
            ),
            MyVerticalDivider(),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_up),
              color: Colors.blue,
              onPressed: selected == null ? null : () {
                setState(() {
                  //selected
                  selected.incrementSize();
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_down),
              color: Colors.blue,
              onPressed: selected == null ? null : () {
                setState(() {
                  selected.decrementSize();
                });
              },
            )
          ],
        )
      );


      columnChildren.add(editRow);
    }

    return Scaffold(
        appBar: appbar,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: columnChildren,
        )
    );
  }

}


class CirclePainter extends CustomPainter{

  Color lineColor = Colors.green;
  double width = 3;
  bool fill;

  CirclePainter(this.lineColor, this.fill);


  @override
  void paint(Canvas canvas, Size size) {

    Paint line = new Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    canvas.drawCircle(
        Offset(size.width/2, size.width/2),
        size.width/2,
        line
    );
    if(fill) {
      line.color = Colors.yellow;

      canvas.drawCircle( Offset(size.width/2, size.width/2),
          size.width/1.8,
          line);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}