import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class Todo {
  String key;
  String code;
  String name_junta;
  Todo(this.code,this.name_junta);

  Todo.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        code = snapshot.value["code"],
        name_junta =snapshot.value["name_junta"];

  toJson() {
    return {
      "code": code,
      "name_junta":name_junta,
    };
  }
}