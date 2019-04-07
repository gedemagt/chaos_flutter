import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/pages/imageviewer.dart';
import 'package:timer/providers/database.dart';
import 'package:timer/util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class RuteCreator extends StatefulWidget {
  /// initial selection for the slider

  ///
  final Database _prov;

  RuteCreator(this._prov);

  @override
  _RuteCreatorState createState() => _RuteCreatorState();
}

class _RuteCreatorState extends State<RuteCreator> {

  static const double MAX_SIZE = 2048;

  String _sector = "Uncategorized";
  File _image;
  //ImageSource _source;
  final TextEditingController _nameCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
    _image.copy(newPath);

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
                widget._prov.createRute(_nameCtrl.text, _sector, imageUUID).then((r) {
                  print("Success!");
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ImageViewer(r)));
                },
                onError: (e) {
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