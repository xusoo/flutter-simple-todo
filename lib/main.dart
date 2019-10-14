import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/model/tasks_model.dart';
import 'package:simple_todo/tasks_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var primaryColor = Colors.deepOrange;

    return ChangeNotifierProvider<TasksModel>(
      builder: (context) => TasksModel(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: primaryColor,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: TasksList(),
    );
  }
}
