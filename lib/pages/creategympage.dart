import 'package:flutter/material.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/models/gym.dart';
import 'package:timer/pages/widgets/sectorindicator.dart';
import 'package:timer/providers/webdatabase.dart';
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
  Set<String> sectors = Set<String>();

  @override
  Widget build(BuildContext context) {

    if(widget.gym != null) {
      sectors = widget.gym.sectors;
      _nameCtrl.text = widget.gym.name;
    }
    _addSector.text = "";
    List<Widget> sectorWidgets = List<Widget>();
    List<String> sorted = sectors.toList();
    sorted.sort((o1,o2) => o1.compareTo(o2));
    for(String s in sorted) {
      sectorWidgets.add(
        ListTile(
          title: Text(s),
          leading: SectorIndicator(s),
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
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => RuteListPage())
                  );
                }
                else {
                  WebDatabase().createGym(_nameCtrl.text, StateManager().loggedInUser, sectors: sectors.toList()).then((newGym) {
                    StateManager().gym = newGym;
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => RuteListPage())
                    );
                  });
                }
              },
            )
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget> [
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title:TextField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                            labelText: "Gym name"
                        )
                      )
                    ),
                    ListTile(
                      title: TextField(
                        controller: _addSector,
                        decoration: InputDecoration(
                            labelText: "Add sector"
                        )
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState((){
                            sectors.add(_addSector.text);
                          });
                        }
                      ),
                    ),
                  ],
                )
              ),
              Expanded(
                child: ListView(
                  children: sectorWidgets
                )
              )
            ]
          ),
        )
      )
    );
  }
}