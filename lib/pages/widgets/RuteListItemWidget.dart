

import 'package:flutter/material.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/pages/ruteviewer.dart';
import 'package:timer/util.dart';

class RuteListItemWidget extends StatelessWidget {

  final Rute _rute;

  RuteListItemWidget(this._rute);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.1,
      child: ListTile(
        title: Text(
          _rute.name,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
                  Text(_rute.date.toString().substring(0, 10))
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
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: getColor(_rute.sector),
            shape: BoxShape.circle
          ),
          child: Center(
            child: Text(getText(_rute.sector),
              style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
            )
          )
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RuteViewer(_rute))
          );
        },
      )
    );
  }
}