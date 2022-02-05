import 'package:firebase_authentication_tutorial/models/junta_integrant_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_authentication_tutorial/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'dart:math';

enum ConfirmAction { CANCEL, ACCEPT }

class ListAddIntegrants extends StatefulWidget {
  final String junta_code;
  int tam;
  List<JuntaIntegrants> listUsers;
  ListAddIntegrants({this.junta_code, this.tam, this.listUsers});
  @override
  State<StatefulWidget> createState() => new _ListJuntaUsersState();
}

class _ListJuntaUsersState extends State<ListAddIntegrants> {
  List<Item> AddIntegrants = List();
  Item item;
  DatabaseReference itemRef;
  TextEditingController controller = new TextEditingController();
  String filter = null;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    item = Item("", "", false, "");
    final FirebaseDatabase database = FirebaseDatabase
        .instance; //Rather then just writing FirebaseDatabase(), get the instance.
    itemRef = database.reference().child('Users');
    itemRef.onChildAdded.listen(_onEntryAdded);
    itemRef.onChildChanged.listen(_onEntryChanged);
    controller.addListener(() {
      setState(() {
        filter = controller.text;
      });
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      AddIntegrants.add(Item.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = AddIntegrants.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      AddIntegrants[AddIntegrants.indexOf(old)] =
          Item.fromSnapshot(event.snapshot);
    });
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      itemRef.push().set(item.toJson());
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: kPrimaryLightColor,
        iconTheme: IconThemeData(color: Colors.black87),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 20),
          new Container(
              width: 300,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Buscar Personas',
                  hintText: 'Buscar Personas',
                ),
                controller: controller,
                autofocus: false,
              )),
          Flexible(
            child: FirebaseAnimatedList(
              query: itemRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                if (filter == "" || filter == null) {
                  //print("bandera mas tarde");
                  return new Container(
                      //child: Text("Buscar Personas"),
                      );
                } else {
                  return (AddIntegrants[index]
                                  .name
                                  .toUpperCase()
                                  .startsWith(filter.toUpperCase()) ||
                              AddIntegrants[index]
                                  .form
                                  .toUpperCase()
                                  .startsWith(filter.toUpperCase())) &&
                          AddIntegrants[index].validado == true
                      ? ListTile(
                          onTap: () async {
                            final ConfirmAction action =
                                await _asyncConfirmDialog(
                                    context,
                                    AddIntegrants[index].name,
                                    AddIntegrants[index].key);
                            if (action == ConfirmAction.ACCEPT) {
                              print("Confirm Action: " + action.toString());
                              _saveInputs(AddIntegrants[index]);
                              controller.text = "";
                            }
                          },
                          leading: Icon(Icons.person_add, size: 40),
                          title: Text(AddIntegrants[index].name),
                          subtitle: Text(AddIntegrants[index].form),
                        )
                      : new Container(
                          //child: Text("No encontrado"),
                          );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveInputs(Item user_item) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy  kk:mm').format(now);
    DatabaseReference dbRef1 = FirebaseDatabase.instance.reference();

    if (user_item.notif == true) {
      Random random = Random();
      var cod_group = [
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J',
        'K',
        'L'
      ];
      final num = random.nextInt(9000) + 1000;
      final code_notif =
          cod_group[random.nextInt(cod_group.length) + 1] + num.toString();
      int count;
      String nameJunta;

      await FirebaseDatabase.instance
          .reference()
          .child("Juntas_Info")
          .child(widget.junta_code)
          .once()
          .then((snapshot) {
        count = int.parse(snapshot.value["pendientes"]);
        nameJunta = snapshot.value["name_junta"];
      });
      await FirebaseDatabase.instance
          .reference()
          .child("Juntas_Info")
          .child(widget.junta_code)
          .update({"pendientes": (count + 1).toString()});
      Map<String, String> notification = {
        'date_notif': DateTime.now().toString(),
        'info': "Has sido invitado a la junta '${nameJunta}', ¿deseas aceptar?",
        'type': "invite",
        "idJunta": widget.junta_code,
        "idNotif": code_notif
      };
      await FirebaseDatabase.instance
          .reference()
          .child("Notifications")
          .child(user_item.key)
          .child(code_notif)
          .set(notification);
      await FirebaseDatabase.instance
          .reference()
          .child("NumNotif")
          .child(user_item.key)
          .child(code_notif)
          .set(notification);
    }
    String estaListo = "1";
    if (user_item.notif == true) estaListo = "0";
    Map<String, String> junta_integrants = {
      "integrant_email": user_item.form,
      "state_pay": "0",
      'rol_junta': "0",
      "name": user_item.name,
      'turno': widget.tam.toString(),
      'listo': estaListo,
      'phone': user_item.phone
    };
    Map<String, String> junta_users = {
      'code': widget.junta_code,
      'rol_junta': "0",
      'listo': estaListo
    };
    await dbRef1
        .child("Juntas_Users")
        .child(user_item.key)
        .child(widget.junta_code)
        .set(junta_users);
    await dbRef1
        .child("Juntas_Integrants")
        .child(widget.junta_code)
        .child(user_item.key)
        .set(junta_integrants);
    widget.tam = widget.tam + 1;
  }

  Future _asyncConfirmDialog(
      BuildContext context, String name, String keyUser) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Miembro'),
          content: Text('Deseas agregar a ' + name.toString() + " ?"),
          actions: [
            FlatButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text('Ok'),
              onPressed: () async {
                if (widget.listUsers.any((user) => user.key == keyUser)) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: Text("No se agregó"),
                          content:
                              Text("Este usuario ya se encuentra en la junta"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("OK"),
                            )
                          ]);
                    },
                  );
                  await Future.delayed(Duration(seconds: 2));
                  Navigator.of(context).pop(ConfirmAction.CANCEL);
                } else {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                              title: Container(
                                  child: Text(
                            "Se agregó a ${name.toString()} a tu junta correctamente",
                            maxLines: 3,
                          ))));
                  await Future.delayed(Duration(seconds: 2));
                  Navigator.pop(context);
                  Navigator.of(context).pop(ConfirmAction.ACCEPT);
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class Item {
  String key;
  String form;
  String name;
  bool notif;
  bool validado;
  String phone;

  Item(this.form, this.name, this.notif, this.phone);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        form = snapshot.value["email"],
        name = snapshot.value["name"],
        notif = snapshot.value["notificar"] as bool,
        phone = snapshot.value["phone"],
        validado = snapshot.value["validado"] as bool;

  toJson() {
    return {
      "email": form,
      "name": name,
      "notificar": notif,
      "phone": phone,
      "validado": validado
    };
  }
}
