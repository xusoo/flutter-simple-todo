import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/due_date_selector.dart';
import 'package:simple_todo/model/task.dart';
import 'package:simple_todo/model/tasks_model.dart';

class EditTaskPage extends StatefulWidget {
  EditTaskPage({Key key, this.task}) : super(key: key);

  final Task task;

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateSelectorKey = GlobalKey<DateSelectorState>();

  TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    _descriptionController = new TextEditingController(text: widget.task?.description);
  }

  void _deleteTask() {
    Provider.of<TasksModel>(context, listen: false).deleteTask(widget.task);
    Navigator.pop(context);
  }

  void _saveTask() {
    if (_formKey.currentState.validate()) {
      String description = _descriptionController.text;
      DateTime dueDate = _dateSelectorKey.currentState.selectedDate;

      var model = Provider.of<TasksModel>(context, listen: false);
      if (widget.task != null) {
        widget.task.description = description;
        widget.task.dueDate = dueDate;
        model.updateTask(widget.task);
      } else {
        model.addTask(new Task(description: description, dueDate: dueDate));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Edit task' : 'Add task'),
        actions: <Widget>[
          if (widget.task != null)
            IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Delete',
              onPressed: _deleteTask,
            )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            runSpacing: 10,
            children: [
              TextFormField(
                autofocus: true,
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                validator: (value) => value.isEmpty ? 'You need a title' : null,
              ),
              DateSelector(
                key: _dateSelectorKey,
                title: 'Choose a due date',
                initialDate: widget.task?.dueDate,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        tooltip: 'Save task',
        onPressed: _saveTask,
      ),
    );
  }
}
