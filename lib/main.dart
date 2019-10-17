import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/models/tasks_model.dart';
import 'package:simple_todo/widgets/tasks_list.dart';

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
          buttonTheme: ButtonThemeData(
            buttonColor: primaryColor,
            textTheme: ButtonTextTheme.primary,
          ),
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
