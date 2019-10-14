import 'package:flutter/material.dart';
import 'package:simple_todo/utils/date_utils.dart';

class DateSelector extends StatefulWidget {
  DateSelector({Key key, this.title, this.initialDate}) : super(key: key);

  final String title;
  final DateTime initialDate;

  @override
  DateSelectorState createState() => DateSelectorState();
}

class DateSelectorState extends State<DateSelector> {
  var _dueDateVisible;
  DateTime _selectedDate;

  DateTime get selectedDate => _dueDateVisible && _selectedDate != null ? DateUtils.truncate(_selectedDate) : null;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.initialDate;
    _dueDateVisible = _selectedDate != null;
  }

  bool _isAnotherDateSelected() => _selectedDate != null && !DateUtils.isTomorrow(_selectedDate) && !DateUtils.isNextWeek(_selectedDate);

  void _selectTomorrow() {
    _selectDate(DateTime.now().add(Duration(days: 1)));
  }

  void _selectNextWeek() {
    _selectDate(DateTime.now().add(Duration(days: 7)));
  }

  Future<void> _showDatePicker() async {
    var pickerValue = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2050),
    );
    if (pickerValue != null) {
      _selectDate(pickerValue);
    }
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(widget.title),
            Switch(
              value: _dueDateVisible,
              onChanged: (bool value) {
                setState(() {
                  _dueDateVisible = value;
                });
              },
            ),
          ],
        ),
        Visibility(
          visible: _dueDateVisible,
          maintainAnimation: true,
          maintainState: true,
          child: Wrap(
            spacing: 10,
            children: <Widget>[
              AnimatedOpacity(
                opacity: _dueDateVisible ? 1 : 0,
                duration: Duration(milliseconds: 100),
                child: RaisedButton(
                  child: Text('Tomorrow'),
                  color: DateUtils.isTomorrow(_selectedDate) ? Theme.of(context).primaryColor : Colors.white,
                  onPressed: _selectTomorrow,
                ),
              ),
              AnimatedOpacity(
                opacity: _dueDateVisible ? 1 : 0,
                duration: Duration(milliseconds: 300),
                child: RaisedButton(
                  child: Text('Next week'),
                  color: DateUtils.isNextWeek(_selectedDate) ? Theme.of(context).primaryColor : Colors.white,
                  onPressed: _selectNextWeek,
                ),
              ),
              AnimatedOpacity(
                opacity: _dueDateVisible ? 1 : 0,
                duration: Duration(milliseconds: 500),
                child: RaisedButton(
                  child: Text(_isAnotherDateSelected() ? DateUtils.formatDate(_selectedDate, 'yMd') : 'Pick another'),
                  color: _isAnotherDateSelected() ? Theme.of(context).primaryColor : Colors.white,
                  onPressed: _showDatePicker,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
