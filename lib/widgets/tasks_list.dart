import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/models/task.dart';
import 'package:simple_todo/models/tasks_model.dart';
import 'package:simple_todo/widgets/task_list_tile.dart';

class TasksList extends StatefulWidget {
  @override
  TasksListState createState() => TasksListState();
}

class TasksListState extends State<TasksList> {
  bool _autofocusNewTaskField = false;
  FocusNode _newTaskFieldFocus;
  TextEditingController _newTaskFieldController;
  int _expandedRow;

  @override
  void initState() {
    super.initState();
    _newTaskFieldController = new TextEditingController();
    _newTaskFieldFocus = FocusNode();
    _newTaskFieldFocus.addListener(() {
      setState(() {});

      if (_newTaskFieldFocus.hasFocus) {
        _collapseRowWidget();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _newTaskFieldController.dispose();
    _newTaskFieldFocus.dispose();
  }

  void _onNewTaskFieldSubmitted(TasksModel model, String value) {
    setState(() {
      _autofocusNewTaskField = value.isNotEmpty;
    });

    if (value.isNotEmpty) {
      model.addTask(new Task(description: value));
    }
  }

  void _onRowFocus(int row) {
    setState(() {
      _expandedRow = _expandedRow == row ? row : null;
    });
  }

  void _collapseRowWidget() {
    setState(() => _expandedRow = null);
  }

  void _onExpansionChanged(int row, bool state) {
    FocusScope.of(context).unfocus();
    setState(() => _expandedRow = state ? row : null);
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting(Localizations.localeOf(context).toLanguageTag());

    final model = Provider.of<TasksModel>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8.0),
        itemCount: model.tasks.length + 1,
        itemBuilder: (context, index) {
          if (index == model.tasks.length) {
            return buildNewTaskRow(model);
          }

          Task task = model.tasks[index];

          return TaskListTile(
            task: task,
            onExpansionChanged: (expanded) => _onExpansionChanged(index, expanded),
            widgetExpanded: _expandedRow == index,
            onFocus: () => _onRowFocus(index),
          );
        },
      ),
    );
  }

  ListTile buildNewTaskRow(TasksModel model) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0),
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: GestureDetector(
          child: Icon(Icons.add, color: Theme.of(context).accentColor),
          onTap: _newTaskFieldFocus.requestFocus,
        ),
      ),
      title: TextFormField(
        focusNode: _newTaskFieldFocus,
        autofocus: _autofocusNewTaskField,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: _newTaskFieldFocus.hasFocus ? null : 'Add new task',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Theme.of(context).accentColor),
        ),
        onFieldSubmitted: (value) => _onNewTaskFieldSubmitted(model, value),
      ),
    );
  }
}
