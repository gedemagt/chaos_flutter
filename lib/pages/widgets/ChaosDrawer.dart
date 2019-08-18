import 'package:flutter/material.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/pages/creategympage.dart';
import 'package:timer/pages/gymspage.dart';
import 'package:timer/pages/loginpage.dart';
import 'package:timer/providers/database.dart';
import 'package:timer/util.dart';

class ChaosDrawer extends StatelessWidget {

  final bool isRutesSelected;
  final bool isGymSelected;
  final Database _db;

  ChaosDrawer(this._db, {this.isRutesSelected = true, this.isGymSelected = false});


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
              color: Theme.of(context).primaryColor,
              child: ListTile(
                  title: Text(_db.getLoggedInUser().name,
                      style: Theme.of(context).primaryTextTheme.title),
                  leading: Icon(Icons.account_circle, size: 50,),
                  subtitle: Text("<email>",
                      style: Theme.of(context).primaryTextTheme.caption)
              )
          ),
          ListTile(
            title: Text("Switch gym"),
            subtitle: Text(StateManager().gym.name),
            leading: Icon(Icons.home),
            trailing: canEdit(StateManager().gym.admin) ?
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateGymPage(_db, gym: StateManager().gym))
                );
              },
            ) : null,
            onTap: isGymSelected ? null : () {
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
              _db.logout().whenComplete(() {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
              });
            },
          ),
        ],
      ),
    );
  }



}