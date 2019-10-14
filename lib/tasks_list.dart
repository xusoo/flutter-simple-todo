import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/edit_task_page.dart';
import 'package:simple_todo/model/tasks_model.dart';

import 'model/task.dart';
import 'utils/date_utils.dart';

class TasksList extends StatelessWidget {
  void _addNewTask(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditTaskPage()));
  }

  void _editTask(context, task) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditTaskPage(task: task)));
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting(Localizations.localeOf(context).toLanguageTag());

    var model = Provider.of<TasksModel>(context);

    return ListView.builder(
      itemExtent: 50,
      itemCount: model.tasks.length,
      itemBuilder: (context, i) {
        Task task = model.tasks[i];

        return ListTile(
          onTap: () => _editTask(context, task),
          contentPadding: EdgeInsets.only(left: 16.0, right: 16.0),
          leading: Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: task.done,
            onChanged: (value) {
              task.done = value;
              model.updateTask(task);
            },
          ),
          title: Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  task.description,
                  style: TextStyle(
                    color: task.done ? Colors.grey : Colors.black87,
                    decoration: task.done ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
          trailing: !task.done && task.dueDate != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    DateUtils.friendlyFormatDate(task.dueDate),
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : null,
        );
      },
    );
  }
}
