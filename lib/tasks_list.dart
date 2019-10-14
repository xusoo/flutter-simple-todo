import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/model/tasks_model.dart';

import 'model/task.dart';

class TasksList extends StatelessWidget {
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
        );
      },
    );
  }
}
