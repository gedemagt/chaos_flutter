import 'package:flutter/material.dart';
import 'package:timer/models/comment.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/pages/imageviewer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:intl/intl.dart';


class RuteViewer extends StatelessWidget {

  final Rute _r;

  RuteViewer(this._r);

//  final List<Comment> comments = [
//    Comment("I used to think I was pretty good at Chess. Whenever I asked my friends to play after school I would always beat them. Then I actually joined in a Chess club, and never won a game again.",    "BallClamps",
//    DateTime.now()
//  ),
//  Comment("I used to think I was pretty good at Chess. Whenever I asked my friends to play after school I would always beat them. Then I actually joined in a Chess club, and never won a game again.",
//    "BallClamps",
//    DateTime.now()
//  ),
//    Comment("I used to think I was pretty good at Chess. Whenever I asked my friends to play after school I would always beat them. Then I actually joined in a Chess club, and never won a game again.",
//        "BallClamps",
//        DateTime.now()
//    ),
//  ];



  @override
  Widget build(BuildContext context) {
    return ImageViewer(_r);
//    List<Widget> children = List();
//
//
//    children.add(
//      Material(
//        child: Container(
//          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
//          child:TextField(
//            controller: TextEditingController(),
//            decoration: InputDecoration(
//              hintText: "Maah, totally sandbagged!",
//              labelText: "Add comment"
//            ),
//          )
//        )
//      )
//    );
//
//
//    children.addAll(
//      comments.map((s) {
//      return CommentWidget(s.comment, s.author, s.dateTime);
//    }));
//
//
//    return SlidingUpPanel(
//      minHeight: 50,
//      backdropEnabled: true,
//      collapsed: Row(
//        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//        children: <Widget>[
//          Container(
//            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
//            child:Row(
//              children: <Widget>[
//                Icon(Icons.comment),
//                Text(
//                  "  ${comments.length}",
//                  style: TextStyle(
//                    color: Colors.black38,
//                    fontWeight: FontWeight.bold,
//                    fontSize: 30,
//                    inherit: false
//                  )
//                )
//              ],
//            )
//          ),
//          Container(
//            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
//            child:
//            Row(
//              children: <Widget>[
//                Icon(Icons.star),
//                Icon(Icons.star),
//                Icon(Icons.star)
//              ],
//            )
//          )
//        ],
//      ),
//      body:ImageViewer(_r),
//      panel: IntrinsicWidth(
//        child: Container(
//          padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
//          child:Column(
//            children: children
//          )
//        )
//      )
//    );
    }
}

class CommentWidget extends StatelessWidget {

  final String _comment;
  final String _author;
  final DateTime _dateTime;
  final DateFormat _format = DateFormat.yMMMd();

  CommentWidget(this._comment, this._author, this._dateTime);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),

      child: Column(
        children: <Widget>[
          Container(
            //color: Theme.of(context).backgroundColor,
            child:Row(
              children: <Widget>[
                Text(_author, style: Theme.of(context).textTheme.caption),
                Text("   ", style: Theme.of(context).textTheme.caption),
                Text(_format.format(_dateTime), style:Theme.of(context).textTheme.caption)
              ],
            )
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(_comment, style: Theme.of(context).textTheme.body1, softWrap: true)
          )
        ],
      )
    );
  }

}