import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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

class _TaskListTileState extends State<TaskListTile> with SingleTickerProviderStateMixin {
  FocusNode _focusNode = FocusNode();
  TextEditingController _textController;
  AnimationController _animationController;
  Animation<double> _rotationAnimation;
  Animation<double> _expandAnimation;

  bool _editing = false;
  bool _expandRequested = false;

  @override
  void initState() {
    super.initState();
    _textController = new TextEditingController(text: widget.task.description);
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _rotationAnimation = _animationController.drive(Tween(begin: 0.0, end: 0.5));
    _expandAnimation = _animationController.drive(CurveTween(curve: Curves.easeIn));

    _focusNode.addListener(() {
      setState(() {
        if (_focusNode.hasFocus) {
          widget.onFocus();
        } else {
          _editing = false;
          _updateTask();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _focusNode.dispose();
  }

  void _updateTask() {
    final model = Provider.of<TasksModel>(context, listen: false);
    if (_textController.text.isEmpty) {
      model.deleteTask(widget.task);
    } else if (widget.task.description != _textController.text) {
      model.updateTaskDescription(widget.task, _textController.text);
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
    if (widget.widgetExpanded) {
      _collapseWidget();
    } else {
      _expandWidget();
    }
  }

  void _collapseWidget() {
    _animationController.reverse().then((value) {
      Future.delayed(Duration.zero, () {
        widget.onExpansionChanged(false);
      });
    });
  }

  void _expandWidget() {
    setState(() => _expandRequested = true);
    _animationController.forward().then((value) {
      Future.delayed(Duration.zero, () {
        widget.onExpansionChanged(true);
        setState(() => _expandRequested = false);
      });
    });
  }

  void _startEditing() {
    setState(() {
      _editing = true;
      _focusNode.requestFocus();
    });
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
            title: widget.task.done ? _buildStrikethroughTask() : _buildTextField(),
            trailing: _buildTrailingWidget(),
          ),
          if (_expandRequested || widget.widgetExpanded)
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: DateSelector(
                initialDate: widget.task.dueDate ?? DateTime.now().add(Duration(days: 1)),
                onDateChanged: (date) {
                  _updateTaskDate(model, date);
                },
              ),
            ),
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

  Widget _buildTextField() {
    return IndexedStack(
      index: _editing ? 0 : 1,
      children: <Widget>[
        TextField(
          focusNode: _focusNode,
          controller: _textController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: 'Remove task?', border: InputBorder.none),
          minLines: 1,
          maxLines: _focusNode.hasFocus ? 4 : 1,
        ),
        GestureDetector(
          onTap: _startEditing,
          behavior: HitTestBehavior.opaque,
          child: TextFormField(enabled: false, controller: _textController),
        )
      ],
    );
  }

  Row _buildStrikethroughTask() {
    return Row(
      children: [
        Text(widget.task.description, style: TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough)),
      ],
    );
  }

  Widget _buildTrailingWidget() {
    if (widget.task.done) {
      return null;
    }

    if (widget.widgetExpanded || _expandRequested) {
      return GestureDetector(
        child: RotationTransition(
          child: const Icon(Icons.expand_more),
          turns: _rotationAnimation,
        ),
        onTap: _toggleWidget,
      );
    }

    if (widget.task.dueDate != null) {
      return GestureDetector(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: _buildDueDate(),
        ),
        onTap: _toggleWidget,
      );
    }

    if (_focusNode.hasFocus) {
      return GestureDetector(
        child: Icon(Icons.add_alarm),
        onTap: _toggleWidget,
      );
    }

    return null;
  }

  Text _buildDueDate() {
    var color, weight, text = DateUtils.friendlyFormatDate(widget.task.dueDate);

    if (DateUtils.isToday(widget.task.dueDate)) {
      color = Theme.of(context).textTheme.title.color;
      weight = FontWeight.bold;
    } else if (DateUtils.daysFromNow(widget.task.dueDate) < 1) {
      color = Colors.red;
      weight = FontWeight.bold;
      text = "Due";
    } else {
      color = Colors.grey;
      weight = FontWeight.normal;
    }

    return Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: weight,
        fontSize: 14,
      ),
    );
  }
}
