import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/model/task.dart';
import 'package:simple_todo/model/tasks_model.dart';

class EditTaskPage extends StatefulWidget {
  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    _descriptionController = new TextEditingController();
  }

  void _saveTask() {
    if (_formKey.currentState.validate()) {
      String description = _descriptionController.text;

      var model = Provider.of<TasksModel>(context, listen: false);
      model.addTask(new Task(description: description));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add task'),
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
