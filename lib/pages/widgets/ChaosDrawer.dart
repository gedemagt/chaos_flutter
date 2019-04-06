import 'package:flutter/material.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/pages/creategympage.dart';
import 'package:timer/pages/gymspage.dart';
import 'package:timer/pages/loginpage.dart';
import 'package:timer/util.dart';
import 'package:timer/webapi.dart';
import 'package:timer/pages/homepage.dart';

class ChaosDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
              color: Theme.of(context).primaryColor,
              child: ListTile(
                  title: Text(StateManager().loggedInUser.name,
                      style: Theme.of(context).primaryTextTheme.title),
                  leading: Icon(Icons.account_circle, size: 50,),
                  subtitle: Text("<email>",
                      style: Theme.of(context).primaryTextTheme.caption)
              )
          ),
          ListTile(
            title: Text("Rutes"),
            leading: Icon(Icons.speaker_group),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RuteListPage())
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text(StateManager().gym.name),
            leading: Icon(Icons.home),
            trailing: canEdit(StateManager().gym.admin) ?
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
    );
  }



}