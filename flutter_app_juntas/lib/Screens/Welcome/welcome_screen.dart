import 'package:flutter/material.dart';
import 'package:firebase_authentication_tutorial/Screens/Welcome/components/body.dart';
import 'package:firebase_authentication_tutorial/models/model_app.dart';
import 'package:firebase_authentication_tutorial/constants.dart';
class WelcomeScreen extends StatefulWidget {
  
  @override
  State<StatefulWidget> createState() => new _WelcomeScreen();
}

class _WelcomeScreen extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBackgroundColor,
      body: Body(),
    );
  }
}
