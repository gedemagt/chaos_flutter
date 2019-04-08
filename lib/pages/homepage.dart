import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/models/filter.dart';
import 'package:timer/pages/filterpage.dart';
import 'package:timer/pages/ruteviewer.dart';
import 'package:timer/pages/widgets/ChaosDrawer.dart';
import 'package:timer/pages/widgets/RuteListItemWidget.dart';
import 'package:timer/pages/widgets/nothingtoshow.dart';
import 'package:timer/providers/database.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/pages/rutecreator.dart';
import 'package:timer/providers/webdatabase.dart';

class RuteListPage extends StatefulWidget {
  RuteListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RuteListPageState createState() => _RuteListPageState();
}



class _RuteListPageState extends State<RuteListPage> {

  List<Rute> _rutes;
  List<Rute> _filteredRutes;
  Database prov = WebDatabase();

  Filter _filter = Filter();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  StreamSubscription ss;

  @override
  void initState() {

    ss = prov.ruteStream.stream.listen((data) {
      setState(() {
        _rutes = data;
        _filteredRutes = _filter.filter(_rutes);
      });
    }, onError: (o, stacktrace) {
      if(o is SocketException) {
        if(_rutes == null) {
          setState(() {
            _rutes  = List<Rute>();
            _filteredRutes  = List<Rute>();
          });
        }
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Internet connection error...")));
      }
      else {
        throw o;
      }
    });

    prov.refreshRutes();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if(ss != null) ss.cancel();
  }

  @override
  Widget build(BuildContext context) {

    Widget body;
    if(_filteredRutes != null && _filteredRutes.length ==0 ) {
      body =  RefreshIndicator(
          onRefresh: prov.refreshRutes,
          child: ListView(
            children: <Widget>[
              NothingToShowWidget(text: "Nothing to see here...")
            ],
          )
      );
    }
    else if(_filteredRutes != null && _filteredRutes.length > 0 ) {
      body = RefreshIndicator(
        onRefresh: prov.refreshRutes,
        child: ListView.builder(
          itemCount: _filteredRutes.length,
          itemBuilder: (context, idx) {
            return RuteListItemWidget(_filteredRutes[idx], (r) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RuteViewer(_filteredRutes, _filteredRutes.indexOf(r)))
              );
            });
        })
      );
    }
    else {
      body = SizedBox.expand(child: Center(child: CircularProgressIndicator()));
    }
    return Material(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(StateManager().gym.name),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.sort),
              onPressed: () async {
                Filter result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FilterPage(_filter))
                );
                if (result != null) {
                  setState(() {
                    _filter = result;
                    _filteredRutes = _filter.filter(_rutes);
                  });
                }
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            Rute r = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return RuteCreator(prov, StateManager().lastRute != null ? StateManager().lastRute.sector : null);
                }
              )
            );
            setState(() {
              _filteredRutes = _filter.filter(_rutes);
            });
            List<Rute> toShow = _filteredRutes.contains(r) ? _filteredRutes : _rutes;
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RuteViewer(toShow, toShow.indexOf(r)))
            );

          }),
          body: body,
          drawer: ChaosDrawer(isRutesSelected: true),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _filter.author == StateManager().loggedInUser ? 1 : 0,
            onTap: (idx) {
              setState(() {
                _filter = Filter(author: idx==0? null : StateManager().loggedInUser, minGrade: _filter.minGrade, maxGrade: _filter.maxGrade, sector: _filter.sector, orderBy: _filter.orderBy, ascending: _filter.ascending);
                _filteredRutes = _filter.filter(_rutes);
              });
            },
            items: [
              BottomNavigationBarItem(
                title: Text("All"),
                icon: Icon(Icons.people)
              ),
              BottomNavigationBarItem(
                title: Text("My"),
                icon: Icon(Icons.person)
              )
            ],
          )
        )
    );
  }
}