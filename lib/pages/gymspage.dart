import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/models/gym.dart';
import 'package:timer/pages/homepage.dart';
import 'package:timer/pages/widgets/nothingtoshow.dart';
import 'package:timer/providers/database.dart';
import 'package:timer/providers/webdatabase.dart';
import 'package:timer/pages/creategympage.dart';

class GymsPage extends StatefulWidget {
  GymsPage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _GymsPageState createState() => _GymsPageState();
}



class _GymsPageState extends State<GymsPage> {

  List<Gym> _gyms;
  List<Gym> _searchGyms;
  TextEditingController _searchCtrl = TextEditingController();

  Database prov = WebDatabase();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  StreamSubscription ss;

  void setSearchGyms() {
    setState(() {
      _searchGyms = _gyms.where((g) {
        return g.name.toLowerCase().startsWith(_searchCtrl.text.toLowerCase());
        }).toList();
    });
  }

  @override
  void initState() {
    ss = prov.gymStream.stream.listen((data) {
      setState(() {
        _gyms = data;
        setSearchGyms();
      });
    }, onError: (o, stacktrace) {
      if (o is SocketException) {
        setState(() {
          if(_gyms == null) {
            _gyms = _searchGyms = List<Gym>();
          }
        });
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text("Internet connection error...")));
      }
      else {
        throw o;
      }
    });

    prov.refreshGyms();

    _searchCtrl.addListener(setSearchGyms);
  }

  @override
  void dispose() {
    super.dispose();
    if(ss != null) ss.cancel();
  }

  @override
  Widget build(BuildContext context) {

    Widget header =
      ListTile(
        trailing: Icon(Icons.search),
      title: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: "My favorite gym...",
        ),
      ));

    Widget body;
    if(_searchGyms != null && _searchGyms.length ==0 ) {
      body =  RefreshIndicator(
          onRefresh: prov.refreshGyms,
          child: ListView(
            children: <Widget>[
              NothingToShowWidget(text: "Nothing to see here...")
            ],
          )
      );
    }
    else if(_searchGyms != null && _searchGyms.length > 0 ) {
      body = RefreshIndicator(
          onRefresh: prov.refreshGyms,
          child: ListView.builder(
              itemCount: _searchGyms.length,
              itemBuilder: (context, idx) {
                Gym g = _searchGyms[idx];
                return Card(
                    elevation: 0.1,
                    child: ListTile (
                      title: Text(
                        g.name,
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      trailing: Container(
                          child:Text("${g.nrRutes}",
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 30)
                          )
                      ),
                      onTap: () {
                        StateManager().gym = g;
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RuteListPage())
                        );
                      },
                    )
                );
              })
      );
    }
    else {
      body = SizedBox.expand(child: Center(child: CircularProgressIndicator()));
    }


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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateGymPage())
            );
          },
          child: Icon(Icons.add),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            header,
            Expanded(child:body)
          ]
        ),
      )
    );
  }
}