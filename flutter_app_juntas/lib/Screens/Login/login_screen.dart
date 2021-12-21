import 'package:flutter/material.dart';
import 'package:firebase_authentication_tutorial/Screens/Login/components/body.dart';
import 'package:firebase_authentication_tutorial/models/model_app.dart';
import 'package:firebase_authentication_tutorial/constants.dart';
class LoginScreen extends StatefulWidget {
  final App app;
  LoginScreen({this.app});
  @override
  State<StatefulWidget> createState() => new _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar( backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      backgroundColor: kPrimaryBackgroundColor,
      body: Body(),
    );
  }
}
