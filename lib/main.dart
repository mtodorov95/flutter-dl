import 'package:flutter/material.dart';
import 'package:flutterdl/screens/home.dart';

//TODO: How to check process status


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter-dl',
      home: FlutterDl(),
    );
  }
}