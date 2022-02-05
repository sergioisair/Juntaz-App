//import 'package:firebase_authentication_tutorial/models/JuntaIntegrants.dart';
import 'dart:math';

import 'package:firebase_authentication_tutorial/Screens/Home/home.dart';
import 'package:firebase_authentication_tutorial/models/junta_groups_list.dart';
import 'package:firebase_authentication_tutorial/models/junta_integrant_model.dart';
import 'package:firebase_authentication_tutorial/models/Fields_Options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authentication_tutorial/models/user_model.dart';
import 'package:firebase_authentication_tutorial/models/junta_group_model.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/create_group_junta.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/juntas_home.dart';
import 'package:firebase_authentication_tutorial/global.dart';
import 'package:firebase_authentication_tutorial/styles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_authentication_tutorial/constants.dart';
import 'package:firebase_authentication_tutorial/models/junta_users_list.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/list_add_integrants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

enum ConfirmAction { CANCEL, ACCEPT }

class PayJunta extends StatefulWidget {
  final User_ user_;
  final String junta_code;
  JuntaInfo junta_info;
  PayJunta({this.user_, this.junta_info, this.junta_code});
  @override
  State<StatefulWidget> createState() => new _PayJuntaState();
}

class _PayJuntaState extends State<PayJunta> {
  //final FirebaseDatabase _database = FirebaseDatabase.instance;
  DatabaseReference _database = FirebaseDatabase.instance.reference();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onJuntaIntegrantsAddedSubscription;
  StreamSubscription<Event> _onJuntaIntegrantsChangedSubscription;
  Query _JuntaIntegrantsQuery;
  List<JuntaIntegrants> _JuntaIntegrantsList;
  /////////////////////////////
  Future<String> _future;
  List<JuntaUsersList> _JuntaUsersList;
  DatabaseReference _ref = FirebaseDatabase.instance.reference();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  String uid;
  //bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    _future = fetchAllLocations();
    getCurrentUser();

