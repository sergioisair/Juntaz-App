import 'dart:async';

import 'package:firebase_authentication_tutorial/Screens/Juntas/notifications.dart';
import 'package:firebase_authentication_tutorial/global.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_authentication_tutorial/Screens/Welcome/welcome_screen.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/list_juntas.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/list_add_integrants.dart';
import 'package:firebase_authentication_tutorial/models/user_model.dart';
import 'package:firebase_authentication_tutorial/constants.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/create_group_junta.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_authentication_tutorial/models/model_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_calendar/smart_calendar.dart';
import 'package:smart_calendar/controller/smart_calendar_controller.dart';

var auth2;

class HomeScreen extends StatefulWidget {
  final User_ user_;
  HomeScreen({this.user_});
  @override
  State<StatefulWidget> createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool logged;
  bool isOpen;
  List<bool> _isOpen = [false, false];
  Future<int> numNotif;
  Query db = null;
  /*User_ user_ = new User_(
      "NONE", "...", "...", "...", "Elegir", "...", "...", 0.00, null, "...");*/
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user = null;
  String uid;
  void initState() {
    super.initState();
    getCurrentUser();
    auth2 = _auth;
  }
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;
  StreamSubscription<Event> _onTodoRemoveSubscription;
  Query _todoQuery;

  int cant = 0;

  getCurrentUser() async {
    this.user = await _auth.currentUser();
    this.uid = user.uid;
    cant = 0;
    _todoQuery = FirebaseDatabase.instance.reference().child("NumNotif/" + widget.user_.Id);
    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(onEntryChanged);
    _onTodoChangedSubscription =
    _todoQuery.onChildRemoved.listen(onEntryRemoved);
  }

  onEntryChanged(Event event) async {
    
      String snap;
      await FirebaseDatabase.instance
        .reference()
        .child("NumNotif")
        .child(widget.user_.id)
        .once()
        .then((snapshot) {
      snap = snapshot.value.toString();
    });
    List<String> snaps = snap.split("idNotif");
    cant = snaps.length - 1;
    
    print("ENTRYCHANGED CANT ES POR FIN $cant");
    setState(() {
      
    });
  }

  onEntryRemoved(Event event) async {
    
      String snap;
      await FirebaseDatabase.instance
        .reference()
        .child("NumNotif")
        .child(widget.user_.id)
        .once()
        .then((snapshot) {
      snap = snapshot.value.toString();
    });
    List<String> snaps = snap.split("idNotif");
    cant = snaps.length - 1;
    
    print("ENTRYCHANGED CANT ES POR FIN $cant");
    setState(() {
      
    });
  }

  onEntryAdded(Event event) async {
     
      String snap;
    await FirebaseDatabase.instance
        .reference()
        .child("NumNotif")
        .child(widget.user_.id)
        .once()
        .then((snapshot) {
      snap = snapshot.value.toString();
    });
    List<String> snaps = snap.split("idNotif");
    cant = snaps.length - 1;
    
    print("ENTRYADDED CANT ES POR FIN $cant");
    setState(() {
      
    });
  }

    onDeletedAdded(Event event) async {
     
      String snap;
    await FirebaseDatabase.instance
        .reference()
        .child("NumNotif")
        .child(widget.user_.id)
        .once()
        .then((snapshot) {
      snap = snapshot.value.toString();
    });
    List<String> snaps = snap.split("idNotif");
    cant = snaps.length - 1;
    
    print("ENTRYADDED CANT ES POR FIN $cant");
    setState(() {
      
    });
  }



  Future<int> obtenerNumNotif() async {
    int cant = 0;
    String snap;
    await FirebaseDatabase.instance
        .reference()
        .child("NumNotif")
        .child(widget.user_.id)
        .once()
        .then((snapshot) {
      snap = snapshot.value.toString();
    });
    List<String> snaps = snap.split("idNotif");
    cant = snaps.length - 1;
    return cant;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await showDialog(
        context: context,
        barrierDismissible: true, // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("¿Deseas cerrar sesión?"),
            actions: [
              FlatButton(
                child: const Text('SÍ'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: const Text('NO'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        },
      ),
      child: Scaffold(
        backgroundColor: kPrimaryLightColor,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: kPrimaryLightColor,
          iconTheme: IconThemeData(color: Colors.black87),
          elevation: 0,
          centerTitle: true,
          actions: <Widget>[
            Container(
              width: 40,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                title: Text(
                                  "Historial de Notificaciones",
                                  textAlign: TextAlign.center,
                                ),
                                content: ListNotifications(
                                  user_: widget.user_,
                                )));
                          Future<int> n = Future.value(0);  
                          setState(() {numNotif = n;});
                      },
                    ),
                  ),
                  
                        Container(
                          alignment: Alignment.topRight,
                          padding: EdgeInsets.only(top: 10, right: 4),
                          child: cant > 0 ? CircleAvatar(
                            child: Text(
                              cant.toString(),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 8),
                            ),
                            backgroundColor: Colors.red,
                            radius: 7,
                          ) : Container()
                        ),
                      
                  
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.replay_outlined,
                color: Colors.grey,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        //Home(uid: result.user.uid)
                        HomeScreen(user_: widget.user_),
                  ),
                );
              },
            ),
          ],
        ),
        body: RawScrollbar(
          isAlwaysShown: true,
          thumbColor: Colors.blueAccent.withOpacity(0.5),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "¡Hola!  ",
                      style: Theme.of(context)
                          .textTheme
                          .display1
                          .apply(color: Colors.grey[500]),
                    ),
                    Text(
                      widget.user_.Name ?? "",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .display1
                          .apply(color: darkBlue, fontWeightDelta: 2),
                    ),
                  ],
                ),
                Image.asset(
                  "assets/icons/juntas.png",
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.height * 0.3,
                ),
                SizedBox(
                  height: 15.0,
                ),
                Divider(),
                ListJuntas(
                  user_: widget.user_,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          margin: EdgeInsets.all(10),
          width: double.infinity,
          height: 60.0,
          child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Color.fromRGBO(0, 160, 227, 1))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateJunta(
                            user_: widget.user_,
                          )),
                );
              },
              padding: EdgeInsets.all(10.0),
              color: kPrimaryButtonColor,
              textColor: Color.fromRGBO(0, 160, 227, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_add, color: Colors.white, size: 40),
                  SizedBox(width: 15),
                  Text("Crear junta",
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ],
              )),
        ),
        drawer: NavigateDrawer(user: user, user_: widget.user_),
      ),
    );
  }
}

