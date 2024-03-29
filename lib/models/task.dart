import 'package:flutter/widgets.dart';

class Task {
  String description;
  bool done;
  DateTime dueDate;

  DateTime _creationDate;

  DateTime get creationDate => _creationDate;

  Task({@required this.description, this.dueDate, this.done = false}) {
    _creationDate = DateTime.now();
  }
}