    //_checkEmailVerification();
  }

  Future<String> fetchAllLocations() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Future.value("test");
  }

  getCurrentUser() async {
    this.user = await _auth.currentUser();
    this.uid = user.uid;
    // Similarly we can get email as well
    //final uemail = user.email;
    //////////////////////////////
    _JuntaIntegrantsList = new List();
    _JuntaUsersList = new List();
    _JuntaIntegrantsQuery =
        await _database.child("Juntas_Integrants/" + widget.junta_code);
    _onJuntaIntegrantsAddedSubscription =
        _JuntaIntegrantsQuery.onChildAdded.listen(onEntryAdded);
    _onJuntaIntegrantsChangedSubscription =
        _JuntaIntegrantsQuery.onChildChanged.listen(onEntryChanged);
  }

  @override
  void dispose() {
    _onJuntaIntegrantsAddedSubscription.cancel();
    _onJuntaIntegrantsChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = _JuntaIntegrantsList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _JuntaIntegrantsList[_JuntaIntegrantsList.indexOf(oldEntry)] =
          JuntaIntegrants.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      _JuntaIntegrantsList.add(JuntaIntegrants.fromSnapshot(event.snapshot));
      FirebaseDatabase.instance
          .reference()
          .child("Users")
          .orderByKey()
          .equalTo(_JuntaIntegrantsList[_JuntaIntegrantsList.length - 1].Key)
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, values) {
          print("KEY ES : " + key);
          setState(
            () => _JuntaUsersList.add(JuntaUsersList(key, values["name"],
                values["apepat"], values["email"], values['phone'])),
          );
        });
      });
    });
  }

  deleteJuntaIntegrants(String JuntaIntegrantsId, int index) async {
    // BAJAR PENDIENTES
    await FirebaseDatabase.instance
        .reference()
        .child("Juntas_Integrants")
        .child(widget.junta_code)
        .child(JuntaIntegrantsId)
        .once()
        .then((DataSnapshot snapshot) async {
      if (snapshot.value["listo"] == "0") {
        int pend;
        await FirebaseDatabase.instance
            .reference()
            .child("Juntas_Info")
            .child(widget.junta_code)
            .once()
            .then((DataSnapshot snapshotJunta) {
          pend = int.parse(snapshotJunta.value["pendientes"]);
        });
        print("PEND ES $pend");
        FirebaseDatabase.instance
            .reference()
            .child("Juntas_Info")
            .child(widget.junta_code)
            .update({"pendientes": (pend - 1).toString()});
      }
    });
    // BORRAR NOTIFICACIONES DEL USER
    await FirebaseDatabase.instance
        .reference()
        .child("Notifications")
        .child(JuntaIntegrantsId)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, valuess) {
        print("IDJUNTA: " +
            valuess["idJunta"].toString() +
            " es igual a ${widget.junta_code} ?");
        if (valuess["idJunta"].toString().contains(widget.junta_code)) {
          print("SI CONTIENE");
          FirebaseDatabase.instance
              .reference()
              .child("Notifications")
              .child(JuntaIntegrantsId)
              .child(key)
              .remove();
        }
      });
    });

    print("CONTINUANDO CON LA ELIMINACION :)");
    await _database
        .reference()
        .child("Juntas_Users/" + JuntaIntegrantsId)
        .child(widget.junta_code)
        .remove();
    await _database
        .reference()
        .child("Juntas_Integrants/" + widget.junta_code)
        .child(JuntaIntegrantsId)
        .remove()
        .then((_) async {
      print("Delete $JuntaIntegrantsId successful");

      int turnoDelEliminado = _JuntaIntegrantsList[index].turno;
      // REDUCIR EL TURNO
      for (int i = 0; i < _JuntaIntegrantsList.length; i++) {
        if (_JuntaIntegrantsList[i].turno > turnoDelEliminado) {
          _JuntaIntegrantsList[i].turno = _JuntaIntegrantsList[i].turno - 1;
          // ACTUALIZAR TURNOS
          await FirebaseDatabase.instance
              .reference()
              .child("Juntas_Integrants")
              .child(widget.junta_code)
              .child(_JuntaIntegrantsList[i].key)
              .update({
            "turno": _JuntaIntegrantsList[i].turno.toString(),
          });
        }
      }
      if (turnoDelEliminado < widget.junta_info.turno) {
        // ACTUALIZAR TURNO GLOBAL
        widget.junta_info.turno = widget.junta_info.turno - 1;
        await FirebaseDatabase.instance
            .reference()
            .child("Juntas_Info")
            .child(widget.junta_code)
            .update({
          "total_amount": "0.00",
          "turno": widget.junta_info.turno.toString(),
        });
      }

      setState(() {
        _JuntaIntegrantsList.removeAt(index);
        _JuntaUsersList.removeAt(index);
      });
    });
  }

  showAddJuntaIntegrantsDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new TextField(
                  controller: _textEditingController,
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'No hay Juntas',
                  ),
                ))
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Guardar'),
                  onPressed: () {
                    //addNewJuntaIntegrants(_textEditingController.text.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  int contarPend() {
    int contadorPend = 0;
    for (int i = 0; i < _JuntaIntegrantsList.length; i++)
      if (_JuntaIntegrantsList[i].listo == "0") contadorPend++;
    return contadorPend;
  }

  Widget showJuntaIntegrantsList() {
    if (_JuntaIntegrantsList.length > 0) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: _JuntaIntegrantsList.length,
                itemBuilder: (BuildContext context, int index) {
                  String code = _JuntaIntegrantsList[index].key;
                  String integrant_email =
                      _JuntaIntegrantsList[index].integrant_email;
                  String state_pay = _JuntaIntegrantsList[index].state_pay;
                  String rol_junta = _JuntaIntegrantsList[index].rol_junta;
                  Color color;

                  Icon icon;
                  if (state_pay == "1") {
                    color = Colors.green;
                    icon = Icon(Icons.check_circle_rounded,
                        size: 25, color: Colors.blue);
                  } else {
                    color = Colors.blue;
                    icon = Icon(Icons.circle_outlined,
                        size: 25, color: Colors.blue);
                  }
                  //print("index "+_JuntaIntegrantsList.length.toString()+"  "+ index.toString());
                  return Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    child: Container(
                      color: kPrimaryBackgroundContainer,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        leading: Container(
                          padding: EdgeInsets.only(right: 12.0),
                          decoration: new BoxDecoration(
                              border: new Border(
                                  right: new BorderSide(
                                      width: 2.0, color: Colors.lightBlue))),
                          child: icon,
                        ),

                        title: Container(
                          alignment: Alignment.center,
                          //padding: EdgeInsets.only(top: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                //double.parse().toString(),
                                _JuntaUsersList[index].Apetpat == ""
                                    ? _JuntaUsersList[index]
                                            .Name_user
                                            .split(" ")[0] +
                                        " " +
                                        _JuntaUsersList[index]
                                            .Name_user
                                            .split(" ")[1]
                                    : _JuntaUsersList[index]
                                            .Name_user
                                            .split(" ")[0] +
                                        " " +
                                        _JuntaUsersList[index]
                                            .Apetpat
                                            .split(" ")[0] +
                                        "  ",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color:
                                        _JuntaIntegrantsList[index].listo == "1"
                                            ? Colors.black
                                            : Colors.red),
                              ),
                              if (_JuntaUsersList[index].id != widget.user_.id)
                                GestureDetector(
                                  child: Icon(FontAwesomeIcons.whatsapp),
                                  onTap: () async {
                                    String phone;
                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Users")
                                        .child(_JuntaUsersList[index].id)
                                        .once()
                                        .then((snapshot) {
                                      phone = snapshot.value["telefono"];
                                    });
                                    print("El teléfono es: " + phone);
                                    String msj = "";
                                    String url =
                                        "whatsapp://send?phone=+51${phone.trim()}&text=$msj";
                                    await canLaunch(url)
                                        ? launch(url)
                                        : print("No se pudo abrir whatsapp");
                                  },
                                ),
                            ],
                          ),
                        ),
                        trailing: new Column(
                          children: <Widget>[
                            if (widget.junta_info.creator_email == user.email)
                              new Container(
                                child: new IconButton(
                                  icon: new Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    if (widget.junta_info.creator_email ==
                                            widget.user_.Email &&
                                        integrant_email != widget.user_.Email &&
                                        state_pay != "1") {
                                      if (_JuntaIntegrantsList.length < 3) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: Text(
                                                  "No se puede quedar una junta con una sola persona"),
                                              actions: [
                                                TextButton(
                                                  child: Text("Ok"),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                )
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        ConfirmAction action =
                                            await _asyncConfirmDialog(
                                                context,
                                                "Deseas eliminar a " +
                                                    integrant_email +
                                                    " ?");
                                        print("Confirm Action $action");
                                        if (action == ConfirmAction.ACCEPT) {
                                          action = await _asyncConfirmDialog(
                                              context,
                                              "Confirmas la eliminación del usuario con el email " +
                                                  integrant_email +
                                                  " ? ");
                                          if (action == ConfirmAction.ACCEPT) {
                                            String tieneListo =
                                                _JuntaIntegrantsList[index]
                                                    .listo;
                                            deleteJuntaIntegrants(code, index);
                                            Random random = Random();
                                            final num =
                                                random.nextInt(9000) + 1000;
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
                                            final code_notif = cod_group[
                                                    random.nextInt(
                                                            cod_group.length) +
                                                        1] +
                                                num.toString();
                                            Map<String, String> notification = {
                                              'date_notif':
                                                  DateTime.now().toString(),
                                              'info':
                                                  "Has sido eliminado de la junta '${widget.junta_info.name_junta}'",
                                              'type': "eliminado",
                                              'idNotif': code_notif
                                            };

                                            await FirebaseDatabase.instance
                                                .reference()
                                                .child("Notifications")
                                                .child(
                                                    _JuntaUsersList[index].id)
                                                .child(code_notif)
                                                .set(notification);
                                            await FirebaseDatabase.instance
                                                .reference()
                                                .child("NumNotif")
                                                .child(
                                                    _JuntaUsersList[index].id)
                                                .child(code_notif)
                                                .set(notification);

                                            /*print("INICIO DE LO CHIDO");
                                            String userPendiente;
                                            print("Buscando en JuntaIntegrants/${widget.junta_code}/${_JuntaUsersList[index].id}");
                                            await FirebaseDatabase.instance
                                                .reference()
                                                .child("Juntas_Integrants")
                                                .child(widget.junta_code)
                                                .child(
                                                    _JuntaUsersList[index].id)
                                                .once()
                                                .then((snapshot) {
                                              userPendiente = snapshot.value["listo"];
                                            });
                                            print("userPendiente = $userPendiente");
                                            String pendientes;
                                            if(userPendiente == "0"){
                                              print("Ni entra aqui");
                                              await FirebaseDatabase.instance
                                                .reference()
                                                .child("Juntas_Info")
                                                .child(widget.junta_code)
                                                .once()
                                                .then((snapshot) {
                                              pendientes = snapshot.value["pendientes"].toString();
                                            });
                                            print(pendientes);
                                            int p = int.parse(pendientes);
                                            print("pendientes = $p");
                                            p = p -1;
                                              await FirebaseDatabase.instance
                                                .reference()
                                                .child("Juntas_Info")
                                                .child(widget.junta_code)
                                                .update({
                                                "pendientes": p,
                                              });
                                              String idnotif;
                                              await FirebaseDatabase.instance
                                                .reference()
                                                .child("Notifications")
                                                .child(
                                                    _JuntaUsersList[index].id)
                                                    .once()
                                                .then((snapshot) {
                                                  //print("FOR: IdJunta es "+snapshot.value["idJunta"].toString());
                                              if(snapshot.value["idJunta"] == widget.junta_code)
                                              {
                                                idnotif = snapshot.value["idNotif"];
                                              }
                                            });
                                                   print("idnotif = $idnotif");
                                              await FirebaseDatabase.instance
                                                .reference()
                                                .child("Notifications")
                                                .child(
                                                    _JuntaUsersList[index].id)
                                                .child(idnotif)
                                                .remove();
                                              
                                            print("FIN DE LO CHIDO");
                                            }
                                            */
                                          }
                                        }
                                      }
                                    } else if (state_pay == "1") {
                                      final ConfirmAction action =
                                          await _asyncConfirmDialog(context,
                                              "No puedes eliminar a usuario que realizó aporte!.");
                                    } else if (integrant_email ==
                                        widget.user_.Email) {
                                      final ConfirmAction action =
                                          await _asyncConfirmDialog(context,
                                              "No puedes eliminarte como creador.");
                                    } else {
                                      final ConfirmAction action =
                                          await _asyncConfirmDialog(context,
                                              "Sólo el creador puede eliminar a los miembro");
                                    }
                                  },
                                ),
                              )
                          ],
                        ),
                        //onTap: ()
                      ),
                    ),
                  );
                }),
          ],
        ),
      );
    } else {
      return Center(
          child: Text(
        "No hay Aportes",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
    }
  }

  int myPos;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: kPrimaryLightColor,
      appBar: AppBar(
        backgroundColor: kPrimaryLightColor,
        title: new Text("Integrantes de Junta ",
            style: TextStyle(
              color: kPrimaryColor,
              fontSize: 22,
            )),
        actions: [
          (widget.junta_info.id_creator != widget.user_.id &&
                  _JuntaIntegrantsList.length > 2)
              ? IconButton(
                  icon: Icon(Icons.exit_to_app_rounded, color: Colors.red),
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Container(
                              child: Text(
                                "¿Deseas abandonar la junta?",
                                textScaleFactor: 0.9,
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: Text("Cancelar"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Text("Sí"),
                                onPressed: () async {
                                  // ENVIAR NOTIFICACIONES A LOS OTROS USERS
                                  for (int i = 0;
                                      i < _JuntaIntegrantsList.length;
                                      i++) {
                                    if (_JuntaIntegrantsList[i].key ==
                                        widget.user_.id) {
                                      myPos = i;
                                      break;
                                    }
                                  }
                                  print("MI POSICION ES: " + myPos.toString());
                                  print("CORREO DE MYPOS: " +
                                      _JuntaIntegrantsList[myPos]
                                          .integrant_email);
                                  deleteJuntaIntegrants(
                                      _JuntaIntegrantsList[myPos].key, myPos);
                                  Random random = Random();
                                  final num = random.nextInt(9000) + 1000;
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
                                  final code_notif = cod_group[
                                          random.nextInt(cod_group.length) +
                                              1] +
                                      num.toString();

                                  Map<String, String> notification = {
                                    'date_notif': DateTime.now().toString(),
                                    'info':
                                        "${widget.user_.name} ha abandonado la junta '${widget.junta_info.name_junta}'",
                                    'type': "abandono",
                                    "idJunta": widget.junta_code,
                                    "idNotif": code_notif
                                  };
                                  for (int i = 0;
                                      i < _JuntaIntegrantsList.length;
                                      i++) {
                                    if (_JuntaIntegrantsList[i]
                                            .integrant_email !=
                                        widget.user_.email) {
                                      print("SE ENVIA NOTIF A " +
                                          _JuntaIntegrantsList[i]
                                              .integrant_email);
                                      await FirebaseDatabase.instance
                                          .reference()
                                          .child("Notifications")
                                          .child(_JuntaIntegrantsList[i].key)
                                          .child(code_notif)
                                          .set(notification);
                                      await FirebaseDatabase.instance
                                          .reference()
                                          .child("NumNotif")
                                          .child(_JuntaIntegrantsList[i].key)
                                          .child(code_notif)
                                          .set(notification);
                                    }
                                  }
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => //Home(uid: result.user.uid)
                                              HomeScreen(user_: widget.user_),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        });
                  })
              : Container()
        ],
        iconTheme: IconThemeData(color: Colors.black87),
        elevation: 0,
      ),
      body: new Container(
        decoration: BoxDecoration(color: kPrimaryLightColor),
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: new Form(
            child: new ListView(
          children: <Widget>[
            new SizedBox(
              height: 20.0,
            ),
            Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Total de Integrantes",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 11.0,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "   " + _JuntaIntegrantsList.length.toString(),
                          style: ThemeStyles()
                              .display1
                              .apply(color: Colors.white, fontWeightDelta: 2),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.lock, color: Colors.grey[300]),
                      SizedBox(width: 5.0),
                      if (widget.junta_info.Coin_type ==
                          "Tipo de Moneda: Dólares")
                        Text(
                          "Aporte " +
                              widget.junta_info.tipoJunta +
                              ": \$. " +
                              widget.junta_info.Aporte.toStringAsFixed(0),
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                      if (widget.junta_info.Coin_type ==
                          "Tipo de Moneda: Soles")
                        Text(
                          "Aporte " +
                              widget.junta_info.tipoJunta +
                              ": S/. " +
                              widget.junta_info.Aporte.toStringAsFixed(0),
                          style: TextStyle(color: Colors.grey[300]),
                        )
                    ],
                  ),
                  SizedBox(
                    height: 11.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Día límite de aporte: ",
                    style: ThemeStyles()
                        .title
                        .apply(color: darkBlue, fontWeightDelta: 2),
                  ),
                ),
                Icon(Icons.timelapse, color: Colors.black.withOpacity(.71)),
                Text(
                  " Día " + widget.junta_info.aporte_day,
                  style: TextStyle(color: Colors.black.withOpacity(.71)),
                ),
              ],
            ),
            Divider(
              height: 30,
            ),
            new SizedBox(
              height: 20.0,
            ),
            if (contarPend() > 0)
              Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    "Usuarios pendientes:  ${contarPend()}",
                    style: TextStyle(fontSize: 20),
                  )),
            if (contarPend() > 0)
              Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    "Los usuarios pendientes se muestran en rojo",
                    style: TextStyle(fontSize: 14),
                  )),
            showJuntaIntegrantsList(),
            showAddItegrant()
          ],
        )),
      ),
    );
  }

  Widget showAddItegrant() {
    if (widget.junta_info.Id_creator == widget.user_.Id) {
      return Container(
        margin: EdgeInsets.all(10),
        width: 500,
        height: 50.0,
        alignment: Alignment.center,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Color.fromRGBO(0, 160, 227, 1))),
          onPressed: () async {
            int pendientes;
            await FirebaseDatabase.instance
                .reference()
                .child("Juntas_Info")
                .child(widget.junta_code)
                .once()
                .then((snapshot) {
              pendientes = int.parse(snapshot.value["pendientes"]);
            });
            if (pendientes > 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ListAddIntegrants(
                        junta_code: widget.junta_info.Code,
                        tam: _JuntaIntegrantsList.length,
                        listUsers: _JuntaIntegrantsList)),
              );
            } else
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Text(
                        "No se puede agregar miembros a la junta cuando ya ha iniciado"),
                    actions: [
                      TextButton(
                        child: Text("Ok"),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  );
                },
              );
          },
          padding: EdgeInsets.all(10.0),
          color: Colors.white,
          textColor: Color.fromRGBO(0, 160, 227, 1),
          child: Text("Agregar a Miembros", style: TextStyle(fontSize: 15)),
        ),
      );
    } else {
      return SizedBox(
        height: 0,
      );
    }
  }
}

Future _asyncConfirmDialog(BuildContext context, String date) async {
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Informe'),
        content: Text(date.toString()),
        actions: [
          FlatButton(
            child: const Text('CANCELAR'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.CANCEL);
            },
          ),
          FlatButton(
            child: const Text('SÍ'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.ACCEPT);
            },
          ),
        ],
      );
    },
  );
}
