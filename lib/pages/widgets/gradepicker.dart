import 'package:flutter/material.dart';
import 'package:timer/util.dart';

// move the dialog into it's own stateful widget.
// It's completely independent from your page
// this is good practice
class GradePickerDialog extends StatefulWidget {
  /// initial selection for the slider
  int grade;

  GradePickerDialog({Key key, this.grade}) : super(key: key);

  @override
  _GradePickerDialogState createState() => _GradePickerDialogState();
}

class _GradePickerDialogState extends State<GradePickerDialog> {
  /// current selection of the slider
//  double _grade;

//  @override
//  void initState() {
//    super.initState();
//    _grade = widget.grade.toDouble();
//  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Choose grade'),
      content: Column (
        children: [
          Slider(
            value: widget.grade.toDouble(),
            min: 0,
            max: 20,
            divisions: 20,
            onChanged: (value) {
              setState(() {
                widget.grade = value.round();
              });
            },
          ),
          Text(
            numberToGrade(widget.grade)
          )
        ]
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            // Use the second argument of Navigator.pop(...) to pass
            // back a result to the page that opened the dialog
            Navigator.pop(context, widget.grade);
          },
          child: Text('OK'),
        )
      ],
    );
  }
}