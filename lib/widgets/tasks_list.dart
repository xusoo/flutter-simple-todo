import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/models/task.dart';
import 'package:simple_todo/models/tasks_model.dart';
import 'package:simple_todo/utils/theme_utils.dart';
import 'package:simple_todo/widgets/task_list_tile.dart';

class TasksList extends StatefulWidget {
  @override
  TasksListState createState() => TasksListState();
}

class TasksListState extends State<TasksList> {
  int _expandedRow;
  bool _autofocusNewTaskField = false;
  FocusNode _newTaskFieldFocus = FocusNode();
  TextEditingController _newTaskFieldController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
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

  void _deleteTask(TasksModel model, Task task) {
    model.deleteTask(task);
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting(Localizations.localeOf(context).toLanguageTag());

    final model = Provider.of<TasksModel>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              Container(
                decoration: _listContainerDecoration(),
                child: ListView.separated(
                  shrinkWrap: true,
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: model.tasks.length + 1,
                  itemBuilder: (context, index) => _buildItem(index, model),
                  separatorBuilder: (BuildContext context, int index) => _buildItemSeparator(),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(int index, TasksModel model) {
    if (index == model.tasks.length) {
      return _buildNewTaskRow(model);
    }

    Task task = model.tasks[index];

    return Dismissible(
      key: ObjectKey(task),
      onDismissed: (direction) => _deleteTask(model, task),
      background: Container(color: Theme.of(context).canvasColor),
      child: TaskListTile(
        task: task,
        onExpansionChanged: (expanded) => _onExpansionChanged(index, expanded),
        widgetExpanded: _expandedRow == index,
        onFocus: () => _onRowFocus(index),
      ),
    );
  }

  BoxDecoration _listContainerDecoration() {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          blurRadius: 5,
          color: isDarkMode() ? Colors.grey.shade900 : Colors.grey,
          offset: Offset(0, 2),
          spreadRadius: -2,
        )
      ],
      color: isDarkMode() ? Colors.grey.shade800 : Colors.white,
    );
  }

  DecoratedBox _buildItemSeparator() {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDarkMode() ? Colors.grey.shade700 : Colors.grey.shade200, width: 1)),
      ),
      child: SizedBox(height: 1),
    );
  }

  bool isDarkMode() => ThemeUtils.isDarkMode(context);

  ListTile _buildNewTaskRow(TasksModel model) {
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
