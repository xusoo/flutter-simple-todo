import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/models/task.dart';
import 'package:simple_todo/models/tasks_model.dart';
import 'package:simple_todo/utils/date_utils.dart';

class TaskListTile extends StatefulWidget {
  final Task task;
  final VoidCallback onTrailingWidgetTap;
  final VoidCallback onFocus;
  final bool widgetExpanded;

  const TaskListTile({Key key, @required this.task, @required this.onTrailingWidgetTap, this.widgetExpanded = false, this.onFocus}) : super(key: key);

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
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<TasksModel>(context);

    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0),
          leading: _buildCheckbox(model),
          title: _buildTaskTitle(model),
          trailing: _buildTrailingWidget(),
        ),
      ],
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
        Flexible(
          child: TextFormField(
            focusNode: _focusNode,
            controller: _controller,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Task description',
              border: InputBorder.none,
            ),
            minLines: 1,
            maxLines: _focusNode.hasFocus ? 4 : 1,
            style: TextStyle(
              color: widget.task.done ? Colors.grey : Theme.of(context).textTheme.body1.color,
              decoration: widget.task.done ? TextDecoration.lineThrough : TextDecoration.none,
            ),
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
        onTap: widget.onTrailingWidgetTap,
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
        onTap: widget.onTrailingWidgetTap,
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
