import 'package:flutter/material.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/pages/imageviewer.dart';
import 'package:intl/intl.dart';
import 'package:timer/webapi.dart';

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

  PageController controller;
  ScrollPhysics scrollPhysics = ScrollPhysics();
  bool showBottom = true;

  @override
  void initState() {
    rutes = widget._r;
    controller = PageController(initialPage: widget.startIndex);
    controller.addListener(() {
      StateManager().lastRute = rutes[controller.page.floor()];
    });
    super.initState();
  }

  ImageViewer getImageViewer(int pos) {
    return ImageViewer(rutes[pos],
      startEdit: () => setState(() {
        scrollPhysics = NeverScrollableScrollPhysics();
        showBottom = false;
      }),
      endEdit: () => setState(() {
        scrollPhysics = null;
        showBottom = true;
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

        Widget completeWidget;
        Set<Complete> completes = rutes[pos].completes;
        Complete c = completes.firstWhere((complete) => StateManager().loggedInUser == complete.u, orElse: () => null);

        if(c != null) {
          completeWidget = Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 10),
            child:Column(
              children: <Widget>[
                Text("${c.retries == 1 ? 'Flashed' : 'Completed'} on", style: TextStyle(color:Colors.blue, inherit: false)),
                Text(DateFormat("dd-MM-yyyy").format(c.date), style: TextStyle(color:Colors.blue, inherit: false))
              ],
            )
          );
        }
        else {
          completeWidget = FlatButton(
            child: Text("Complete"),
            onPressed: (){
              TextEditingController _ctrl = TextEditingController(text:"1");
              showDialog(
                context: context,
                child: AlertDialog(
                  content: TextField(
                    controller: _ctrl,
                    keyboardType: TextInputType.numberWithOptions(),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          rutes[pos].complete(StateManager().loggedInUser, int.parse(_ctrl.text));
                        });
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    )
                  ],
                )
              );
            },
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
          );
        }

        print(rutes[pos].completes);
        List<Widget> widgets = [
          Expanded(child:getImageViewer(pos))
        ];
        if(showBottom) widgets.add(
          Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              color: Colors.white,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[

              completeWidget
            ]
          ))
        );

        return Column(
          children: widgets
        );


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
