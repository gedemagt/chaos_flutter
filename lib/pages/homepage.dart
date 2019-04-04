import 'package:flutter/material.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/models/filter.dart';
import 'package:timer/pages/filterpage.dart';
import 'package:timer/pages/gymspage.dart';
import 'package:timer/pages/loginpage.dart';
import 'package:timer/pages/ruteviewer.dart';
import 'package:timer/pages/widgets/RuteListItemWidget.dart';
import 'package:timer/providers/provider.dart';
import 'package:timer/providers/webprovider.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/pages/rutecreator.dart';
import 'package:timer/models/user.dart';
import 'package:timer/util.dart';
import 'package:timer/webapi.dart';
import 'package:timer/pages/creategympage.dart';

class RuteListPage extends StatefulWidget {
  RuteListPage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _RuteListPageState createState() => _RuteListPageState();
}



class _RuteListPageState extends State<RuteListPage> {

  List<Rute> _rutes = new List<Rute>();
  List<Rute> _filteredRutes = new List<Rute>();
  Provider<Rute> prov = WebRuteProvider();

  Filter _filter = Filter();

  bool _showError = false;

  Future<void> doRefresh() async {
    await prov.refresh();
    User.refreshUsers().then(
            (s) => prov.refresh()

    ).then(
            (s) {
              setState(() {
                print("Hello");
                _showError=false;
              });
            }
    ).catchError((s) {setState(() {
      print("No");
      _showError=true;
    });} );
  }

  @override
  void initState() {
    super.initState();
    prov.init();
    prov.stream.stream.listen((newRutes){
      setState(() {
        _rutes = newRutes;
        _filteredRutes = _filter.filter(_rutes);
      });
    });
    doRefresh();
  }


  @override
  Widget build(BuildContext context) {

    List<Widget> ruteWidgets = List<Widget>();

    _filteredRutes.forEach((rute) {
      ruteWidgets.add(RuteListItemWidget(rute));
    });

    Widget switchRutes;
    if(_filter.author == StateManager().loggedInUser) {
      switchRutes = ListTile(
        title: Text("All rutes"),
        leading: Icon(Icons.people),
        onTap: () {
          setState(() {
            _filter = Filter();
            _filteredRutes = _filter.filter(_rutes);
          });
          Navigator.of(context).pop();
        },
      );
    }
    else {
      switchRutes = ListTile(
        title: Text("My rutes"),
        leading: Icon(Icons.person_outline),
        onTap: () {
          setState(() {
            _filter = Filter(author: StateManager().loggedInUser);
            _filteredRutes = _filter.filter(_rutes);
          });
          Navigator.of(context).pop();
        },
      );
    }



    return Material(child:Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(StateManager().gym.name), //StateManager().gym.name
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () async {
              Filter result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FilterPage(_filter))
              );
              if(result != null) {
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
        onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RuteCreator(prov))
        );
      }),
      body:
      RefreshIndicator(
        onRefresh: doRefresh,
        child:  ListView(
          children: _rutes.length == 0 ? [Center(
            child: Text("No rutes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),),
          )] : ruteWidgets
        )
      ),
      bottomSheet: !_showError ? null : Container(
        color: Colors.black54,
        child: new Wrap(
          children: <Widget>[
            ListTile(
              title: Container(
                child: Text(
                  "Internet problems...",
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            Container(
              color: Theme.of(context).primaryColor,
                child: ListTile(
                  title: Text(StateManager().loggedInUser.name,
                  style: Theme.of(context).primaryTextTheme.title),
                  leading: Icon(Icons.person),
                  subtitle: Text("<email>",
                  style: Theme.of(context).primaryTextTheme.caption)
              )
            ),
            switchRutes,
            Divider(),
            ListTile(
              title: Text(StateManager().gym.name),
              leading: Icon(Icons.home),
              trailing: StateManager().loggedInUser == StateManager().gym.admin || StateManager().loggedInUser.role == Role.ADMIN ?
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateGymPage(gym: StateManager().gym))
                    );
                  },
                ) : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GymsPage())
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text("Logout"),
              leading: Icon(Icons.navigate_before),
              onTap: () {
                WebAPI.logout().then((s) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
                });
              },
            ),
          ],
        ),
      ),
    )
    );
  }
}