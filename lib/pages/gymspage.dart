import 'package:flutter/material.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/models/gym.dart';
import 'package:timer/pages/homepage.dart';
import 'package:timer/webapi.dart';
import 'package:timer/pages/creategympage.dart';

class GymsPage extends StatefulWidget {
  GymsPage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _GymsPageState createState() => _GymsPageState();
}



class _GymsPageState extends State<GymsPage> {

  List<Gym> _gyms = new List<Gym>();
  List<Gym> _searchGyms = List<Gym>();
  TextEditingController _searchCtrl = TextEditingController();

  GlobalKey _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WebAPI.downloadGyms().then((gyms) {
      setState(() {
        _gyms = gyms;
        _gyms.forEach((g) => _searchGyms.add(g));
      });

    }).catchError((er) {
      print("Error");
    });
   }


  @override
  Widget build(BuildContext context) {

    List<Widget> ruteWidgets = List<Widget>();
    ruteWidgets.add(
      ListTile(
        trailing: Icon(Icons.search),
      title: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: "My favorite gym...",
        ),
      ))
    );
    _searchCtrl.addListener(() {
      _searchGyms.clear();
      setState(() {
        _gyms.forEach((g) {
          if(g.name.toLowerCase().startsWith(_searchCtrl.text.toLowerCase())) {
            _searchGyms.add(g);
          }
        });
      });
    });

    _searchGyms.forEach((gym) {
      ruteWidgets.add(Card(
        elevation: 0.1,
        child: ListTile (
          title: Text(
            gym.name,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          trailing: Container(
            child:Text("${gym.nrRutes}",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 30)
            )
          ),
          onTap: () {
            StateManager().gym = gym;
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RuteListPage())
            );
          },
        )));
    });

    return Material(child:Scaffold(
      key:_scaffoldKey,
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(""), //StateManager().gym.name
          centerTitle: true,
          actions: <Widget>[
            //IconButton(icon: Icon(Icons.refresh), onPressed: doRefresh)
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateGymPage())
          );
        }),
        body: _gyms.length == 0 ? Center(
          child: Text("No gyms", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),),

        ) :
        ListView(
            children: ruteWidgets

        ),
    )
    );
  }
}