import 'package:flutter/material.dart';
import 'package:timer/util.dart';

class SectorIndicator extends StatelessWidget {

  final String sector;
  final double size;

  SectorIndicator(this.sector, {this.size = 50.0});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
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