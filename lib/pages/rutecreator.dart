import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/pages/imageviewer.dart';
import 'package:timer/providers/provider.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class RuteCreator extends StatefulWidget {
  /// initial selection for the slider

  ///
  final Provider<Rute> _prov;

  RuteCreator(this._prov);

  @override
  _RuteCreatorState createState() => _RuteCreatorState();
}

class _RuteCreatorState extends State<RuteCreator> {

  String _sector = "Uncategorized";
  File _image;
  ImageSource _source;
  final TextEditingController _nameCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    _source = ImageSource.camera;
    setState(() {
      _image = image;
    });
  }

  Future getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    _source = ImageSource.gallery;
    setState(() {
      _image = image;
    });
  }

  Future<String> handleImage() async {

    final d = await getApplicationDocumentsDirectory();
    print(d.path);

    String imageUUID = getUUID("image");
    String newPath = join(d.path, "$imageUUID.jpg");
    if(_source == ImageSource.camera) _image.copy(newPath);
    else if (_source == ImageSource.gallery) _image.copy(newPath);
    return imageUUID;
  }

  @override
  Widget build(BuildContext context) {

    List<String> items = ["Uncategorized"];
    if(StateManager().gym != null) items.addAll(StateManager().gym.sectors);

    return Scaffold(
      appBar: AppBar(
        title: Text("New rute"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              if (_formKey.currentState.validate()){
                try {
                  String imageUUID = await handleImage();
                  Rute r = Rute.create(_nameCtrl.text, _sector, imageUUID, widget._prov);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ImageViewer(r)));
                } catch(e) {
                  print(e.toString());
                }
              }
            },
          )
        ],
      ),
      body:
        Form(
          key: _formKey,
          child: Column(
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
                            Text("Sector:",
                              style: TextStyle(fontWeight: FontWeight.bold)
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
              Container(
                child: _image == null ? null : Image.file(_image),
              )
            ],
          )
        )
      );
  }
}