import 'dart:math';

import 'package:firebase_authentication_tutorial/components/rounded_confirm_password.dart';
import 'package:firebase_authentication_tutorial/models/user_model.dart';
import 'package:firebase_authentication_tutorial/widgets/my_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_authentication_tutorial/Screens/Login/login_screen.dart';
import 'package:firebase_authentication_tutorial/Screens/Signup/components/background.dart';
import 'package:firebase_authentication_tutorial/components/text_field_container.dart';
import 'package:firebase_authentication_tutorial/Screens/Signup/components/or_divider.dart';
import 'package:firebase_authentication_tutorial/Screens/Signup/components/social_icon.dart';
import 'package:firebase_authentication_tutorial/components/already_have_an_account_acheck.dart';
import 'package:firebase_authentication_tutorial/components/rounded_button.dart';
import 'package:firebase_authentication_tutorial/components/rounded_input_field.dart';
import 'package:firebase_authentication_tutorial/components/rounded_input_name_field.dart';
import 'package:firebase_authentication_tutorial/components/rounded_input_telef_field.dart';
import 'package:firebase_authentication_tutorial/components/rounded_password_field.dart';
import 'package:firebase_authentication_tutorial/components/dropdown_button_filed.dart';
import 'package:firebase_authentication_tutorial/Screens/Home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_authentication_tutorial/models/model_app.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:url_launcher/url_launcher.dart';

class Body extends StatefulWidget {
  final App app;
  Body({this.app});
  @override
  State<StatefulWidget> createState() => new _Body();
}

