import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authentication_tutorial/models/user_model.dart';
import 'package:firebase_authentication_tutorial/models/junta_groups_list.dart';
import 'package:firebase_authentication_tutorial/models/junta_users_.dart';
import 'package:firebase_authentication_tutorial/models/Fields_Options.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/create_group_junta.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/juntas_home.dart';
import 'package:firebase_authentication_tutorial/constants.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:smart_calendar/controller/smart_calendar_controller.dart';
import 'package:smart_calendar/smart_calendar.dart';

class ListJuntas extends StatefulWidget {
  final User_ user_;
  ListJuntas({this.user_});
  @override
  State<StatefulWidget> createState() => new _ListJuntasState();
}

class _ListJuntasState extends State<ListJuntas> {
  //final FirebaseDatabase _database = FirebaseDatabase.instance;
  DatabaseReference _database = FirebaseDatabase.instance.reference();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<bool> _isOpen = [true, true];
  List<dynamic> aportesDays = [];

  var controller = SmartCalendarController(
    weekdayType: WeekDayType.medium,
    locale: 'es_MX',
    initialDate: DateTime.now(),
    lastDate: DateTime.utc(2053, 04, 31),
    eventDates: [],
    annualEvents: false,
    calendarType: CalendarType.civilCalendar,
  );

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;
  Query _todoQuery;
  List<Todo> _todoList;
  List<JuntaGroupsList> _JuntaGroupsList;
  JuntaGroupsList user_list = JuntaGroupsList("", "", "", "");
  /////////////////////////////
  Future<String> _future;
  DatabaseReference _ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  String uid;
  bool haveList = false;
  //bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    _future = fetchAllLocations();
    getCurrentUser();

