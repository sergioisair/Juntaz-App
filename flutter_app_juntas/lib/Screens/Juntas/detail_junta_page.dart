import 'package:firebase_authentication_tutorial/global.dart';
import 'package:firebase_authentication_tutorial/styles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_authentication_tutorial/Screens/Welcome/welcome_screen.dart';
import 'package:firebase_authentication_tutorial/models/user_model.dart';
import 'package:firebase_authentication_tutorial/constants.dart';
import 'package:firebase_authentication_tutorial/models/junta_group_model.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/list_add_integrants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_authentication_tutorial/models/model_app.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

enum ConfirmAction { CANCEL, ACCEPT }

class DetailJunta extends StatefulWidget {
  //final App app;
  DetailJunta({this.user_, this.junta_info});
  JuntaInfo junta_info;
  final User_ user_;
  @override
  State<StatefulWidget> createState() => new _DetailJuntaState();
}

class _DetailJuntaState extends State<DetailJunta> {
  Query db = null;
  User_ user_ = new User_("NONE", "...", "...", "...", "Elegir", "...", null,
      0.00, null, null, false, false);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user = null;
  String uid;
  TextEditingController nameJunta = new TextEditingController();

  void initState() {
    super.initState();
    getCurrentUser();
  }

  getCurrentUser() async {
    this.user = await _auth.currentUser();
    this.uid = user.uid;
    // Similarly we can get email as well
    //final uemail = user.email;
    print("test uid: " + uid);
    print("test email: " + user.email);
    final db = FirebaseDatabase.instance
        .reference()
        .child("Users")
        .orderByKey()
        .equalTo(this.user.uid.toString());
    updateProfile(db);
  }