class _Body extends State<Body> {
  bool isLoading = false;
  ProgressDialog _progressDialog;
  //final _formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("Users");
  DateTime _dateTime;
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String name, email, mobile;
  String selectedbd = "-";
  bool _passwordVisible;
  List<String> list_type = ['DNI', 'Pasaporte', 'Carnet Extranjería'];
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController apeController = TextEditingController();
  TextEditingController tipdocController = TextEditingController();
  TextEditingController numdocController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController fechaNacController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  @override
  @override
  void initState() {
    super.initState();
    _progressDialog =
        MyProgressDialog.createProgressDialog(context, "Espere un momento...");
    tipdocController.text = list_type[0];
    //dbRef2 =    FirebaseDatabase.instance.reference().child("Juntas_Participant").child(widget.user_.Email.toString());
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SafeArea(
        child: SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.all(15.0),
            child: new Form(
              key: _key,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "REGISTRARSE",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                    SizedBox(height: size.height * 0.03),
                    SvgPicture.asset(
                      "assets/icons/signup.svg",
                      height: size.height * 0.35,
                    ),
                    formUI(),
                    SizedBox(height: size.height * 0.01),
                    ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width,
                      height: 60.0,
                      splashColor: Colors.lightBlue[100],
                      buttonColor: Colors.white,
                      child: RaisedButton.icon(
                        label: Text(
                          '\tFecha de Nacimiento: \t       ' + selectedbd,
                          style: TextStyle(color: Colors.black54),
                        ),
                        icon: Icon(
                          Icons.calendar_today,
                          color: Colors.blue,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            locale: Locale('es', 'MX'),
                            initialDate: _dateTime == null
                                ? DateTime.utc(DateTime.now().year - 17)
                                : _dateTime,
                            firstDate: DateTime(1920),
                            lastDate: DateTime.utc(DateTime.now().year - 17),
                          ).then((date) {
                            setState(() {
                              _dateTime = date;
                              selectedbd = _dateTime.day.toString() +
                                  "/" +
                                  _dateTime.month.toString() +
                                  "/" +
                                  _dateTime.year.toString();
                            });
                          });
                        },
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Tipo de Documento:    "),
                        Center(
                          child: DropdownButton(
                            hint: Text(
                                'Tipo de Documento'), // Not necessary for Option 1
                            value: tipdocController.text,
                            onChanged: (newValue) {
                              setState(() {
                                tipdocController.text = newValue;
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
                      ],
                    ),
                    RoundedInputTelefField(
                      hintText: "Número de Documento",
                      onChanged: (value_name) {
                        numdocController.text = value_name;
                      },
                      typedoc: tipdocController.text,
                    ),
                    SizedBox(height: size.height * 0.01),
                    RoundedPasswordField(
                      onChanged: (value_pass) {
                        passwordController.text = value_pass;
                      },
                    ),
                    RoundedConfirmPasswordField(
                      onChanged: (value_pass) {
                        confirmPasswordController.text = value_pass;
                      },
                    ),
                    Container(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Checkbox(
                              value: tyc,
                              onChanged: (check) {
                                tyc = check;
                                setState(() {});
                              }),
                          Expanded(
                              child: GestureDetector(
                            onTap: () async {
                              await canLaunch("https://juntaz.com/tyc.html")
                                  ? launch("https://juntaz.com/tyc.html")
                                  : false as Future<bool>;
                            },
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: "He leído y acepto los ",
                                    style: TextStyle(color: Colors.black)),
                                TextSpan(
                                    text: "términos y condiciones",
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold))
                              ]),
                            ),
                          ))
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Checkbox(
                              value: pp,
                              onChanged: (check) {
                                pp = check;
                                setState(() {});
                              }),
                          Expanded(
                              child: GestureDetector(
                            onTap: () async {
                              await canLaunch("https://juntaz.com/pdp.html")
                                  ? launch("https://juntaz.com/pdp.html")
                                  : false as Future<bool>;
                            },
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: "He leído y acepto nuestra ",
                                    style: TextStyle(color: Colors.black)),
                                TextSpan(
                                    text: "Política de Privacidad",
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold))
                              ]),
                            ),
                          ))
                        ],
                      ),
                    ),
                    RoundedButton(
                      text: "REGISTRARSE",
                      press: () {
                        _sendToServer();

                        print("tipo doc: " + tipdocController.text);
                      },
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget formUI() {
    return new Column(
      children: <Widget>[
        new TextFieldContainer(
          child: TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.person),
              hintText: 'Nombre',
            ),
            maxLength: 20,
            validator: validateName,
            onSaved: (String val) {
              nameController.text = val;
            },
          ),
        ),
        new TextFieldContainer(
          child: TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.person),
              hintText: 'Apellidos',
            ),
            maxLength: 40,
            validator: validateName,
            onSaved: (String val) {
              apeController.text = val;
            },
          ),
        ),
        new TextFieldContainer(
          child: TextFormField(
              decoration: const InputDecoration(
                icon: const Icon(Icons.email),
                hintText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              maxLength: 32,
              validator: validateEmail,
              onSaved: (String val) {
                emailController.text = val;
              }),
        ),
        new TextFieldContainer(
          child: TextFormField(
              decoration: const InputDecoration(
                icon: const Icon(Icons.phone),
                hintText: 'Teléfono',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 9,
              validator: validateMobile,
              onSaved: (String val) {
                telefonoController.text = val;
              }),
        ),
      ],
    );
  }

  bool tyc = false;
  bool pp = false;

  String validateName(String value) {
    String patttern =
        r'^[a-zA-ZÀ-ÿ\u00f1\u00d1]+(\s*[a-zA-ZÀ-ÿ\u00f1\u00d1]*)*[a-zA-ZÀ-ÿ\u00f1\u00d1]+$';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Campo Requerido";
    } else if (!regExp.hasMatch(value)) {
      return "Campo de ser entre a-z y A-Z";
    }
    return null;
  }

  String validatePasswords(String value) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }

  String validateMobile(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Campo Requerido";
    } else if (!regExp.hasMatch(value)) {
      return "Sólo debe contener dígitos";
    } else if (value.length < 9) {
      return "El número debe ser de 9 cifras";
    }
    return null;
  }

  String validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Campo Requerido";
    } else if (!regExp.hasMatch(value)) {
      return "Email inválido";
    } else {
      return null;
    }
  }

  _sendToServer() {
    if (!pp || !tyc) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("AVISO"),
            content: Text(
                "Por favor, confirma que has leído y aceptas nuestros Términos y Condiciones y nuestra Política de Privacidad."),
          );
        },
      );
    } else if (_key.currentState.validate()) {
      // No any error in validation
      _key.currentState.save();
      print("Name $name");
      print("Mobile $mobile");
      print("Email $email");
      if (passwordController.text == confirmPasswordController.text) {
        registerWithJuntasAccount();
        //confirmCode();
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text("Las contraseñas no coinciden"),
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
      }
    } else {
      setState(() {
        _validate = true;
      });
    }
  }

  void registerWithJuntasAccount() async {
    _progressDialog.show();
    firebaseAuth
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((result) async {
      await result.user.sendEmailVerification();
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(
                "Se te ha enviado un correo de a tu email, ingresa a él para verificar tu cuenta- (Recomendación: Si no ves tu correo, revisa en correos no deseados)"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Entendido"),
              )
            ],
          );
        },
      );
      await dbRef.child(result.user.uid).set({
        "email": emailController.text,
        "name": nameController.text,
        "apepat": apeController.text,
        "tipdoc": tipdocController.text,
        "numdoc": numdocController.text,
        "total_amount": "0.00",
        "fecha_nac": selectedbd,
        "telefono": telefonoController.text,
        "notificar": true,
        "validado": false
      }).then((res) async {
        isLoading = false;
        _progressDialog.hide();
        FirebaseUser user = null;
        final FirebaseAuth _auth = FirebaseAuth.instance;
        String uid;
        Query db = null;
        User_ user_ = new User_("NONE", "...", "...", "...", "Elegir", "...",
            "...", 0.00, null, "...", false, false);
        user = await _auth.currentUser();
        uid = user.uid;
        db = await FirebaseDatabase.instance
            .reference()
            .child("Users")
            .orderByKey()
            .equalTo(user.uid.toString());
        await db.once().then((DataSnapshot snapshot) {
          //name_user=snapshot.value['name'];
          Map<dynamic, dynamic> values = snapshot.value;
          values.forEach((key, values) {
            setState(() => user_ = new User_(
                user.uid.toString(),
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
                values["validado"] as bool));
          });
        });

        print(
            " EN ANTES DE LOGIN:  USERID = ${user_.id} , USER@ = ${user_.email} , USERNAME = ${user_.name}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => //Home(uid: result.user.uid)
                LoginScreen(),
          ),
        );
      });
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
                    _progressDialog.hide();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }
}
