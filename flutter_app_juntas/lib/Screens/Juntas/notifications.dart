import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authentication_tutorial/Screens/Home/home.dart';
import 'package:firebase_authentication_tutorial/models/user_model.dart';
import 'package:firebase_authentication_tutorial/models/junta_groups_list.dart';
import 'package:firebase_authentication_tutorial/models/junta_users_.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';

class ListNotifications extends StatefulWidget {
  final User_ user_;
  ListNotifications({this.user_});
  @override
  State<StatefulWidget> createState() => new _ListNotificationsState();
}

class _ListNotificationsState extends State<ListNotifications> {
  DatabaseReference _database = FirebaseDatabase.instance.reference();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<dynamic> aportesDays = [];

  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;
  Query _todoQuery;
  List<Todo> _todoList;
  List<Notificacion> _JuntaGroupsList;
  Future<String> _future;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  String uid;
  bool haveList = false;

  @override
  void initState() {
    super.initState();
    _future = fetchAllLocations();
    getCurrentUser();
  }

  Future<String> fetchAllLocations() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Future.value("test");
  }

  getCurrentUser() async {
    this.user = await _auth.currentUser();
    this.uid = user.uid;
    _todoList = new List();
    _JuntaGroupsList = new List();
    _todoQuery = _database.child("Notifications/" + widget.user_.id);
    //_onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(onEntryChanged);
    onEntryAdded();
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = _todoList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] =
          Todo.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded() {
    setState(() {
      var dbRef = FirebaseDatabase.instance
          .reference()
          .child("Notifications")
          .child(widget.user_.id)
          .once()
          .then(
        (DataSnapshot snapshot) {
          Map<dynamic, dynamic> values = snapshot.value;
          values.forEach((key, values) {
            setState(
              () => _JuntaGroupsList.add(Notificacion(
                  values["idJunta"],
                  values["info"],
                  values["type"],
                  values["date_notif"],
                  values["idNotif"])),
            );
          });
        },
      );
    });
  }

  Widget showTodoList() {
    if (_JuntaGroupsList.length > 0) {
      FirebaseDatabase.instance
                    .reference()
                    .child("NumNotif")
                    .child(widget.user_.id)
                    .remove();
                    print("Se han borrado las notificaciones");
      return ListView.builder(
          reverse: true,
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: _JuntaGroupsList.length,
          itemBuilder: (BuildContext context, int index) {
            print("FECHA DATES");
            print(_JuntaGroupsList[index].create_date);
            final color = _JuntaGroupsList[index].id_creator;
            return Dismissible(
              key: ValueKey(_JuntaGroupsList[index].Id_notif),
              direction: color == 'invite'
                  ? DismissDirection.none
                  : DismissDirection.horizontal,
              onDismissed: (direction) async {
                await FirebaseDatabase.instance
                    .reference()
                    .child("Notifications")
                    .child(widget.user_.id)
                    .child(_JuntaGroupsList[index].Id_notif)
                    .remove();
              },
              child: Container(
                child: Column(
                  children: [
                    Divider(),
                    Container(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                AssetImage("assets/icons/juntas.png"),
                            backgroundColor: color == "eliminado"
                                ? Colors.redAccent
                                : color == "abandono"
                                    ? Colors.yellowAccent
                                    : color == "invite"
                                        ? Colors.blueAccent
                                        : _JuntaGroupsList[index]
                                                .name_junta
                                                .contains("aceptado")
                                            ? Colors.green
                                            : Colors.grey,
                            radius: 15,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _JuntaGroupsList[index].Name_junta,
                              softWrap: true,
                              overflow: TextOverflow.fade,
                              maxLines: 4,
                              style: TextStyle(fontSize: 15.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    color == "invite"
                        ? Row(
                            children: [
                              Spacer(),
                              Expanded(
                                child: TextButton(
                                  child: Icon(Icons.check),
                                  onPressed: () async {
                                    int count;
                                    String notifID;
                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Juntas_Info")
                                        .child(_JuntaGroupsList[index].id)
                                        .once()
                                        .then((snapshot) {
                                      count = int.parse(
                                          snapshot.value["pendientes"]);
                                    });
                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Juntas_Info")
                                        .child(_JuntaGroupsList[index].id)
                                        .update({
                                      "pendientes": (count - 1).toString()
                                    });

                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Juntas_Integrants")
                                        .child(_JuntaGroupsList[index].id)
                                        .child(widget.user_.id)
                                        .update({"listo": "1"});
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
                                    String code_notif = cod_group[
                                            random.nextInt(cod_group.length) +
                                                1] +
                                        num.toString();
                                    String nameJunta;
                                    String codeAdmin;

                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Juntas_Info")
                                        .child(_JuntaGroupsList[index].id)
                                        .once()
                                        .then((snapshot) {
                                      nameJunta = snapshot.value["name_junta"];
                                      codeAdmin = snapshot.value["id_creator"];
                                    });

                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Notifications")
                                        .child(widget.user_.id)
                                        .child(_JuntaGroupsList[index].idNotif)
                                        .update({
                                      "idJunta": "",
                                      "type": "accepted",
                                      "info":
                                          "Has aceptado la invitación a unirte a '$nameJunta'"
                                    });

                                    Map<String, String> notification = {
                                      'date_notif': DateTime.now().toString(),
                                      'info':
                                          "${widget.user_.name} ha aceptado unirse a tu junta '$nameJunta'",
                                      'type': "aceptado",
                                      "idJunta": "",
                                      "idNotif": code_notif
                                    };
                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Notifications")
                                        .child(codeAdmin)
                                        .child(code_notif)
                                        .set(notification);
                                    
                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("NumNotif")
                                        .child(codeAdmin)
                                        .child(code_notif)
                                        .set(notification);

                                    await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: Text("Has aceptado"),
                                            ));
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
                              ),
                              Expanded(
                                child: TextButton(
                                  child: Icon(Icons.close),
                                  onPressed: () async {
                                    // actualizar pendientes
                                    int count;

                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Juntas_Info")
                                        .child(_JuntaGroupsList[index].id)
                                        .once()
                                        .then((snapshot) {
                                      count = int.parse(
                                          snapshot.value["pendientes"]);
                                    });
                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Juntas_Info")
                                        .child(_JuntaGroupsList[index].id)
                                        .update({
                                      "pendientes": (count - 1).toString()
                                    });
                                    // acomodar turnos

                                    // eliminarme de integrantes
                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Juntas_Users")
                                        .child(widget.user_.id)
                                        .child(_JuntaGroupsList[index].id)
                                        .remove();

                                    // por si acaso borrar esto
                                    int turnoEliminado;
                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Juntas_Integrants")
                                        .child(_JuntaGroupsList[index].id)
                                        .child(widget.user_.id)
                                        .once()
                                        .then((snapshot) {
                                      turnoEliminado =
                                          int.parse(snapshot.value["turno"]);
                                    });

                                    print("MI TURNO ERA: " +
                                        turnoEliminado.toString());

                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Juntas_Integrants")
                                        .child(_JuntaGroupsList[index].id)
                                        .child(widget.user_.id)
                                        .remove();

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
                                    String code_notif = cod_group[
                                            random.nextInt(cod_group.length) +
                                                1] +
                                        num.toString();
                                    String nameJunta;
                                    String codeAdmin;

                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Juntas_Info")
                                        .child(_JuntaGroupsList[index].id)
                                        .once()
                                        .then((snapshot) {
                                      nameJunta = snapshot.value["name_junta"];
                                      codeAdmin = snapshot.value["id_creator"];
                                    });

                                    // mandar notif
                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Notifications")
                                        .child(widget.user_.id)
                                        .child(_JuntaGroupsList[index].idNotif)
                                        .update({
                                      "idJunta": "",
                                      "type": "accepted",
                                      "info":
                                          "Has rechazado la invitación a '$nameJunta'"
                                    });

                                    Map<String, String> notification = {
                                      'date_notif': DateTime.now().toString(),
                                      'info':
                                          "${widget.user_.name} ha rechazado unirse a '$nameJunta'",
                                      'type': "adsa",
                                      "idJunta": "",
                                      "idNotif": code_notif
                                    };
                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Notifications")
                                        .child(codeAdmin)
                                        .child(code_notif)
                                        .set(notification);

                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("NumNotif")
                                        .child(codeAdmin)
                                        .child(code_notif)
                                        .set(notification);

                                    await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: Text("Has rechazado"),
                                            ));

                                    // turno

                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Juntas_Integrants")
                                        .child(_JuntaGroupsList[index].id)
                                        .once()
                                        .then((DataSnapshot snapshot) {
                                      Map<dynamic, dynamic> values =
                                          snapshot.value;
                                      values.forEach((key, valuess) {
                                        int turnoUser = int.parse(valuess["turno"]);
                                        print("USER TURNO de $key es $turnoUser");
                                        if (turnoUser > turnoEliminado) {
                                          FirebaseDatabase.instance
                                              .reference()
                                              .child("Juntas_Integrants")
                                              .child(_JuntaGroupsList[index].id)
                                              .child(key)
                                              .update({
                                            "turno": (turnoUser - 1).toString(),
                                          });
                                        }
                                      });
                                    });

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
                              ),
                              Spacer(),
                            ],
                          )
                        : Container(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "Recibida el " +
                            _JuntaGroupsList[index].Create_date.split(" ")[0] +
                            " a las " +
                            (_JuntaGroupsList[index].Create_date.split(" ")[1])
                                .split(".")[0],
                        style: TextStyle(fontSize: 10.0),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    } else {
      return Center(
          child: Text(
        "No tienes Notificaciones",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder(
          future: _future,
          // ignore: missing_return
          builder: (context, AsyncSnapshot<String> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('Ninguna Conexión Establecida');
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
                return Text('Conexión Activa');
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text(
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                  );
                } else {
                  return showTodoList();
                }
            }
          }),
    );
  }
}
