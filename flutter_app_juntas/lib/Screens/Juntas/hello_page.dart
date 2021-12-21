import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_authentication_tutorial/models/model_app.dart';
class HelloPage extends StatefulWidget {
  final App app;
  HelloPage({this.app});
  @override
  State<StatefulWidget> createState() => new _HelloPage();
}

class _HelloPage extends State<HelloPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Flutter'),
        ),
        body: Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}