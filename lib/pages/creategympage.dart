import 'package:flutter/material.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/models/gym.dart';
import 'package:timer/webapi.dart';
import 'package:timer/pages/homepage.dart';

class CreateGymPage extends StatefulWidget {
  CreateGymPage({Key key, this.gym}) : super(key: key);

  final Gym gym;

  @override
  _CreateGymPageState createState() => _CreateGymPageState();
}



class _CreateGymPageState extends State<CreateGymPage> {

  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _addSector = TextEditingController();

  @override
  void initState() {
    super.initState();

   }


  @override
  Widget build(BuildContext context) {


    Set<String> sectors = Set<String>();
    if(widget.gym != null) {
      sectors = widget.gym.sectors;
      _nameCtrl.text = widget.gym.name;
    }
    _addSector.text = "";

    List<Widget> sectorWidgets = List<Widget>();
    for(String s in sectors) {
      sectorWidgets.add(
        ListTile(
          title: Text(s),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                sectors.remove(s);
              });
            },
          ),
        )
      );
    }

    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(""),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(widget.gym == null ? Icons.add : Icons.check),
              onPressed: () {
                if(widget.gym != null) {
                  for(String s in sectors) {
                    widget.gym.addSector(s);
                  }
                  widget.gym.name = _nameCtrl.text;
                  Gym.refreshGyms().then((l) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => RuteListPage())
                    );
                  });
                }
                else {
                  WebAPI.createGym(_nameCtrl.text, sectors, StateManager().loggedInUser).then((i) {
                    Gym.refreshGyms().then((l) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => RuteListPage())
                      );
                    });
                  });
                }
              },
            )
          ],
        ),
        body: Column(
          children: <Widget> [
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                labelText: "Gym name"
              )
            ),
            Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(child:
                  TextField(
                    controller: _addSector,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        labelText: "Add sector"
                    )
                  )
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState((){
                      sectors.add(_addSector.text);
                    });
                  }
                )
              ],
            ),
            Expanded(child:ListView(children: sectorWidgets))
          ]
        ),
      )
    );
  }
}