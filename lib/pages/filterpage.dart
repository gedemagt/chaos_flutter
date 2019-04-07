import 'package:flutter/material.dart';
import 'package:timer/StateManager.dart';
import 'package:timer/models/filter.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart';
import 'package:timer/util.dart';

class FilterPage extends StatefulWidget {
  FilterPage(this.current, {Key key}) : super(key: key);

  final Filter current;

  @override
  _FilterPageState createState() => _FilterPageState();
}


class _FilterPageState extends State<FilterPage> {

  @override
  void initState() {
    super.initState();
    _orderByValue = widget.current.orderBy;
    _ascending = widget.current.ascending;
    _min = widget.current.minGrade.toDouble();
    _max = widget.current.maxGrade.toDouble();
    _sector = widget.current.sector;
    if(_sector == null) _sector = "All";
  }

  int _orderByValue;
  bool _ascending;
  double _min, _max;
  String _sector;

  @override
  Widget build(BuildContext context) {
    Widget w = RangeSlider(
      min:0,
      max:20,
      showValueIndicator: true,
      divisions: 20,
      lowerValue: _min,
      upperValue: _max,
      onChanged: (v1, v2) {
        setState(() {
          _min = v1;
          _max = v2;
        });
      },
      valueIndicatorFormatter: (i, d) {
        return numberToGrade(d.floor());
      },
    );

    // Create dropdown for sectors

    List<DropdownMenuItem<String>> items = List();

    items.add(DropdownMenuItem<String>(
      value: "All",
      child: Text("All")
    ));
    items.add(DropdownMenuItem<String>(
        value: "Uncategorized",
        child: Text("Uncategorized")
    ));
    for(String s in StateManager().gym.sectors) {
      items.add(DropdownMenuItem<String>(
        value: s,
        child: Text(s)
      ));
    }
    DropdownButton<String> sectorChooser = DropdownButton(
      items: items,
      value: _sector,
      onChanged: (v) {
        setState(() {
          _sector = v;
        });
      },
    );

    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Filter by"),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, Filter(
                  orderBy: _orderByValue,
                  ascending: _ascending,
                  minGrade: _min.toInt(),
                  maxGrade: _max.toInt(),
                  sector: _sector == "All" ? null : _sector
                  )
                );
              },
            )
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget> [
            FilterItem(
              heading: "Order by",
              child: Column(children: <Widget>[
                ListTile(
                  title: Text("Date"),
                  trailing: Radio(
                    value: 0,
                    groupValue: _orderByValue,
                    onChanged: _setOrderBy,
                  ),
                ),
                ListTile(
                  title: Text("Name"),
                  trailing: Radio(
                    value: 1,
                    groupValue: _orderByValue,
                    onChanged: _setOrderBy,
                  ),
                ),
                ListTile(
                  title: Text("Username"),
                  trailing: Radio(
                    value: 2,
                    groupValue: _orderByValue,
                    onChanged: _setOrderBy,
                  ),
                ),
                ListTile(
                  title: Text("Grade"),
                  trailing: Radio(
                    value: 3,
                    groupValue: _orderByValue,
                    onChanged: _setOrderBy,
                  ),
                ),
                ListTile(
                  title: Text("Ascending"),
                  trailing: Switch(value: _ascending, onChanged: (v) => setState((){_ascending = v;})),
                )],),
            ),
            FilterItem(
              heading: "Grade interval",
              child: Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child:Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget> [
                        CircleAvatar(
                          child: Text(numberToGrade(_min.toInt())),
                        ),
                        Expanded(child:w),
                        CircleAvatar(
                          child: Text(numberToGrade(_max.toInt())),
                        ),
                      ]
                  )
              )
            ),
            FilterItem(
              heading: "Sector",
              child: Container(
                alignment: Alignment.center,
                child: sectorChooser,
              ),
            )
          ]
        ),
      )
    );
  }

  void _setOrderBy(int value) {
    setState(() {
      _orderByValue = value;
    });
  }
}

class FilterItem extends StatelessWidget {

  final Widget child;
  final String heading;

  FilterItem({this.child, this.heading});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: ListTile(
          title: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Center(
              child: Text(heading,
                style: TextStyle(
                  fontSize: 20
                ),
              )
            )
          ),
          subtitle: child,
        )
      )
    );
  }

}