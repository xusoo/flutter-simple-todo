import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  DateSelector({Key key, this.initialDate, this.onDateChanged}) : super(key: key);

  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;

  void _selectToday() {
    onDateChanged(DateTime.now());
  }

  void _selectTomorrow() {
    onDateChanged(DateTime.now().add(Duration(days: 1)));
  }

  void _selectNextWeek() {
    onDateChanged(DateTime.now().add(Duration(days: 7)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Wrap(
          spacing: 10,
          children: <Widget>[
            ActionChip(label: Text('Today'), onPressed: _selectToday),
            ActionChip(label: Text('Tomorrow'), onPressed: _selectTomorrow),
            ActionChip(label: Text('Next week'), onPressed: _selectNextWeek),
          ],
        ),
        MonthPicker(
          selectedDate: initialDate ?? DateTime.now(),
          firstDate: DateTime(2010),
          lastDate: DateTime(2050),
          onChanged: onDateChanged,
        ),
      ],
    );
  }
}
