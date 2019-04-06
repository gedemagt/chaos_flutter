import 'package:flutter/material.dart';

class NothingToShowWidget extends StatelessWidget {

  final String text;

  NothingToShowWidget({this.text});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IntrinsicHeight(
      child: SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(text == null ? "" : text,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black26,
                fontSize: 30
            ),
          ),
          Image.asset("assets/images.jpeg")
        ],
      ),
    ));
  }

}