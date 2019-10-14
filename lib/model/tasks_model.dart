import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'task.dart';

class TasksModel with ChangeNotifier {
  final List<Task> _tasks = [
    new Task(description: 'Buy groceries'),
    new Task(description: 'Project deadline', dueDate: DateTime.now().add(Duration(days: 30))),
    new Task(description: 'Pick up laundry', dueDate: DateTime.now().add(Duration(days: 1))),
  ];

  get tasks => UnmodifiableListView(_tasks);

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task task) {
    notifyListeners();
  }

  void deleteTask(Task task) {
    _tasks.remove(task);
    notifyListeners();
  }
}
