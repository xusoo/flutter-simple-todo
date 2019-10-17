import 'package:flutter/widgets.dart';

class Task {
  String description;
  bool done = false;
  DateTime dueDate;

  DateTime _creationDate;

  DateTime get creationDate => _creationDate;

  Task({@required this.description, this.dueDate}) {
    _creationDate = DateTime.now();
  }
}