    //_checkEmailVerification();
  }

  Future<String> fetchAllLocations() async {
    await Future.delayed(Duration(seconds: 5), () {});
    Future.value("test");
  }

  getCurrentUser() async {
    this.user = await _auth.currentUser();
    this.uid = user.uid;
    _todoList = new List();
    _JuntaGroupsList = new List();
    _todoQuery = _database.child("Juntas_Users/" + widget.user_.Id);
    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(onEntryChanged);
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

  onEntryAdded(Event event) {
     setState(() {
      _todoList.add(Todo.fromSnapshot(event.snapshot));
      var dbRef = FirebaseDatabase.instance
          .reference()
          .child("Juntas_Info")
          .orderByKey()
          .equalTo(_todoList[_todoList.length - 1].code)
          .once()
          .then(
        (DataSnapshot snapshot) {
          Map<dynamic, dynamic> values = snapshot.value;
          values.forEach((key, values)  {
            aportesDays.add(
              {
                "date": DateTime.now().year.toString() +
                    "-" +
                    (DateTime.now().month < 10
                        ? "0" + DateTime.now().month.toString()
                        : DateTime.now().month.toString()) +
                    "-" +
                    (values["pago_date"].toString().length < 2
                        ? "0" + values["pago_date"].toString()
                        : values["pago_date"].toString()),
                "description": "Dia de aporte",
                "title": "Dia de aporte"
              },
            );
            setState(
              () => _JuntaGroupsList.add(JuntaGroupsList(
                  _todoList[_todoList.length - 1].key,
                  values["name_junta"],
                  values["id_creator"],
                  values["create_date"])),
            );
          });
        },
      );
      controller = SmartCalendarController(
        weekdayType: WeekDayType.medium,
        locale: 'es_MX',
        initialDate: DateTime.now(),
        lastDate: DateTime.utc(2053, 04, 31),
        eventDates: aportesDays,
        annualEvents: false,
        calendarType: CalendarType.civilCalendar,
      );
      setState(() {
        
      });
    });
  }

  swap(int x, int y){
    JuntaGroupsList nuevoJunta = _JuntaGroupsList[x];
    Todo nuevoTodo = _todoList[x];
    _JuntaGroupsList[x] = _JuntaGroupsList[y];
    _todoList[x] = _todoList[y];
    _JuntaGroupsList[y] = nuevoJunta;
    _todoList[y] = nuevoTodo;
  }

  Widget showTodoList() {
    if (_JuntaGroupsList.length > 2)
      for (int j = 0; j < _JuntaGroupsList.length; j++)
      for (int i = 0; i < _JuntaGroupsList.length-1; i++) {
        int d1 = int.parse(_JuntaGroupsList[i].Create_date.substring(0, 2));
        int m1 = int.parse(_JuntaGroupsList[i].Create_date.substring(3, 5));
        int y1 = int.parse(_JuntaGroupsList[i].Create_date.substring(6, 10));

        int d2 = int.parse(_JuntaGroupsList[i+1].Create_date.substring(0, 2));
        int m2 = int.parse(_JuntaGroupsList[i+1].Create_date.substring(3, 5));
        int y2 = int.parse(_JuntaGroupsList[i+1].Create_date.substring(6, 10));

        if(y2 < y1){
          swap(i,i+1);
        }
        else if(y2 > y1){
          // NADA
        }
        else if(m2 < m1){
          swap(i,i+1);
        }
        else if(m2 > m1){
          // NADA
        }
        else if(d2 < d1){
          swap(i,i+1);
        }
        else if(d2 > d1){
          // NADA
        }
        else{

        }
          // NADA
      }
      int pos = 0;
      if (_JuntaGroupsList.length > 1)
      for (int j = 1; j < _JuntaGroupsList.length; j++)
      if(_JuntaGroupsList[j].Id_creator == widget.user_.Id){
        swap(pos,j);
        pos++;
      }

    if (_todoList.length > 0) {
      return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _todoList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _todoList[index].key;
            String code = _todoList[index].code;
            String name_junta = _todoList[index].name_junta;
            Color color = Colors.black45;
            if (_JuntaGroupsList[index].Id_creator == widget.user_.Id) {
              color = Colors.green;
            }
            return Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              child: Container(
                color: Colors.white,
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: Container(
                    padding: EdgeInsets.only(right: 12.0),
                    decoration: new BoxDecoration(
                        border: new Border(
                            right: new BorderSide(
                                width: 2.0, color: Colors.lightBlue))),
                    child: Icon(
                      Icons.group,
                      color: color,
                      size: 30,
                    ),
                  ),
                  title: Text(
                    _JuntaGroupsList[index]
                        .Name_junta //double.parse().toString(),
                    ,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  trailing: Text(
                    _JuntaGroupsList[index].Create_date.split(" ")[0],
                    style: TextStyle(fontSize: 20.0),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => JuntaHome(
                              user_: widget.user_,
                              code_junta: code,
                            )),
                  ),
                ),
              ),
              actions: <Widget>[
                IconSlideAction(
                  caption: 'Ingresar',
                  color: Colors.blue,
                  icon: Icons.input,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => JuntaHome(
                              user_: widget.user_,
                              code_junta: code,
                            )),
                  ),
                ),
              ],
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: 'Ingresar',
                  color: Colors.blue,
                  icon: Icons.input,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => JuntaHome(
                              user_: widget.user_,
                              code_junta: code,
                            )),
                  ),
                ),
              ],
            );
          });
    } else {
      return Center(
          child: Text(
        "No hay Juntas",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          ExpansionPanelList(
              elevation: 0,
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  isExpanded: _isOpen[0],
                  headerBuilder: (context, isOpen) {
                    return Container(
                      width: double.infinity,
                      height: 50.0,
                      child: Text("CALENDARIO DE PAGOS",
                          style: TextStyle(fontSize: 20)),
                      alignment: Alignment.center,
                    );
                  },
                  body: FutureBuilder(
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
                              return IgnorePointer(
                                child: SmartCalendar(
                                    controller: controller,
                                    customTitleWidget: Padding(
                                      padding: EdgeInsets.only(bottom: 20),
                                      child: Text(
                                        mostrarMes(DateTime.now().month),
                                        style: TextStyle(fontSize: 25),
                                      ),
                                    )),
                              );
                            }
                        }
                      }),
                ),
              ],
              expansionCallback: (i, isOpen) {
                setState(() {
                  _isOpen[0] = !isOpen;
                });
              }),
          Divider(),
          ExpansionPanelList(
              elevation: 0,
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  isExpanded: _isOpen[1],
                  headerBuilder: (context, isOpen) {
                    return Container(
                      width: double.infinity,
                      height: 50.0,
                      child: Text("MIS JUNTAS ACTIVAS",
                          style: TextStyle(fontSize: 20)),
                      alignment: Alignment.center,
                    );
                  },
                  body: FutureBuilder(
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
                ),
              ],
              expansionCallback: (i, isOpen) {
                setState(() {
                  _isOpen[1] = !isOpen;
                });
              }),
        ],
      ),
    );
  }

  /*final controller = SmartCalendarController(
    weekdayType: WeekDayType.medium,
    locale: 'es_MX',
    initialDate: DateTime.now(),
    lastDate: DateTime.utc(2053, 04, 31),
    eventDates: [],
    [
      {
        "date": "2021-09-09",
        "description": "This a holiday because of the Worker day",
        "title": "Worker Day"
      },
      {
        "date": "2021-09-01",
        "description": "This a holiday because of the Kids day",
        "title": "Kids Day"
      },
      {
        "date": "2021-09-17",
        "description": "This a holiday because of the hero day",
        "title": "Hero day"
      }
    ],
    annualEvents: false,
    calendarType: CalendarType.civilCalendar,
  );*/

  void choiceAction(String choice) {
    if (choice == Options.Todo) {
      getCurrentUser();
    } else if (choice == Options.Stadistic) {}
  }

  String mostrarMes(int mes) {
    if (mes == 1) return "Enero";
    if (mes == 2) return "Febrero";
    if (mes == 3) return "Marzo";
    if (mes == 4) return "Abril";
    if (mes == 5) return "Mayo";
    if (mes == 6) return "Junio";
    if (mes == 7) return "Julio";
    if (mes == 8) return "Agosto";
    if (mes == 9) return "Septiembre";
    if (mes == 10) return "Octubre";
    if (mes == 11) return "Noviembre";
    if (mes == 12) return "Diciembre";
    return "JUNTAS EN ESTE MES";
  }
}
