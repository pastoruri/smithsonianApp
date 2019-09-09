import 'package:flutter/material.dart';
import 'question.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReporteAnimal',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: Question(title: '¿Has visto algún animal varado?'),
    );
  }
}


