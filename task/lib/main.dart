// --no-sound-null-safety
import 'package:flutter/material.dart';
import 'package:task/start.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noted',
      debugShowCheckedModeBanner: false,
      home: Start(),
    );
  }
}
