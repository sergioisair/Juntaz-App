import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class JuntaTransaction {
  String key;
  String aporte;
  String aporte_day;
  String name_integrant;
  String last_name;
  String state_pay;
  JuntaTransaction(this.aporte,this.aporte_day, this.name_integrant, this.last_name, this.state_pay);

  JuntaTransaction.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        aporte = snapshot.value["aporte"],
        aporte_day =snapshot.value["aporte_day"],
        name_integrant =snapshot.value["name_integrant"],
        last_name =snapshot.value["last_name"],
        state_pay =snapshot.value["state_pay"];

  toJson() {
    return {
      "aporte": aporte,
      "aporte_day":aporte_day,
      "name_integrant":name_integrant,
      "last_name": last_name,
      "state_pay":state_pay
    };
  }
}