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

  const TaskListTile({Key key, @required this.task}) : super(key: key);

  @override
  _TaskListTileState createState() => _TaskListTileState();
}

class _TaskListTileState extends State<TaskListTile> with SingleTickerProviderStateMixin {
  GlobalKey _globalKey = GlobalKey();
  FocusNode _focusNode = FocusNode();
  TextEditingController _textController;

  AnimationController _animationController;
  Animation<double> _moveAnimation, _expandAnimation, _elevationAnimation, _opacityAnimation, _maskOpacityAnimation;
  OverlayEntry _editingPopup;

  bool _editing = false;
  bool _popupOpen = false;

  @override
  void initState() {
    super.initState();
    _textController = new TextEditingController(text: widget.task.description);
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 350), reverseDuration: Duration(milliseconds: 500));

    _maskOpacityAnimation = Tween(begin: 0.0, end: 0.2).animate(_animationController);
    _moveAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.5, 1)));
    _expandAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.75, 1)));
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Interval(0, 0.5)));
    _elevationAnimation = Tween(begin: 0.0, end: 5.0).animate(CurvedAnimation(parent: _animationController, curve: Interval(0, 0.75)));

    _editingPopup = _buildEditPopup();

    _focusNode.addListener(() {
      setState(() {
        if (!_focusNode.hasFocus) {
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
    _animationController.dispose();
  }

  void _updateTask() {
    final model = Provider.of<TasksModel>(context, listen: false);
    var fieldValue = _textController.text.trim();
    if (fieldValue.isEmpty) {
      model.deleteTask(widget.task);
    } else if (widget.task.description != fieldValue) {
      model.updateTaskDescription(widget.task, fieldValue);
    }
    _collapseWidget();
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
    if (_popupOpen) {
      _collapseWidget();
    } else {
      _expandWidget();
    }
  }

  void _collapseWidget() {
    if (!_popupOpen) {
      return;
    }
    _animationController.reverse().then((value) {
      Future.delayed(Duration.zero, () {
        setState(() {
          _popupOpen = false;
        });
        _editingPopup.remove();
      });
    });
  }

  void _expandWidget() {
    if (_popupOpen) {
      return;
    }

    FocusScope.of(context).unfocus();

    Overlay.of(context).insert(_editingPopup);

    _animationController.forward().then((value) {
      Future.delayed(Duration.zero, () {
        setState(() {
          _popupOpen = true;
        });
      });
    });
  }

  void _startEditing() {
    setState(() {
      _editing = true;
      _focusNode.requestFocus();
    });
  }

  OverlayEntry _buildEditPopup() {
    return OverlayEntry(builder: (BuildContext context) {
      RenderBox renderBox = _globalKey.currentContext.findRenderObject();
      var size = renderBox.size;
      var offset = renderBox.localToGlobal(Offset.zero);

      final model = Provider.of<TasksModel>(context);

      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            children: [
              /* Background mask */
              FadeTransition(
                opacity: _maskOpacityAnimation,
                child: Column(
                  children: <Widget>[
                    Expanded(child: Container(color: Theme.of(context).textTheme.title.color)),
                  ],
                ),
              ),
              /* Popup */
              AnimatedPositioned(
                left: offset.dx + (_moveAnimation.value * 10),
                top: offset.dy - ((offset.dy - 150) * _moveAnimation.value),
                width: size.width - (_moveAnimation.value * 20),
                duration: Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: Material(
                    type: MaterialType.card,
                    elevation: _elevationAnimation.value,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: Column(
                      children: <Widget>[
                        /* Replica of the selected row */
                        ListTile(
                          contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0),
                          leading: _buildCheckbox(model),
                          title: widget.task.done ? _buildStrikethroughTask() : _buildTextField(),
                          trailing: GestureDetector(
                            child: Icon(Icons.close),
                            onTap: _collapseWidget,
                          ),
                        ),
                        /* Calendar widget */
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
                  ),
                ),
              )
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<TasksModel>(context);

    return Container(
      key: _globalKey,
      child: Column(
        children: [
          FadeTransition(
            opacity: ReverseAnimation(_opacityAnimation),
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0),
              leading: _buildCheckbox(model),
              title: widget.task.done ? _buildStrikethroughTask() : _buildTextField(),
              trailing: _buildTrailingWidget(),
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
        ),
        GestureDetector(
          onTap: _startEditing,
          behavior: HitTestBehavior.opaque,
          child: TextFormField(
            enabled: false,
            controller: _textController,
            decoration: InputDecoration(border: InputBorder.none),
          ),
        )
      ],
    );
  }

  Widget _buildStrikethroughTask() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.task.description,
            style: TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailingWidget() {
    if (widget.task.done) {
      return null;
    }

    if (widget.task.dueDate != null) {
      return GestureDetector(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: FadeTransition(
            opacity: ReverseAnimation(_opacityAnimation),
            child: _buildDueDate(),
          ),
        ),
        onTap: _toggleWidget,
      );
    }

    if (_focusNode.hasFocus) {
      return GestureDetector(
        child: Icon(
          Icons.calendar_today,
          size: 20,
        ),
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
