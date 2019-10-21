import 'package:flutter/material.dart';
import 'package:simple_todo/utils/date_utils.dart';

class DateSelector extends StatelessWidget {
  DateSelector({Key key, this.initialDate, this.onDateChanged}) : super(key: key);

  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;

  void _selectNone() {
    onDateChanged(null);
  }

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
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: Text('Choose a due date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200)),
        ),
        Wrap(
          spacing: 10,
          children: <Widget>[
            _buildChip(context, 'None', _selectNone, initialDate == null),
            _buildChip(context, 'Today', _selectToday, DateUtils.isToday(initialDate)),
            _buildChip(context, 'Tomorrow', _selectTomorrow, DateUtils.isTomorrow(initialDate)),
            _buildChip(context, 'Next week', _selectNextWeek, DateUtils.isNextWeek(initialDate)),
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

  ActionChip _buildChip(BuildContext context, String text, VoidCallback onPressed, bool selected) {
    return ActionChip(
      label: Text(text),
      onPressed: onPressed,
      backgroundColor: selected ? Theme.of(context).hintColor.withOpacity(0.4) : null,
    );
  }
}
