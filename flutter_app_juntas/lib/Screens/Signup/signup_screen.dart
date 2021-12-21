import 'package:flutter/material.dart';
import 'package:firebase_authentication_tutorial/Screens/Signup/components/body.dart';
import 'package:firebase_authentication_tutorial/models/model_app.dart';
import 'package:firebase_authentication_tutorial/constants.dart';
class SignUpScreen extends StatefulWidget {
  final App app;
  SignUpScreen({this.app});
  @override
  State<StatefulWidget> createState() => new _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> {
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
