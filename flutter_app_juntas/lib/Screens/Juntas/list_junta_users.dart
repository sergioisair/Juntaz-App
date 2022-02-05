//import 'package:firebase_authentication_tutorial/models/JuntaIntegrants.dart';
import 'package:firebase_authentication_tutorial/Screens/Home/home.dart';
import 'package:firebase_authentication_tutorial/models/junta_integrant_model.dart';
import 'package:firebase_authentication_tutorial/models/Fields_Options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authentication_tutorial/models/user_model.dart';
import 'package:firebase_authentication_tutorial/models/junta_group_model.dart';
import 'package:firebase_authentication_tutorial/models/junta_users_list.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/create_group_junta.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/juntas_home.dart';
import 'package:firebase_authentication_tutorial/global.dart';
import 'package:firebase_authentication_tutorial/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authentication_tutorial/styles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

enum ConfirmAction { CANCEL, ACCEPT }

class ListJuntaUsers extends StatefulWidget {
  final User_ user_;
  final String junta_code;
  JuntaInfo junta_info;
  bool pay;
  ListJuntaUsers({this.user_, this.junta_info, this.junta_code});
  @override
  State<StatefulWidget> createState() => new _ListJuntaUsersState();
}

class _ListJuntaUsersState extends State<ListJuntaUsers> {
  //final FirebaseDatabase _database = FirebaseDatabase.instance;
  DatabaseReference _database = FirebaseDatabase.instance.reference();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onJuntaIntegrantsAddedSubscription;
  StreamSubscription<Event> _onJuntaIntegrantsChangedSubscription;
  Query _JuntaIntegrantsQuery;
  List<JuntaIntegrants> _JuntaIntegrantsList;
  List<JuntaUsersList> _JuntaUsersList;
  JuntaUsersList user_list = JuntaUsersList("", "", "", "", "");
  /////////////////////////////
  Future<String> _future;
  DatabaseReference _ref = FirebaseDatabase.instance.reference();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  String uid;
  //bool _isEmailVerified = false;
  bool todos = true;
  int pressed = 0;
  bool pay = false;

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
        _database.child("Juntas_Integrants/" + widget.junta_code);
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
      print("bandera List: " + (_JuntaIntegrantsList.length - 1).toString());
      print("Key junta List: " +
          _JuntaIntegrantsList[_JuntaIntegrantsList.length - 1].Key);
      FirebaseDatabase.instance
          .reference()
          .child("Users")
          .orderByKey()
          .equalTo(_JuntaIntegrantsList[_JuntaIntegrantsList.length - 1].Key)
          .once()
          .then((DataSnapshot snapshot) {
        //name_user=snapshot.value['name'];
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, values) {
          setState(
            () => _JuntaUsersList.add(JuntaUsersList(
                _JuntaIntegrantsList[_JuntaIntegrantsList.length - 1].Key,
                values["name"],
                values["apepat"],
                values["email"],
                values["phone"])),
          );
          print("users names: " + user_list.Name_user);
        });
      });
    });
  }

  deleteJuntaIntegrants(String JuntaIntegrantsId, int index) async {
    await _database
        .reference()
        .child("Juntas_Integrants/" + widget.junta_code)
        .child(JuntaIntegrantsId)
        .remove()
        .then((_) {
      print("Delete $JuntaIntegrantsId successful");
      setState(() {
        _JuntaIntegrantsList.removeAt(index);
        _JuntaUsersList.removeAt(index);
      });
    });
  }

  Future deleteJunta() async {
    //await Future.delayed(Duration(seconds: 3));
    await FirebaseDatabase.instance
        .reference()
        .child("Juntas_Info")
        .child(widget.junta_code)
        .remove();
    await FirebaseDatabase.instance
        .reference()
        .child("Juntas_Integrants")
        .child(widget.junta_code)
        .remove();
    await FirebaseDatabase.instance
        .reference()
        .child("Juntas_Transactions")
        .child(widget.junta_code)
        .remove();
    await FirebaseDatabase.instance
        .reference()
        .child("Juntas_Users")
        .child(widget.user_.id)
        .child(widget.junta_code)
        .remove();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Junta eliminada"),
          content: Text(
              "Debido a que sólo hay un miembro en la junta, esta se ha disuelto"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => //Home(uid: result.user.uid)
                          HomeScreen(user_: widget.user_),
                    ),
                  );
                },
                child: Text("Ok"))
          ],
        );
      },
    );
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

  bool eliminar = false;

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
                  int turno = _JuntaIntegrantsList[index].turno;
                  //print(integrant_email + " turno es " + turno.toString());
                  if (_JuntaIntegrantsList[index].key == widget.user_.id &&
                      _JuntaIntegrantsList[index].state_pay == "1") pay = true;
                  if (_JuntaIntegrantsList.length < 2 && eliminar == false) {
                    eliminar = true;
                    deleteJunta();
                  }
                  //print( "Tamano _JuntaUsersList "+ _JuntaUsersList.length.toString());
                  var current_turno = widget.junta_info.Turno;
                  Color color;
                  Color color_back;
                  Icon icon;
                  //if (index == current_turno) {
                  if (turno == current_turno) {
                    color_back = Colors.transparent;
                    icon = Icon(
                        widget.junta_info.total_amount ==
                                widget.junta_info.aporte *
                                    _JuntaIntegrantsList.length
                            ? Icons.download_rounded
                            : Icons.watch_later_rounded,
                        size: 30,
                        color: widget.junta_info.total_amount ==
                                widget.junta_info.aporte *
                                    _JuntaIntegrantsList.length
                            ? Colors.blueAccent
                            : Colors.grey);
                  } else if (turno > current_turno) {
                    color_back = Colors.transparent;
                    icon = Icon(Icons.cancel, size: 30, color: Colors.red);
                  } else {
                    color_back = Colors.transparent;
                    icon = Icon(Icons.check_circle_rounded,
                        size: 30, color: Colors.green);
                  }
                  /*if (state_pay == "1") {
                    color = Colors.green;
                  } else {
                    color = Colors.grey;
                  }*/
                  if (_JuntaIntegrantsList[index].state_pay == "1") {
                    color = Colors.blue;
                  } else {
                    color = Colors.grey;
                  }

                  return Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    child: Container(
                      color: color_back,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),

                        leading: CircleAvatar(
                            child: Text(
                              (turno + 1).toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: color),

                        title: Text(
                          //double.parse().toString(),
                          _JuntaUsersList[index].Apetpat == ""
                              ? _JuntaUsersList[index].Name_user.split(" ")[0] +
                                  " " +
                                  _JuntaUsersList[index].Name_user.split(" ")[1]
                              : _JuntaUsersList[index].Name_user.split(" ")[0] +
                                  " " +
                                  _JuntaUsersList[index].Apetpat.split(" ")[0],
                          style: TextStyle(fontSize: 15.0),
                        ),

                        trailing: icon,
                        // widget.junta_info.pago_day == DateTime.now().day.toString() ?
                        onTap: () async {
                          // SI ES EL TURNO
                          if (turno == current_turno) {
                            todos = true;
                            for (int i = 0;
                                i < _JuntaIntegrantsList.length;
                                i++) {
                              print("state pay: " +
                                  _JuntaIntegrantsList[i].integrant_email);
                              // SI ALGUIEN NO PAGÓ, SE DESACTIVA PAGO
                              if (_JuntaIntegrantsList[i].state_pay == "0") {
                                todos = false;
                                break;
                              }
                            }
                            // SI NO ERES EL ADMIN
                            if (widget.user_.id !=
                                widget.junta_info.id_creator) {
                              final ConfirmAction action0 =
                                  await _asyncConfirmDialog(context,
                                      "Sólo el administrador puede otorgar los pagos");
                              print("Confirm Action $action0");
                            } else {
                              // SI NO HAY PAGADO
                              if (todos == false) {
                                final ConfirmAction action1 =
                                    await _asyncConfirmDialog(context,
                                        "Todavía no pagan todos los Miembros!");
                                print("Confirm Action $action1");
                              }
                              // SI HOY NO ES EL DÍA DEL PAGO
                              else if (widget.junta_info.pago_day !=
                                  DateTime.now().day.toString()) {
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          title: Text(
                                              "Sólo se pueden hacer pagos el día pactado, vuelve el día ${widget.junta_info.pago_day}"),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text("Aceptar"))
                                          ],
                                        ));
                              } else {
                                final ConfirmAction action2 =
                                    await _asyncConfirmDialog(
                                        context,
                                        (_JuntaIntegrantsList[index]
                                                    .integrant_email ==
                                                widget.user_.email)
                                            ? "¿Deseas recibir tu pago?"
                                            : "¿Enviar pago a ${_JuntaIntegrantsList[index].integrant_email}?");
                                print("Confirm Action $action2");
                                // RECIBIR EL PAGO
                                if (action2 == ConfirmAction.ACCEPT) {
                                  var pass_turno = widget.junta_info.Turno;
                                  DateTime now = DateTime.now();
                                  String formattedDate =
                                      DateFormat('dd/MM/yyyy  kk:mm')
                                          .format(now);
                                  Map<String, String> pay = {
                                    'aporte': (widget.junta_info.aporte *
                                            _JuntaIntegrantsList.length)
                                        .toString(),
                                    'state_pay': "1",
                                    "aporte_day": formattedDate.toString(),
                                    "name_integrant":
                                        _JuntaIntegrantsList[index].name,
                                    'last_name': _JuntaIntegrantsList[index]
                                        .integrant_email,
                                  };
                                  await FirebaseDatabase.instance
                                      .reference()
                                      .child("Juntas_Transactions")
                                      .child(widget.junta_code)
                                      .push()
                                      .set(pay);
                                  for (int i = 0;
                                      i < _JuntaIntegrantsList.length;
                                      i++) {
                                    print("state pay: " +
                                        _JuntaIntegrantsList[i]
                                            .integrant_email);
                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Juntas_Integrants")
                                        .child(widget.junta_code)
                                        .child(_JuntaIntegrantsList[i].key)
                                        .update({
                                      "state_pay": "0",
                                    });
                                  }
                                  pass_turno = widget.junta_info.Turno + 1;
                                  if (pass_turno ==
                                      _JuntaIntegrantsList.length) {
                                    pass_turno = 0;
                                  }
                                  widget.junta_info.turno = pass_turno;
                                  widget.junta_info.total_amount = 0;
                                  setState(() {});
                                  int diaAporte =
                                      int.parse(widget.junta_info.aporte_day);
                                  int diaPago = DateTime.utc(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          diaAporte)
                                      .add(Duration(days: 1))
                                      .day;

                                  if (widget.junta_info.tipoJunta ==
                                      "Quincenal") {
                                    if (diaAporte <= 15) {
                                      diaAporte = diaAporte + 15;
                                      if (diaAporte == 30)
                                        diaPago = DateTime.utc(
                                                DateTime.now().year,
                                                DateTime.now().month,
                                                30)
                                            .add(Duration(days: 1))
                                            .day;
                                      else
                                        diaPago = diaAporte + 1;
                                    } else {
                                      diaAporte = diaAporte - 15;
                                      diaPago = diaAporte + 1;
                                    }
                                  }

                                  if (widget.junta_info.tipoJunta ==
                                      "Semanal") {
                                    final diaAct = diaAporte;
                                    diaAporte = DateTime.utc(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            diaAporte)
                                        .add(Duration(days: 7))
                                        .day;
                                    if (diaAct > diaAporte)
                                      diaPago = diaAporte + 1;
                                    else
                                      diaPago = DateTime.utc(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              diaAporte)
                                          .add(Duration(days: 1))
                                          .day;
                                  }

                                  await FirebaseDatabase.instance
                                      .reference()
                                      .child("Juntas_Info")
                                      .child(widget.junta_code)
                                      .update({
                                    "total_amount": "0.00",
                                    "turno": pass_turno.toString(),
                                    "aporte_day": diaAporte.toString(),
                                    "pago_date": diaPago.toString()
                                  });
                                  for (int i = 0;
                                      i < _JuntaIntegrantsList.length;
                                      i++) {
                                    if (_JuntaIntegrantsList[i].key ==
                                        widget.user_.Id) {
                                      print("tama: " +
                                          _JuntaIntegrantsList.length
                                              .toString());
                                      for (var i = 0;
                                          i < _JuntaIntegrantsList.length - 1;
                                          i++) {
                                        print("correos: " +
                                            i.toString() +
                                            " " +
                                            _JuntaIntegrantsList[i]
                                                .integrant_email);
                                      }
                                      await FirebaseDatabase.instance
                                          .reference()
                                          .child("Users")
                                          .child(widget.user_.Id)
                                          .update({
                                        "total_amount": widget
                                            .junta_info.Total_amount
                                            .toString(),
                                      }).then((value) {
                                        Future.delayed(
                                            Duration(milliseconds: 100), () {
                                          // Do something
                                        });

                                        //Navigator.of(context).pop();
                                      });
                                      _showInSnackBar(
                                          'Pago Cobrado con éxito!');
                                      widget.junta_info.total_amount = 0;
                                      widget.junta_info.pago_day =
                                          diaPago.toString();
                                      widget.junta_info.aporte_day =
                                          diaAporte.toString();
                                      setState(() {});
                                    }
                                  }
                                }
                              }
                            }
                          }
                        },
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

  int contarPagos() {
    int contadorPagos = 0;
    for (int i = 0; i < _JuntaIntegrantsList.length; i++)
      if (_JuntaIntegrantsList[i].state_pay == "1") contadorPagos++;
    actualizaTurno();
    return contadorPagos;
  }

  dynamic turno;

  void actualizaTurno() async {
    await FirebaseDatabase.instance
        .reference()
        .child("Juntas_Info")
        .child(widget.junta_code)
        .once()
        .then((snapshot) {
      turno = int.parse(snapshot.value["turno"]);
    });
    setState(() {
      widget.junta_info.turno = turno;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: kPrimaryLightColor,
      appBar: AppBar(
        backgroundColor: kPrimaryLightColor,
        title: new Text("Orden de Pago ",
            style: TextStyle(
              color: kPrimaryColor,
              fontSize: 22,
            )),
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
                    "Monto Total de Junta",
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
                        if (widget.junta_info.Coin_type ==
                            "Tipo de Moneda: Dólares")
                          TextSpan(text: "\$. "),
                        if (widget.junta_info.Coin_type ==
                            "Tipo de Moneda: Soles")
                          TextSpan(text: "S/. "),
                        TextSpan(
                          text: (contarPagos() * widget.junta_info.aporte)
                              .toStringAsFixed(
                                  0), //widget.junta_info.Total_amount.toStringAsFixed(0),
                          style: ThemeStyles()
                              .display1
                              .apply(color: Colors.white, fontWeightDelta: 2),
                        ),
                        TextSpan(
                            text:
                                " / ${(widget.junta_info.Aporte * _JuntaIntegrantsList.length).toStringAsFixed(0)}",
                            style: TextStyle(fontSize: 16)),
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
                    "Día de pago: ",
                    style: ThemeStyles()
                        .title
                        .apply(color: darkBlue, fontWeightDelta: 2),
                  ),
                ),
                Icon(Icons.timelapse, color: Colors.black.withOpacity(.71)),
                Text(
                  "Día " + widget.junta_info.pago_day,
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
            Container(
              margin: EdgeInsets.all(10),
              height: 70.0,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(
                      color: pay
                          ? Colors.black
                          : DateTime.now().day.toString() ==
                                  widget.junta_info.aporte_day
                              ? Colors.redAccent
                              : diasRestantes() > 7
                                  ? Color.fromRGBO(0, 160, 227, 1)
                                  : Colors.yellow[700],
                    )),
                onPressed: pressed == 0
                    ? () {
                        print("PRESSED ES $pressed");
                        if (pressed == 1) return;

                        if (pressed == 0) {
                          print("PRESSED CAMBIADO A 1");
                          setState(() {
                            pressed = 1;
                          });
                          if (widget.junta_info.pendientes > 0) return;
                          bool actualice = true;
                          //print("tamano de lista: "+_JuntaIntegrantsList.length.toString());
                          for (int i = 0;
                              i < _JuntaIntegrantsList.length;
                              i++) {
                            print("state pay: " + i.toString());
                            if (_JuntaIntegrantsList[i].key ==
                                    widget.user_.Id &&
                                _JuntaIntegrantsList[i].state_pay == "1") {
                              actualice = false;
                              pay = true;
                              break;
                            }
                          }
                          if (actualice == true) {
                            _validateInputs();
                          } else {
                            _showInSnackBar('Usted ya realizó su pago!');
                          }
                          setState(() async {
                            await Future.delayed(Duration(seconds: 1));
                            pressed = 0;
                          });
                        }
                      }
                    : () {},
                padding: EdgeInsets.all(10.0),
                color: pay ? Colors.grey[300] : Colors.white,
                textColor: Color.fromRGBO(0, 160, 227, 1),
                child: Text(
                  widget.junta_info.pendientes > 0
                      ? "Aún hay integrantes por confirmar"
                      : pay == true
                          ? "Ya has pagado"
                          : DateTime.now().day.toString() ==
                                  widget.junta_info.aporte_day
                              ? "Registrar aporte\nHOY es el último día de aporte"
                              : "Registrar aporte\n Restan " +
                                  diasRestantes().toString() +
                                  " días para realizar su aporte",
                  style: TextStyle(
                    fontSize: 15,
                    color: pay
                        ? Colors.black
                        : DateTime.now().day.toString() ==
                                widget.junta_info.aporte_day
                            ? Colors.redAccent
                            : diasRestantes() > 7
                                ? Color.fromRGBO(0, 160, 227, 1)
                                : Colors.yellow[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            showJuntaIntegrantsList(),
          ],
        )),
      ),
    );
  }

  int diasRestantes() {
    int hoy = DateTime.now().day;
    int diaPago = int.parse(widget.junta_info.aporte_day);
    int mesHoy = DateTime.now().month;
    if (hoy < diaPago)
      return diaPago - hoy;
    else if (mesHoy == 2) {
      return 28 - hoy + diaPago;
    } else if (mesHoy == 1 ||
        mesHoy == 3 ||
        mesHoy == 5 ||
        mesHoy == 7 ||
        mesHoy == 8 ||
        mesHoy == 10 ||
        mesHoy == 12) {
      return 31 - hoy + diaPago;
    } else
      return 30 - hoy + diaPago;
  }

  void _validateInputs() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy  kk:mm').format(now);
    //widget.user_.total_amount= widget.user_.total_amount-widget.junta_info.Aporte;
    //if(widget.user_.Total_amount>0){
    Map<String, String> pay = {
      'aporte': widget.junta_info.Aporte.toString(),
      'state_pay': "0",
      "aporte_day": formattedDate.toString(),
      "name_integrant": widget.user_.Name,
      'last_name': widget.user_.email,
      //"description":description,
      //"oxi_bool": oxi_med.toString(),
      //'type': _typeSelected,
    };
    await _ref
        .child("Juntas_Transactions")
        .child(widget.junta_code)
        .push()
        .set(pay)
        .then((value) {
      Future.delayed(Duration(milliseconds: 100), () {
        // Do something
      });
      //Navigator.of(context).pop();
    });
    updateDataRealTime();
    _showInSnackBar('Pago Realizado con éxito!');
    //}else{
    //  _showInSnackBar('Sa');
    //}
  }

  void updateDataRealTime() async {
    //final db = FirebaseDatabase.instance.reference().child("Users_Doctors").orderByKey().equalTo(widget.uid);

    print("Entra aqui");
    double montoActual;
    await FirebaseDatabase.instance
        .reference()
        .child("Juntas_Info")
        .child(widget.junta_code)
        .once()
        .then((snapshot) {
      montoActual = double.parse(snapshot.value["total_amount"]);
    });
    print("el monto actual es: " + montoActual.toString());
    setState(() {});

    widget.junta_info.total_amount = montoActual + widget.junta_info.Aporte;

    print("con mi pago ahora es: " + widget.junta_info.total_amount.toString());
    await FirebaseDatabase.instance
        .reference()
        .child("Juntas_Info")
        .child(widget.junta_code)
        .update({
      "total_amount": (widget.junta_info.Total_amount).toString(),
    });
    await FirebaseDatabase.instance
        .reference()
        .child("Juntas_Integrants")
        .child(widget.junta_code)
        .child(widget.user_.Id)
        .update({
      "state_pay": "1",
    });
    /*_firebaseRef
        .child(key)
        .update({"timestamp": DateTime.now().millisecondsSinceEpoch});*/
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(value),
      duration: new Duration(seconds: 3),
    ));
  }
}

Future _asyncConfirmDialog(BuildContext context, String date) async {
  if (date == "¿Deseas recibir tu pago?") {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirma tu respuesta'),
          content: Text(date.toString()),
          actions: [
            FlatButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.ACCEPT);
              },
            )
          ],
        );
      },
    );
  } else {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirma tu respuesta"),
          content: Text(date.toString()),
          actions: [
            FlatButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.ACCEPT);
              },
            )
          ],
        );
      },
    );
  }
}
