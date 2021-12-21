import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class JuntaIntegrants {
  String key;
  String integrant_email;
  String state_pay;
  String rol_junta;
  String name;
  int turno;
  String listo;
  String get Key {
    return key;
  }
  JuntaIntegrants(this.integrant_email,this.state_pay,this.rol_junta,this.name,this.turno,this.listo);

  JuntaIntegrants.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        integrant_email = snapshot.value["integrant_email"],
        state_pay = snapshot.value["state_pay"],
        rol_junta =snapshot.value["rol_junta"],
        name = snapshot.value["name"],
        turno = int.parse(snapshot.value["turno"]),
        listo = snapshot.value["listo"];

  toJson() {
    return {
      "integrant_email": integrant_email,
      "state_pay":state_pay,
      "rol_junta":rol_junta,
      "name": name,
      "turno":turno.toString(),
      "listo": listo,
    };
  }
}