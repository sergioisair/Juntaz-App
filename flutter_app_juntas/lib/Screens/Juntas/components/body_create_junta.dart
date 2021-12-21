import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_authentication_tutorial/Screens/Signup/components/background.dart';
import 'package:firebase_authentication_tutorial/components/rounded_button.dart';
import 'package:firebase_authentication_tutorial/components/text_field_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:firebase_authentication_tutorial/models/user_model.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/juntas_home.dart';

import 'package:firebase_authentication_tutorial/constants.dart';
import 'package:flutter/cupertino.dart';

List<Item> listaUsers = [];

class BodyCreateJunta extends StatefulWidget {
  final User_ user_;
  BodyCreateJunta({this.user_});

  @override
  State<StatefulWidget> createState() => new _BodyCreateJunta();
}

class _BodyCreateJunta extends State<BodyCreateJunta> {
  bool isLoading = false;
  Random random = new Random();
  int code_junta;
  String code_junta_final;
  //final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  DatabaseReference dbRef1 = FirebaseDatabase.instance.reference();
  //var vales_t = ['Moneda: Soles','Moneda: Dólares'];
  List<String> list_type = ['Tipo de Moneda: Soles', 'Tipo de Moneda: Dólares'];
  List<String> type_junta = [
    'Tipo de Junta: Mensual',
    'Tipo de Junta: Quincenal',
    'Tipo de Junta: Semanal'
  ];
  List<String> dias_semana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];



  int valueDiasSemana;
  int valueDiasMensual = 14;
  List<String> dias_mensual = [
    '15  y  30',
    '1  y  16',
    '2  y  17',
    '3  y  18',
    '4  y  19',
    '5  y  20',
    '6  y  21',
    '7  y  22',
    '8  y  23',
    '9  y  24',
    '10  y  25',
    '11  y  26',
    '12  y  27',
    '13  y  28',
    '14  y  29',
  ];

  var cod_group = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'];
  TextEditingController nameJuntaController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController apepatController = TextEditingController();
  TextEditingController apematController = TextEditingController();
  TextEditingController tipMonedaController = TextEditingController();
  TextEditingController typeJuntaController = TextEditingController();
  TextEditingController aporteController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController fechaAporteController = TextEditingController();
  TextEditingController fechaPagoController = TextEditingController();

  int numPend;

  List<Item> AddIntegrants = List();
  Item item;
  DatabaseReference itemRef;
  TextEditingController controller = new TextEditingController();
  String filter = null;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    print("test user   " + widget.user_.Email);
    numPend = 0;
    valueDiasSemana = 0;
    valueDiasMensual = 0;
    listaUsers = [];
    listaUsers
        .add(Item(widget.user_.email, "Tú", false, widget.user_.telefono));
    listaUsers[0].key = widget.user_.id;
    code_junta = random.nextInt(9000) + 1000;
    tipMonedaController.text = list_type[0];
    typeJuntaController.text = type_junta[0];
    code_junta_final =
        cod_group[random.nextInt(cod_group.length) + 1] + code_junta.toString();

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

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: new Container(
          margin: new EdgeInsets.all(15.0),
          child: new Form(
            key: _key,
            autovalidate: _validate,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Crear Junta",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: size.height * 0.03),
                  FormUI(),
                  listaDeUsers(),
                  RoundedButton(
                    text: "Crear Junta",
                    press: () {
                      /*if(typeJuntaController.text != type_junta[0])
                        showDialog(context: context, builder: (BuildContext context) { 
                          return AlertDialog(title: Text("Aun no están disponibles las juntas quincenales ni semanalas, por favor, elige mensual"),);
                         }, );
                      else*/
                      _sendToServer();
                    },
                  ),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget botonAgregarMiembros() {
    return Container(
      margin: EdgeInsets.all(10),
      height: 50.0,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Color.fromRGBO(0, 160, 227, 1))),
        onPressed: () async {
          /*await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ListAddIntegrants(
                      junta_code: code_junta_final,
                    )),
          );*/
          setState(() {});
        },
        padding: EdgeInsets.all(10.0),
        color: Colors.white,
        textColor: Color.fromRGBO(0, 160, 227, 1),
        child: Text("Agregar a Miembros", style: TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget listaDeUsers() {
    return Container(
      alignment: Alignment.bottomLeft,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: kPrimaryLightColor,
        borderRadius: BorderRadius.circular(29),
      ),
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(top: 5),
              width: double.infinity,
              child: Text(
                "Miembros del grupo",
                style: TextStyle(color: Colors.black54, fontSize: 20),
                textAlign: TextAlign.center,
              )),
          listaUsers.length == 0
              ? Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  width: double.infinity,
                  child: Text(
                    "Aún no has ingresado ningún miembro",
                    style: TextStyle(color: Colors.black38),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < listaUsers.length; i++)
                      Column(
                        children: [
                          Divider(),
                          ListTile(
                            leading: CircleAvatar(
                              child: Text((i + 1).toString()),
                            ),
                            title: Text(listaUsers[i].name, maxLines: 1),
                            subtitle: Text(
                              listaUsers[i].form,
                              style: TextStyle(fontSize: 10),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                i < listaUsers.length - 1
                                    ? IconButton(
                                        onPressed: () {
                                          Item nuevo = listaUsers[i];
                                          listaUsers[i] = listaUsers[i + 1];
                                          listaUsers[i + 1] = nuevo;
                                          setState(() {});
                                        },
                                        icon: Icon(
                                            Icons.arrow_downward_outlined,
                                            size: 30))
                                    : Container(),
                                i > 0
                                    ? IconButton(
                                        onPressed: () {
                                          Item nuevo = listaUsers[i];
                                          listaUsers[i] = listaUsers[i - 1];
                                          listaUsers[i - 1] = nuevo;
                                          setState(() {});
                                        },
                                        icon: Icon(Icons.arrow_upward_outlined,
                                            size: 30))
                                    : Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
          listAddIntegrants(
            code_junta_final,
          ),
          //botonAgregarMiembros()
        ],
      ),
    );
  }

  Widget FormUI() {
    return new Column(
      children: <Widget>[
        new TextFieldContainer(
          child: TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.person),
              hintText: 'Ingrese Nombre de Junta',
            ),
            maxLength: 15,
            validator: validateName,
            onSaved: (String val) {
              nameJuntaController.text = val;
            },
          ),
        ),
        new Center(
          child: DropdownButton(
            hint: Text('Tipo de Moneda'), // Not necessary for Option 1
            value: tipMonedaController.text,
            onChanged: (newValue) {
              setState(() {
                tipMonedaController.text = newValue;
              });
            },
            items: list_type.map((location) {
              return DropdownMenuItem(
                child: new Text(location),
                value: location,
              );
            }).toList(),
          ),
        ),
        new TextFieldContainer(
          child: TextFormField(
              decoration: const InputDecoration(
                icon: const Icon(FontAwesomeIcons.coins),
                hintText: 'Cuota ej (20)',
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              validator: validateAporte,
              onSaved: (String val) {
                aporteController.text = val;
              }),
        ),
        new Center(
          child: DropdownButton(
            hint: Text('Tipo de Junta'), // Not necessary for Option 1
            value: typeJuntaController.text,
            onChanged: (newValue) {
              setState(() {
                typeJuntaController.text = newValue;
              });
            },
            items: type_junta.map((location) {
              return DropdownMenuItem(
                child: new Text(location),
                value: location,
              );
            }).toList(),
          ),
        ),
        typeJuntaController.text == type_junta[0]
            ? Column(
                children: [
                  new TextFieldContainer(
                    child: TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.calendar_today),
                          hintText: 'Día de pagar cuota: ej 10',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        validator: validateDay,
                        onSaved: (String val) {
                          fechaAporteController.text = val;
                        }),
                  ),
                  /*new TextFieldContainer(
                    child: TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.calendar_today),
                          hintText: 'Día de Recibo: ej 10',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        validator: validateDay,
                        onSaved: (String val) {
                          fechaPagoController.text = val;
                        }),
                  ),*/
                ],
              )
            : typeJuntaController.text == type_junta[1]
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Días de Pago:  "),
                      Container(
                        alignment: Alignment.center,
                        height: 200,
                        width: 100,
                        child: CupertinoPicker(
                          looping: true,
                          itemExtent: 30,
                          onSelectedItemChanged: (int value2) {
                            valueDiasMensual = value2;
                            setState(() {});
                          },
                          children: List.from(dias_mensual.map((e) => Container(
                              alignment: Alignment.center, child: Text(e)))),
                        ),
                      ),
                      Text("de cada mes"),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Día de Pago:  "),
                      Container(
                        alignment: Alignment.center,
                        height: 200,
                        width: 150,
                        child: CupertinoPicker(
                          itemExtent: 30,
                          onSelectedItemChanged: (int value) {
                            valueDiasSemana = value;
                            setState(() {});
                          },
                          children: List.from(dias_semana.map((e) => Container(
                              width: 200,
                              alignment: Alignment.center,
                              child: Text(e)))),
                        ),
                      ),
                    ],
                  )
      ],
    );
  }

  String validateName(String value) {
    String patttern = r"(\w+)";
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "El nombre es obligatorio";
    } else if (!regExp.hasMatch(value)) {
      return "Name must be a-z and A-Z";
    }
    return null;
  }

  String validateAporte(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Este campo es requerido";
    } else if (!regExp.hasMatch(value)) {
      return "Debe ser una cifra numérica";
    }
    return null;
  }

  String validateDay(String value) {
    String patttern = '[0-9]*[1-9]';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Este Campo es obligatorio";
    } else if (!regExp.hasMatch(value)) {
      return "Día no Válido";
    } else if (int.parse(value) > 31) {
      return "Día Excedido";
    } else if (int.parse(value) == 31) {
      return "El día máximo es 30";
    }
    return null;
  }

  _sendToServer() {
    if (_key.currentState.validate()) {
      // No any error in validation
      _key.currentState.save();

      if (listaUsers.length < 2) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("No puedes crear juntas con un solo integrante"),
                actions: [
                  TextButton(
                    child: Text("Aceptar"),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              );
            });
      } else
        registerToFb();
    } else {
      // validation error
      setState(() {
        _validate = true;
      });
    }
  }

  void registerToFb() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    print(formattedDate.toString());

    addIntegrants(
        code_junta_final,
        nameJuntaController.text[0].toUpperCase() +
            nameJuntaController.text.substring(1));
    
    int fechaAporte;
    int fechaRecibo;
    String tipoJunta;
    DateTime today = DateTime.now();
    if (typeJuntaController.text == type_junta[0]) {
      tipoJunta = "Mensual";
      fechaAporte = int.tryParse(fechaAporteController.text);
      fechaRecibo = DateTime.utc(today.year, today.month, fechaAporte)
          .add(Duration(days: 1))
          .day;
    } else if (typeJuntaController.text == type_junta[1]) {
      tipoJunta = "Quincenal";
      if(today.day <= 14){
        if(today.day < int.parse(dias_mensual[valueDiasMensual].split("  ")[0]) )
          fechaAporte = int.parse(dias_mensual[valueDiasMensual].split("  ")[0]);
        else fechaAporte = int.parse(dias_mensual[valueDiasMensual].split("  ")[2]);
      }
      else {
        if(today.day < int.parse(dias_mensual[valueDiasMensual].split("  ")[2]) )
          fechaAporte = int.parse(dias_mensual[valueDiasMensual].split("  ")[2]);
        else fechaAporte = int.parse(dias_mensual[valueDiasMensual].split("  ")[0]);
      }
      
      today.day < fechaAporte ? fechaAporte = int.parse(dias_mensual[valueDiasMensual].split("  ")[2])
          : fechaAporte = int.parse(dias_mensual[valueDiasMensual].split("  ")[0]);
      fechaAporte == 30
          ? fechaRecibo = DateTime.utc(today.year, today.month, fechaAporte)
              .add(Duration(days: 1))
              .day
          : fechaRecibo = fechaAporte + 1;
    } else if (typeJuntaController.text == type_junta[2]) {
      tipoJunta = "Semanal";
      var diahoy = today;
      while(diahoy.weekday != valueDiasSemana+1){
        diahoy = diahoy.add(Duration(days: 1));
      }
      fechaAporte = diahoy.day;
      fechaRecibo = diahoy.add(Duration(days: 1)).day;
    }

    Map<String, String> junta_info = {
      'name_junta': nameJuntaController.text[0].toUpperCase() +
          nameJuntaController.text.substring(1),
      "coin_type": tipMonedaController.text,
      "id_creator": widget.user_.Id,
      "creator_email": widget.user_.Email,
      "aporte": aporteController.text.split(".")[0],
      "creator_phone": widget.user_.telefono,
      "creator_name": widget.user_.Name,
      "total_amount": "0.00",
      'code': code_junta_final,
      'create_date': formattedDate.toString(),
      "aporte_day": fechaAporte.toString(),
      "pago_date": fechaRecibo.toString(),
      "turno": "0",
      "pendientes": numPend.toString(),
      "type_junta": tipoJunta
    };
    dbRef1
        .child("Juntas_Info")
        .child(code_junta_final)
        .set(junta_info)
        .then((value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => //Home(uid: result.user.uid)
              JuntaHome(
            user_: widget.user_,
            code_junta: code_junta_final,
          ),
        ),
      );
    }).catchError((err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(err.message),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
    
  }

  addIntegrants(String codeJunta, String nombreJunta) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy  kk:mm').format(now);
    DatabaseReference dbRef1 = FirebaseDatabase.instance.reference();

    for (int i = 0; i < listaUsers.length; i++) {
      // SI ERES TÚ
      if (listaUsers[i].key == widget.user_.id) {
        Map<String, String> junta_users = {
          'code': code_junta_final,
          'name_junta': nameJuntaController.text,
          'rol_junta': "1",
          'listo': "1"
        };
        Map<String, String> junta_integrants = {
          "integrant_email": widget.user_.Email,
          'rol_junta': "1",
          "state_pay": "0",
          "name": widget.user_.name,
          'turno': i.toString(),
          'listo': "1"
        };

        dbRef1
            .child("Juntas_Users")
            .child(listaUsers[i].key)
            .child(code_junta_final)
            .set(junta_users);
        dbRef1
            .child("Juntas_Integrants")
            .child(code_junta_final)
            .child(listaUsers[i].key)
            .set(junta_integrants);
      }
      // SI ES UN MIEMBRO
      else {
        if (listaUsers[i].notif == true) {
          final num = random.nextInt(9000) + 1000;
          final code_notif =
              cod_group[random.nextInt(cod_group.length) + 1] + num.toString();
          numPend++;
          Map<String, String> notification = {
            'date_notif': DateTime.now().toString(),
            'info':
                "Has sido invitado a la junta '$nombreJunta', ¿deseas aceptar?",
            'type': "invite",
            "idJunta": codeJunta,
            "idNotif": code_notif
          };
          FirebaseDatabase.instance
              .reference()
              .child("Notifications")
              .child(listaUsers[i].key)
              .child(code_notif)
              .set(notification);
          FirebaseDatabase.instance
              .reference()
              .child("NumNotif")
              .child(listaUsers[i].key)
              .child(code_notif)
              .set(notification);
        }
        String estaListo = "1";
        if (listaUsers[i].notif == true) estaListo = "0";
        Map<String, String> junta_integrants = {
          "integrant_email": listaUsers[i].form,
          "state_pay": "0",
          'rol_junta': "0",
          "name": listaUsers[i].name,
          'turno': i.toString(),
          'listo': estaListo
        };
        Map<String, String> junta_users = {
          'code': code_junta_final,
          'rol_junta': "0",
          'listo': estaListo
        };
        dbRef1
            .child("Juntas_Users")
            .child(listaUsers[i].key)
            .child(code_junta_final)
            .set(junta_users);
        dbRef1
            .child("Juntas_Integrants")
            .child(code_junta_final)
            .child(listaUsers[i].key)
            .set(junta_integrants);
      }
    }
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

  Widget listAddIntegrants(String junta_code) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        children: <Widget>[
          SizedBox(height: 20),
          new Container(
              width: 300,
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    labelText: 'Buscar Personas',
                    hintText: 'Buscar Personas',
                    prefixIcon: Icon(Icons.search)),
                controller: controller,
                autofocus: false,
              )),
          if (controller.text != "")
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Resultados de búsqueda"),
            ),
          Container(
            height: controller.text == ""
                ? 0
                : (AddIntegrants.where((element) =>
                            element.form.contains(filter) ||
                            element.name.contains(filter)).length)
                        .toDouble() *
                    65,
            child: FirebaseAnimatedList(
              physics: BouncingScrollPhysics(),
              query: itemRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                if (filter == "" || filter == null) {
                  return new Container();
                } else {
                  return AddIntegrants[index].name.contains(filter) ||
                          AddIntegrants[index].form.contains(filter)
                      ? Container(
                          height: 65,
                          child: ListTile(
                            onTap: () async {
                              final ConfirmAction action =
                                  await _asyncConfirmDialog(
                                      context, AddIntegrants[index].name);
                              if (action == ConfirmAction.ACCEPT) {
                                //_saveInputs(AddIntegrants[index]);
                                if (listaUsers.any((user) =>
                                    user.key == AddIntegrants[index].key)) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                          title: Text("No se agregó"),
                                          content: Text(
                                              "Este usuario ya se encuentra en la junta"),
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
                                } else {
                                  listaUsers.add(AddIntegrants[index]);
                                  setState(() {});
                                  controller.text = "";
                                }
                              }
                            },
                            leading: Icon(Icons.person_add, size: 40),
                            title: Text(AddIntegrants[index].name),
                            subtitle: Text(AddIntegrants[index].form),
                          ),
                        )
                      : new SizedBox(
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
}

Future _asyncConfirmDialog(BuildContext context, String name) async {
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
              Navigator.of(context).pop(ConfirmAction.ACCEPT);
            },
          ),
        ],
      );
    },
  );
}

class Item {
  String key;
  String form;
  String name;
  bool notif;
  String phone;

  Item(this.form, this.name, this.notif, this.phone);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        form = snapshot.value["email"],
        name = snapshot.value["name"],
        notif = snapshot.value["notificar"] as bool,
        phone = snapshot.value["phone"];

  toJson() {
    return {"email": form, "name": name, "notificar": notif, "phone": phone};
  }
}

enum ConfirmAction { CANCEL, ACCEPT }