class NavigateDrawer extends StatefulWidget {
  FirebaseUser user;
  final User_ user_;
  String gender = null;
  NavigateDrawer({Key key, this.user, this.user_}) : super(key: key);
  @override
  _NavigateDrawerState createState() => _NavigateDrawerState();
}

class _NavigateDrawerState extends State<NavigateDrawer> {
  bool notificar = false;

  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: kPrimaryLightColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountEmail: Text(widget.user_.Email),
              accountName: Text(
                widget.user_.Name,
                style: TextStyle(fontSize: 20),
              ),
              decoration: BoxDecoration(
                color: kPrimaryColor,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage("assets/icons/juntas.png"),
              ),
            ),
            ListTile(
              leading: new IconButton(
                icon: new Icon(Icons.home, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
                /*Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListAddIntegrants()),
                );*/
              },
            ),
            ListTile(
              leading: new IconButton(
                  icon: new Icon(Icons.account_circle, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  }
                  /*onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DoctorsInfo(userId: widget.userId, auth: widget.auth, onSignedOut: widget.onSignedOut,doctor: doctor,)),
              ),*/
                  ),
              title: Text('Mi info'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text("Tu información"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Nombre ",
                                style: TextStyle(color: Colors.black54),
                              ),
                              Text(
                                "${widget.user_.name} ${widget.user_.apepat}",
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Teléfono ",
                                style: TextStyle(color: Colors.black54),
                              ),
                              Text(
                                widget.user_.Telefono,
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Email ",
                                style: TextStyle(color: Colors.black54),
                              ),
                              Text(
                                widget.user_.email,
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Fecha de Nacimiento ",
                                style: TextStyle(color: Colors.black54),
                              ),
                              Text(
                                widget.user_.fecha_nac,
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Documento ",
                                style: TextStyle(color: Colors.black54),
                              ),
                              Text(
                                widget.user_.tipdoc +
                                    "  " +
                                    widget.user_.numdoc,
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ));
              },
            ),
            ListTile(
              leading: new IconButton(
                  icon: new Icon(Icons.group_add, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateJunta(
                                user_: widget.user_,
                              )),
                    );
                  }
                  /*onPressed: () =>
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Contacts(uid:widget.userId,auth: widget.auth, onSignedOut: widget.onSignedOut)),
              ),*/
                  ),
              title: Text('Crear Junta'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateJunta(
                            user_: widget.user_,
                          )),
                );
              },
            ),
            ListTile(
              leading: new IconButton(
                  icon: new Icon(Icons.notifications, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateJunta(
                                user_: widget.user_,
                              )),
                    );
                  }),
              title: Text('Historial de Notificaciones'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                        title: Text("Historial de Notificaciones"),
                        content: ListNotifications(
                          user_: widget.user_,
                        )));
              },
            ),
            ListTile(
                leading: Checkbox(
                    value: this.widget.user_.notificar ?? false,
                    onChanged: (bool value) async {
                      setState(() {
                        this.widget.user_.notificar = value;
                      });
                      await FirebaseDatabase.instance
                          .reference()
                          .child("Users")
                          .child(widget.user_.id)
                          .update({
                        "notificar": widget.user_.notificar,
                      });
                    }),
                title: Container(
                    width: 150,
                    child: Text(
                      "Notificarme antes de ingresar a una junta",
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.fade,
                    ))),
            ListTile(
              leading: IconButton(
                icon: Icon(Icons.logout, color: Colors.red),
                onPressed: () {},
              ),
              title: Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async => await showDialog(
                context: context,
                barrierDismissible:
                    true, // user must tap button for close dialog!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("¿Deseas cerrar sesión?"),
                    actions: [
                      FlatButton(
                        child: const Text('SÍ'),
                        onPressed: () {
                          auth2.signOut().then((res) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WelcomeScreen()),
                                (Route<dynamic> route) => false);
                          });
                        },
                      ),
                      FlatButton(
                        child: const Text('NO'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
