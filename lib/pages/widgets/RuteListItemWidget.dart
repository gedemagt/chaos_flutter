

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/pages/ruteviewer.dart';
import 'package:timer/pages/widgets/sectorindicator.dart';
import 'package:timer/util.dart';

class RuteListItemWidget extends StatelessWidget {

  final Rute _rute;

  RuteListItemWidget(this._rute);

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RuteViewer(_rute))
          );
        },
      )
    );
  }
}