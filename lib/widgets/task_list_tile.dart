import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/models/task.dart';
import 'package:simple_todo/models/tasks_model.dart';
import 'package:simple_todo/utils/date_utils.dart';
import 'package:simple_todo/utils/theme_utils.dart';
import 'package:simple_todo/widgets/date_selector.dart';

class TaskListTile extends StatefulWidget {
  final Task task;
  final Function(bool) onExpansionChanged;
  final VoidCallback onFocus;
  final bool widgetExpanded;

  const TaskListTile({Key key, @required this.task, @required this.onExpansionChanged, this.widgetExpanded = false, this.onFocus}) : super(key: key);

  @override
  _TaskListTileState createState() => _TaskListTileState();
}

class _TaskListTileState extends State<TaskListTile> {
  FocusNode _focusNode;
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = new TextEditingController(text: widget.task.description);

    _focusNode.addListener(() {
      setState(() {
        if (_focusNode.hasFocus) {
          widget.onFocus();
        } else {
          _updateTask();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _focusNode.dispose();
  }

  void _updateTask() {
    final model = Provider.of<TasksModel>(context, listen: false);
    if (_controller.text.isEmpty) {
      model.deleteTask(widget.task);
    } else if (widget.task.description != _controller.text) {
      model.updateTaskDescription(widget.task, _controller.text);
    }
  }

  void _onCheckboxChange(TasksModel model, bool value) {
    model.markTaskAsDone(widget.task, value);
    _collapseWidget();
  }

  void _updateTaskDate(TasksModel model, DateTime date) {
    model.updateTaskDueDate(widget.task, date);
    _collapseWidget();
  }

  void _toggleWidget() {
    widget.onExpansionChanged(!widget.widgetExpanded);
  }

  void _collapseWidget() {
    widget.onExpansionChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<TasksModel>(context);

    return Container(
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0),
            leading: _buildCheckbox(model),
            title: _buildTaskTitle(model),
            trailing: _buildTrailingWidget(),
          ),
          if (widget.widgetExpanded)
            DateSelector(
              initialDate: widget.task.dueDate ?? DateTime.now().add(Duration(days: 1)),
              onDateChanged: (date) {
                _updateTaskDate(model, date);
              },
            )
        ],
      ),
      decoration: BoxDecoration(
        color: ThemeUtils.isDarkMode(context) ? Colors.grey.shade800 : Colors.white,
        border: Border(bottom: BorderSide(color: ThemeUtils.isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade200, width: 1)),
      ),
    );
  }

  Checkbox _buildCheckbox(TasksModel model) {
    return Checkbox(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      value: widget.task.done,
      onChanged: (value) => _onCheckboxChange(model, value),
    );
  }

  Widget _buildTaskTitle(TasksModel model) {
    return Row(
      children: <Widget>[
        if (widget.task.done)
          Flexible(
            child: Text(
              widget.task.description,
              style: TextStyle(
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        if (!widget.task.done)
          Flexible(
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: 'Task description', border: InputBorder.none),
              minLines: 1,
              maxLines: _focusNode.hasFocus ? 4 : 1,
            ),
          ),
      ],
    );
  }

  Widget _buildTrailingWidget() {
    if (widget.task.done) {
      return null;
    }

    if (_focusNode.hasFocus || widget.widgetExpanded) {
      return GestureDetector(
        child: Icon(
          widget.widgetExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
        ),
        onTap: _toggleWidget,
      );
    }

    if (widget.task.dueDate != null) {
      return GestureDetector(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            DateUtils.friendlyFormatDate(widget.task.dueDate),
            style: _dateStyle(),
          ),
        ),
        onTap: _toggleWidget,
      );
    }

    return null;
  }

  TextStyle _dateStyle() {
    var color, weight;

    if (DateUtils.isToday(widget.task.dueDate)) {
      color = Theme.of(context).textTheme.title.color;
      weight = FontWeight.bold;
    } else if (DateUtils.daysFromNow(widget.task.dueDate) < 1) {
      color = Colors.red;
      weight = FontWeight.bold;
    } else {
      color = Colors.grey;
      weight = FontWeight.normal;
    }

    return TextStyle(
      color: color,
      fontWeight: weight,
      fontSize: 14,
    );
  }
}
