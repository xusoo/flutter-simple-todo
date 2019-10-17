import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:simple_todo/utils/date_utils.dart';

import 'task.dart';

class TasksModel with ChangeNotifier {
  final List<Task> _tasks = [
    new Task(description: 'Buy groceries'),
    new Task(description: 'Project deadline', dueDate: DateTime.now().add(Duration(days: 30))),
    new Task(description: 'Pick up laundry', dueDate: DateTime.now().add(Duration(days: 1))),
  ];

  List<Task> get tasks => UnmodifiableListView(_tasks);

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTaskDescription(Task task, String description) {
    task.description = description;
    notifyListeners();
  }

  void markTaskAsDone(Task task, bool done) {
    task.done = done;
    notifyListeners();
  }

  void updateTaskDueDate(Task task, DateTime date) {
    task.dueDate = DateUtils.truncate(date);
    notifyListeners();
  }

  void deleteTask(Task task) {
    _tasks.remove(task);
    notifyListeners();
  }
}
