import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/models/tasks_model.dart';
import 'package:simple_todo/widgets/tasks_list.dart';

void main() => runApp(MyApp());

const materialColor = Colors.deepOrange;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TasksModel>(
      builder: (context) => TasksModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: materialColor,
          disabledColor: Colors.grey.shade100,
          appBarTheme: AppBarTheme(
            textTheme: TextTheme(
              title: TextStyle(color: Colors.black38),
            ),
          ),
          buttonTheme: ButtonThemeData(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            textTheme: ButtonTextTheme.primary,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: materialColor,
          primaryColor: materialColor,
          accentColor: materialColor,
          toggleableActiveColor: materialColor,
          appBarTheme: AppBarTheme(
            textTheme: TextTheme(
              title: TextStyle(color: Colors.black38),
            ),
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
    initializeDateFormatting(Localizations.localeOf(context).toLanguageTag());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 1, color: Colors.black38)),
          ),
          child: AppBar(
            elevation: 0,
            centerTitle: false,
            title: Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Text('Tasks', style: TextStyle(fontSize: 32)),
            ),
          ),
        ),
      ),
      body: TasksList(),
    );
  }
}
