import 'package:flutter/widgets.dart';

class Task {
  int id;
  bool done = false;
  String description;
  DateTime dueDate;

  DateTime _creationDate;

  DateTime get creationDate => _creationDate;

  Task({this.id, @required this.description, this.dueDate}) {
    _creationDate = DateTime.now();
  }
}
