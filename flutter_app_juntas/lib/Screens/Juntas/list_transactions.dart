//import 'package:firebase_authentication_tutorial/models/JuntaTransaction.dart';
import 'package:firebase_authentication_tutorial/models/Fields_Options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authentication_tutorial/models/user_model.dart';
import 'package:firebase_authentication_tutorial/models/junta_transaction_model.dart';
import 'package:firebase_authentication_tutorial/models/junta_group_model.dart';
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

class ListTransactions extends StatefulWidget {
  final User_ user_;
  final String junta_code;
  JuntaInfo junta_info;
  ListTransactions({this.user_, this.junta_info, this.junta_code});
  @override
  State<StatefulWidget> createState() => new _ListTransactionsState();
}

class _ListTransactionsState extends State<ListTransactions> {
  //final FirebaseDatabase _database = FirebaseDatabase.instance;
  DatabaseReference _database = FirebaseDatabase.instance.reference();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onJuntaTransactionAddedSubscription;
  StreamSubscription<Event> _onJuntaTransactionChangedSubscription;
  Query _JuntaTransactionQuery;
  List<JuntaTransaction> _JuntaTransactionList;
  Future<String> _future;
  DatabaseReference _ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  String uid;
  //bool _isEmailVerified = false;
  String simbol_coin = "";

  @override
  void initState() {
    super.initState();
    print("coint type 1122: " + widget.junta_info.Pago_day);
    //if(widget.junta_info.Coin_type=="Tipo de Moneda: Dólares")simbol_coin= "\$. ";
    //if(widget.junta_info.Coin_type=="Tipo de Moneda: Soles")simbol_coin=  "S/. ";
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
    _JuntaTransactionList = new List();
    _JuntaTransactionQuery =
        await _database.child("Juntas_Transactions/" + widget.junta_code);
    _onJuntaTransactionAddedSubscription =
        _JuntaTransactionQuery.onChildAdded.listen(onEntryAdded);
    _onJuntaTransactionChangedSubscription =
        _JuntaTransactionQuery.onChildChanged.listen(onEntryChanged);

    //if(widget.junta_info.Coin_type=="Tipo de Moneda: Dólares")simbol_coin= "\$. ";
    //if(widget.junta_info.Coin_type=="Tipo de Moneda: Soles")simbol_coin=  "S/. ";
  }

  @override
  void dispose() {
    _onJuntaTransactionAddedSubscription.cancel();
    _onJuntaTransactionChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = _JuntaTransactionList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _JuntaTransactionList[_JuntaTransactionList.indexOf(oldEntry)] =
          JuntaTransaction.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      print("tamano lista: " + _JuntaTransactionList.length.toString());
      _JuntaTransactionList.add(JuntaTransaction.fromSnapshot(event.snapshot));
    });
  }

  deleteJuntaTransaction(String JuntaTransactionId, int index) async {
    await _database
        .reference()
        .child("Juntas_Users/" + widget.user_.Id)
        .child(JuntaTransactionId)
        .remove()
        .then((_) {
      print("Delete $JuntaTransactionId successful");
      setState(() {
        _JuntaTransactionList.removeAt(index);
      });
    });
  }

  showAddJuntaTransactionDialog(BuildContext context) async {
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
                    //addNewJuntaTransaction(_textEditingController.text.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Widget showJuntaTransactionList() {
    if (_JuntaTransactionList.length > 0) {
      return Expanded(
        child: Scrollbar(
          isAlwaysShown: true,
          child: ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: _JuntaTransactionList.length,
              itemBuilder: (BuildContext context, int index) {
                String JuntaTransactionId = _JuntaTransactionList[index].key;
                String code = _JuntaTransactionList[
                        _JuntaTransactionList.length - index - 1]
                    .key;
                String aporte = _JuntaTransactionList[
                        _JuntaTransactionList.length - index - 1]
                    .aporte;
                String aporte_day = _JuntaTransactionList[
                        _JuntaTransactionList.length - index - 1]
                    .aporte_day;
                String last_name = _JuntaTransactionList[
                        _JuntaTransactionList.length - index - 1]
                    .last_name;
                String name_integrant = _JuntaTransactionList[
                        _JuntaTransactionList.length - index - 1]
                    .name_integrant;
                String state_pay = _JuntaTransactionList[
                        _JuntaTransactionList.length - index - 1]
                    .state_pay;
                Color color;
                String color_state = "";
                double ap = double.parse(aporte);
                aporte = ap.toStringAsFixed(0);
                print("index  " + state_pay);
                if (state_pay == "1") {
                  color = Colors.red;
                  color_state = "-";
                } else {
                  color = Colors.green;
                  color_state = "+";
                }
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
                        child: Icon(
                          Icons.person,
                          color: color,
                          size: 25,
                        ),
                      ),
                      title: Text(
                        //double.parse().toString(),
                        name_integrant + " " + last_name + " \n" + aporte_day,
                        style: TextStyle(fontSize: 15.0),
                      ),
                      trailing: Text(
                        color_state +
                            " " +
                            aporte +
                            " " +
                            widget.junta_info.Coin_type.split(" ")[
                                widget.junta_info.Coin_type.split(" ").length -
                                    1],
                        style: TextStyle(fontSize: 15.0, color: color),
                      ),
                      onTap: () async {
                        final ConfirmAction action =
                            await _asyncConfirmDialog(context, aporte_day);
                        print("Confirm Action $action");
                      },
                    ),
                  ),
                );
              }),
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: kPrimaryLightColor,
      appBar: AppBar(
        backgroundColor: kPrimaryLightColor,
        title: new Text("Historial de Junta",
            style: TextStyle(
              color: kPrimaryColor,
              fontSize: 22,
            )),
        iconTheme: IconThemeData(color: Colors.black87),
        elevation: 0,
      ),
      body: new Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: new Form(
            child: new Column(
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
                          text:
                              widget.junta_info.Total_amount.toStringAsFixed(0),
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
            new SizedBox(
              height: 20.0,
            ),
            showJuntaTransactionList()
          ],
        )),
      ),

      /*FutureBuilder(
            future: _future,
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

                    return showJuntaTransactionList();
                  }
              }
            }
        ),//showJuntaTransactionList(),*/
    );
  }
}

Future _asyncConfirmDialog(BuildContext context, String date) async {
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Fecha y hora de Aporte'),
        content: Text('Fue realizada: ' + date.toString()),
        actions: [
          FlatButton(
            child: const Text('OKEY'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.ACCEPT);
            },
          )
        ],
      );
    },
  );
}
