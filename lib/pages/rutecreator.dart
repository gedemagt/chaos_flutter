import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/providers/database.dart';
import 'package:timer/util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class RuteCreator extends StatefulWidget {
  /// initial selection for the slider

  ///
  final Database _prov;
  final String _initialSector;

  RuteCreator(this._prov, this._initialSector);

  @override
  _RuteCreatorState createState() => _RuteCreatorState();
}

class _RuteCreatorState extends State<RuteCreator> {

  static const double MAX_SIZE = 1400;

  String _sector = "Uncategorized";
  File _image;
  //ImageSource _source;
  final TextEditingController _nameCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    if(widget._initialSector != null && StateManager().gym.sectors.contains(widget._initialSector)) {
      _sector = widget._initialSector;
    }

  }

  Future getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: MAX_SIZE, maxWidth: MAX_SIZE);
    setState(() {
      _image = image;
    });
  }

  Future getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: MAX_SIZE, maxWidth: MAX_SIZE);
    setState(() {
      _image = image;
    });
  }

  Future<String> handleImage() async {

    final d = await getApplicationDocumentsDirectory();

    String imageUUID = getUUID("image");
    String newPath = join(d.path, "$imageUUID.jpg");
    try {
      File newFile = await _image.copy(newPath);
      await _image.delete();
      _image = newFile;
    }
    catch (o) {
      print("[RuteCreator] Could not rename file from ${_image.path} -> $newPath");
    }

    return imageUUID;
  }

  @override
  Widget build(BuildContext context) {

    List<String> items = ["Uncategorized"];
    if(StateManager().gym != null) items.addAll(StateManager().gym.sectors);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("New rute"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              if (_formKey.currentState.validate()){
                String imageUUID = await handleImage();
                BuildContext c;
                showDialog(barrierDismissible: false, context: context,
                  builder: (context) {
                    c = context;
                    return Center(
                      child: Container(
                        child:Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            Text("Uploading rute...", style: TextStyle(inherit: false),)
                          ],
                        )
                      )
                    );
                  }
                );
                widget._prov.createRute(_nameCtrl.text, _sector, imageUUID, _image).then((r) {
                  Navigator.of(c).pop();
                  Navigator.pop(context, r);
                  //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RuteViewer([r], 0)));
                },
                onError: (e) {
                  Navigator.of(c).pop();
                  String errorText = "An error occured!";
                  if(e is SocketException) errorText = "No internet connection";
                  else errorText = e.toString();
                  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(errorText)));
                });
              }
            },
          )
        ],
      ),
      body:
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                child: Column(children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Rute name"
                    ),
                    controller: _nameCtrl,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a name';
                      }
                      else if(_image == null)
                        return "Please choose an image";
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.camera),
                              onPressed: getImageCamera,
                            ),
                              IconButton(
                                icon: Icon(Icons.image),
                                onPressed: getImageGallery,
                              )
                            ]
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Sec:  ",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                            ),
                            DropdownButton<String>(
                              value: _sector,
                              items: items.map((String value) {
                                return  DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (s) {setState(() => _sector = s);},
                            )
                          ]
                        ),
                      ],
                    )
                  ]
                )
              ),
              Expanded( child:
                _image == null ? Container() : Image.file(_image),
              )
            ],
          )
        )
      );
  }
}