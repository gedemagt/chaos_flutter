

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/pages/widgets/sectorindicator.dart';
import 'package:timer/util.dart';

class RuteListItemWidget extends StatelessWidget {

  final Function onTap;
  final Rute _rute;

  RuteListItemWidget(this._rute, this.onTap);

  @override
  Widget build(BuildContext context) {

    Widget title;
    if(_rute.hasCompleted(StateManager().loggedInUser)) {
      title = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            _rute.name,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Icon(Icons.check_circle, color: Colors.greenAccent)
        ],
      );
    }
    else {
      title = Text(
        _rute.name,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: ListTile(
        title: title,
        subtitle: Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("Sector: " + _rute.sector,
                      textAlign: TextAlign.left)
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(_rute.author.name),
                  Text(DateFormat("dd-MM-yyyy").format(_rute.date))
                ],
              )
            ],
          )
        ),
        trailing: Container(
          width: 50,
          child: Center(
            child: Text(
              numberToGrade(_rute.grade),
              style: TextStyle(color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 30)
            )
          )
        ),
        leading: SectorIndicator(_rute.sector),
        onTap: () {
          onTap(_rute);
        },
      )
    );
  }
}