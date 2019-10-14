import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'task.dart';

class TasksModel with ChangeNotifier {
  final List<Task> _tasks = [
    new Task(id: 1, description: 'Buy groceries'),
    new Task(id: 2, description: 'Project deadline', dueDate: DateTime.now().add(Duration(days: 30))),
    new Task(id: 3, description: 'Pick up laundry', dueDate: DateTime.now().add(Duration(days: 1))),
  ];

  get tasks => UnmodifiableListView(_tasks);

  void addTask(Task task) {
    task.id = _tasks.length + 1;
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task task) {
    assert(task.id != null);
    notifyListeners();
  }
}
