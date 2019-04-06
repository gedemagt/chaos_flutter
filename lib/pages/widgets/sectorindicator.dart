import 'package:flutter/material.dart';
import 'package:timer/util.dart';

class SectorIndicator extends StatelessWidget {

  final String sector;

  SectorIndicator(this.sector);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            color: getColor(sector),
            shape: BoxShape.circle
        ),
        child: Center(
            child: Text(getText(sector),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            )
        )
    );
  }

}