import 'package:flutter/material.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/components/body_create_junta.dart';
import 'package:firebase_authentication_tutorial/models/model_app.dart';
import 'package:firebase_authentication_tutorial/models/user_model.dart';
import 'package:firebase_authentication_tutorial/constants.dart';
class CreateJunta extends StatefulWidget {
  final User_ user_;
  CreateJunta({ this.user_});
  @override
  State<StatefulWidget> createState() => new _CreateJunta();
}

class _CreateJunta extends State<CreateJunta> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: Colors.black),),
      backgroundColor: kPrimaryBackgroundColor,
      body: BodyCreateJunta(user_: widget.user_,),
    );
  }
}