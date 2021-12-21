import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class Todo {
  String key;
  String name;
  String comment;
  String date;
  String id;
  Todo(this.id,this.name, this.comment,this.date);

  Todo.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        id = snapshot.value["id"],
        name = snapshot.value["name"],
        comment = snapshot.value["comment"],
        date = snapshot.value["date"];

  toJson() {
    return {
      "id": id,
      "name": name,
      "comment": comment,
      "date": date,
    };
  }
}