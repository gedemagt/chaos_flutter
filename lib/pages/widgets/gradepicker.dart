import 'package:flutter/material.dart';
import 'package:timer/util.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart';

// move the dialog into it's own stateful widget.
// It's completely independent from your page
// this is good practice
  class GradePickerDialog extends StatefulWidget {
  /// initial selection for the slider
  final int grade;

  GradePickerDialog({Key key, this.grade}) : super(key: key);

  @override
  _GradePickerDialogState createState() => _GradePickerDialogState();
}

class _GradePickerDialogState extends State<GradePickerDialog> {
  /// current selection of the slider
  int _grade;

  @override
  void initState() {
    super.initState();
    _grade = widget.grade;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
        Text('Choose grade'),
        CircleAvatar(
          child: Text(numberToGrade(_grade)),
        ),
      ],),
      content: Column (
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _grade.toDouble(),
            min: 0,
            max: 20,
            divisions: 20,
            onChanged: (value) {
              setState(() {
                _grade = value.round();
              });
            },
          ),

        ]
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            // Use the second argument of Navigator.pop(...) to pass
            // back a result to the page that opened the dialog
            Navigator.pop(context, _grade);
          },
          child: Text('OK'),
        )
      ],
    );
  }
}