  void updateProfile(Query db) {
    db.once().then((DataSnapshot snapshot) {
      //name_user=snapshot.value['name'];

      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        setState(() => user_ = new User_(
            this.user.uid.toString(),
            values["name"],
            values["apepat"],
            values["apemat"],
            values["tipdoc"],
            values["numdoc"],
            values["email"],
            double.parse(values["total_amount"]),
            values["fecha_nac"],
            values["telefono"],
            values["notificar"] as bool,
            values["validado" as bool]));
      });
      print("user name: " + user_.Id);
    });
  }

  Widget mensajeACreador() {
    if (widget.junta_info.Id_creator != widget.user_.Id) {
      return Container(
        margin: EdgeInsets.all(10),
        width: 500,
        height: 50.0,
        alignment: Alignment.center,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Color.fromRGBO(0, 160, 227, 1))),
          padding: EdgeInsets.all(10.0),
          color: Colors.white,
          textColor: Color.fromRGBO(0, 160, 227, 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.whatsapp),
              Text("  Enviar mensaje al Admin", style: TextStyle(fontSize: 15)),
            ],
          ),
          onPressed: () async {
            String msj = "";
            String url =
                "whatsapp://send?phone=+51${widget.junta_info.creator_phone.trim()}&text=$msj";
            await canLaunch(url)
                ? launch(url)
                : print("No se pudo abrir whatsapp");
          },
        ),
      );
    } else {
      return SizedBox(
        height: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryLightColor,
      appBar: AppBar(
        backgroundColor: kPrimaryLightColor,
        title: new Text(widget.junta_info.Name_junta,
            style: TextStyle(color: kPrimaryColor)),
        iconTheme: IconThemeData(color: Colors.black87),
        elevation: 0,
        actions: [
          widget.junta_info.creator_name == user_.name
              ? IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      barrierDismissible:
                          true, // user must tap button for close dialog!
                      builder: (BuildContext context) {
                        nameJunta.text = widget.junta_info.name_junta;
                        return AlertDialog(
                          title: Text("Modificar nombre de junta"),
                          content: TextField(
                            controller: nameJunta,
                          ),
                          actions: [
                            FlatButton(
                              child: const Text('CANCELAR'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            FlatButton(
                              child: const Text('ACTUALIZAR'),
                              onPressed: () async {
                                // TODO: CAMBIAR NOMBRE EN LA BD
                                await FirebaseDatabase.instance
                                    .reference()
                                    .child(
                                        "Juntas_Info/${widget.junta_info.code}")
                                    .update({'name_junta': nameJunta.text});
                                widget.junta_info.name_junta = nameJunta.text;
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        );
                      },
                    );
                    setState(() {});
                  })
              : Container()
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "¡Hola!",
              style: ThemeStyles().display1.apply(color: Colors.grey[500]),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                widget.user_.Name ?? "",
                maxLines: 3,
                textAlign: TextAlign.center,
                style: ThemeStyles()
                    .display1
                    .apply(color: darkBlue, fontWeightDelta: 2),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Container(
              padding: EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Monto depositado actualmente",
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
                      Icon(Icons.payment_rounded, color: Colors.grey[300]),
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
                  /*Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: RaisedButton(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 11.0),
                          color: darkBlue,
                          onPressed: () async {
                            final ConfirmAction action = await _asyncConfirmDialog(context,"Código: ","Comparte este Código: ", widget.junta_info.Code);
                            print("Confirm Action $action" );
                          },
                          child: Text(
                            'Código',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(9.0),
                              side: BorderSide(color: Colors.white)),
                        ),
                      ),

                      Flexible(
                        child: RaisedButton(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 11.0),
                          color: lightBlue,
                          onPressed: () async {
                            final ConfirmAction action = await _asyncConfirmDialog(context,"Fecha de Pago: ","Día de Cada Mes: ", widget.junta_info.Aporte_day);
                            print("Confirm Action $action" );
                          },
                          child: Text(
                            'Fecha de Pago',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(9.0),
                              side: BorderSide(color: Colors.white)),
                        ),
                      ),
                      Flexible(
                        child: RaisedButton(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 11.0),
                          color: lightBlue,
                          onPressed: () async {
                            final ConfirmAction action = await _asyncConfirmDialog(context,"Fecha de Retiro: ","Día de Cada Mes: ", widget.junta_info.Pago_day);
                            print("Confirm Action $action" );
                          },
                          child: Text(
                            'Fecha de Retiro',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(9.0),
                              side: BorderSide(color: Colors.white)),
                        ),
                      ),
                    ],
                  )*/
                ],
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              "Detalles de Junta  " + widget.junta_info.Name_junta,
              style: ThemeStyles()
                  .title
                  .apply(color: darkBlue, fontWeightDelta: 2),
            ),
            Divider(
              height: 30,
            ),
            Row(
              children: <Widget>[
                Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.timer, color: Colors.grey[30]),
                          SizedBox(width: 5.0),
                          Text(
                            "Fecha de Creación: " +
                                widget.junta_info.create_date,
                            style: TextStyle(color: Colors.grey[30]),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.person, color: Colors.grey[30]),
                          SizedBox(width: 5.0),
                          Expanded(
                            child: Text(
                              "Creado por: " + widget.junta_info.Creator_name,
                              maxLines: 2,
                              style: TextStyle(color: Colors.grey[30]),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.email, color: Colors.grey[30]),
                          SizedBox(width: 5.0),
                          Expanded(
                            child: Text(
                              "Correo del Creador: " +
                                  widget.junta_info.Creator_email,
                              maxLines: 2,
                              style: TextStyle(color: Colors.grey[30]),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.phone, color: Colors.grey[30]),
                          SizedBox(width: 5.0),
                          Text(
                            "Teléfono del Creador: " +
                                widget.junta_info
                                    .creator_phone, // cambiar a telefono
                            style: TextStyle(color: Colors.grey[30]),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.date_range, color: Colors.grey[30]),
                          SizedBox(width: 5.0),
                          Text(
                            "Tipo de Pago: " +
                                widget
                                    .junta_info.tipoJunta, // cambiar a telefono
                            style: TextStyle(color: Colors.grey[30]),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.download_rounded, color: Colors.grey[30]),
                          SizedBox(width: 5.0),
                          Text(
                            "Próximo día de aporte: " +
                                "Día " +
                                widget.junta_info
                                    .aporte_day, // cambiar a telefono
                            style: TextStyle(color: Colors.grey[30]),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.payments_rounded, color: Colors.grey[30]),
                          SizedBox(width: 5.0),
                          Text(
                            "Próximo día de recibo: Día " +
                                widget
                                    .junta_info.pago_day, // cambiar a telefono
                            style: TextStyle(color: Colors.grey[30]),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            mensajeACreador()
          ],
        ),
      ),
    );
  }
}

Future _asyncConfirmDialog(BuildContext context, String text_input,
    String second_input, String date) async {
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(text_input),
        content: Text(second_input + date.toString()),
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
