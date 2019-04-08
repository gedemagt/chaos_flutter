import 'package:flutter/material.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/pages/imageviewer.dart';
import 'package:intl/intl.dart';


class RuteViewer extends StatefulWidget {

  final List<Rute> _r;
  final int startIndex;

  RuteViewer(this._r, this.startIndex);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RuteViewerState();
  }

}

class _RuteViewerState extends State<RuteViewer> {




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

  List<Rute> rutes;
  ImageViewer iv;

  PageController controller = PageController();
  var currentPageValue = 0.0;
  ScrollPhysics scrollPhysics = ScrollPhysics();

  @override
  void initState() {
    rutes = widget._r;
    currentPageValue = widget.startIndex.toDouble();
    controller.addListener(() {
      setState(() {
        currentPageValue = controller.page;
      });
    });
    super.initState();
  }

  ImageViewer getImageViewer(int pos) {
    return ImageViewer(rutes[pos],
      startEdit: () => setState(() {
        scrollPhysics = NeverScrollableScrollPhysics();
        print("Mjello");
      }),
      endEdit: () => setState(() {
        scrollPhysics = null;
        print("aaand off");
      })
    );
  }


  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      physics: scrollPhysics,
      controller: controller,
      itemCount: rutes.length,
      itemBuilder: (context, pos) {
        return getImageViewer(pos);
      }
    );


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

class CustomScrollPhysics extends ScrollPhysics {
  CustomScrollPhysics(this.disabled, {ScrollPhysics parent}) : super(parent: parent);

  final bool disabled;

  @override
  CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomScrollPhysics(disabled, parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if(disabled) return 0.0;
    else return super.applyBoundaryConditions(position, value);
  }
}