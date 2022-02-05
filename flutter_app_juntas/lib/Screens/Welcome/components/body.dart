import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authentication_tutorial/Screens/Home/screens.dart';
import 'package:firebase_authentication_tutorial/components/rounded_input_telef_field.dart';
import 'package:firebase_authentication_tutorial/components/text_field_container.dart';
import 'package:firebase_authentication_tutorial/models/user_model.dart';
import 'package:firebase_authentication_tutorial/widgets/my_progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_authentication_tutorial/Screens/Login/login_screen.dart';
import 'package:firebase_authentication_tutorial/Screens/Signup/signup_screen.dart';
import 'package:firebase_authentication_tutorial/Screens/Welcome/components/background.dart';
import 'package:firebase_authentication_tutorial/components/rounded_button.dart';
import 'package:firebase_authentication_tutorial/constants.dart';
import 'package:firebase_authentication_tutorial/Screens/Signup/components/or_divider.dart';
import 'package:firebase_authentication_tutorial/Screens/Signup/components/social_icon.dart';
import 'package:firebase_authentication_tutorial/models/model_app.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class Body extends StatefulWidget {
  final App app;
  Body({this.app});
  @override
  State<StatefulWidget> createState() => new _Body();
}

class _Body extends State<Body> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  ProgressDialog _progressDialog;
  GlobalKey<FormState> _key = new GlobalKey();
  bool tyc = false;
  bool pp = false;

  @override
  void initState() {
    super.initState();
    _progressDialog =
        MyProgressDialog.createProgressDialog(context, "Espere un momento...");
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width of our screen
    return Container(
      height: size.height,
      child: Background(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "BIENVENIDO A JUNTAZ",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                Text("APP DE PRUEBAS"),
                //SizedBox(height: size.height * 0.05),
                Image.asset(
                  //SvgPicture.asset
                  "assets/icons/juntas.png",
                  height: size.height * 0.35,
                ),
                RoundedButton(
                  text: "INGRESAR",
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginScreen();
                        },
                      ),
                    );
                  },
                ),
                RoundedButton(
                  text: "REGISTRARSE",
                  color: kPrimaryLightColor,
                  textColor: Colors.black,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SignUpScreen();
                        },
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.1,
                      vertical: size.height * 0.015),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MaterialButton(
                        onPressed: () => _loginWithGoogle(),
                        minWidth: size.width * 0.37,
                        height: size.height * 0.08,
                        color: Colors.red,
                        shape: StadiumBorder(),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.google, color: Colors.white),
                            Text(
                              "   Ingresar",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () => _loginWithFb(),
                        minWidth: size.width * 0.37,
                        height: size.height * 0.08,
                        color: Colors.blue[800],
                        shape: StadiumBorder(),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.facebook,
                                color: Colors.white),
                            Text(
                              "   Ingresar",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                OrDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SocalIcon(
                      iconSrc: "assets/icons/facebook.svg",
                      press: () => abrirRedSocial(
                          "https://fb.me/"), // ingresar URL de facebook
                    ),
                    /*SocalIcon(
                      iconSrc: "assets/icons/twitter.svg",
                      press: () => abrirRedSocial("https://www.twitter.com/"),
                    ),*/
                    SocalIcon(
                      iconSrc: "assets/icons/google.svg",
                      press: () => abrirRedSocial(
                          'mailto:rozvi2005@gmail.com?subject=JUNTAS APP&body=Buen%20día\n'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loginWithFb() async {
    _progressDialog.show();
    FacebookLogin fbLogin = new FacebookLogin();
    List<String> list_type = ['DNI', 'Pasaporte', 'Carnet Extranjería'];

    TextEditingController tipdocController = TextEditingController();
    TextEditingController numdocController = TextEditingController();
    TextEditingController fechaNacController = TextEditingController();
    TextEditingController telefonoController = TextEditingController();
    DateTime _dateTime;
    tipdocController.text = list_type[0];
    String selectedbd = "-";
    FirebaseUser user = null;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    String uid;
    Query db = null;
    User_ user_ = new User_("NONE", "...", "...", "...", "Elegir", "...", "...",
        0.00, null, "...", false, false);

    final result =
        await fbLogin.logIn(['email', 'public_profile']).then((result) {
      final AuthCredential oAuthCredential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token);
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          FirebaseAuth.instance
              .signInWithCredential(oAuthCredential)
              .then((signedInUser) async {
            if (signedInUser.additionalUserInfo.isNewUser) {
              await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => SingleChildScrollView(
                  child: WillPopScope(
                    onWillPop: () {},
                    child: AlertDialog(
                      title: Text("Completa tu perfil"),
                      content: Form(
                        key: _key,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Teléfono: "),
                            SizedBox(
                              height: 10,
                            ),
                            TextFieldContainer(
                              child: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: 'Ingresa aquí',
                                    icon: Icon(Icons.phone, color: Colors.grey),
                                  ),
                                  controller: telefonoController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  validator: validateMobile,
                                  onSaved: (String val) {
                                    telefonoController.text = val;
                                  }),
                            ),
                            Text("Fecha de Nacimiento: "),
                            SizedBox(
                              height: 10,
                            ),
                            ButtonTheme(
                              minWidth: MediaQuery.of(context).size.width,
                              height: 60.0,
                              splashColor: Colors.lightBlue[100],
                              buttonColor: Colors.white,
                              child: RaisedButton.icon(
                                label: Text(
                                  selectedbd,
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
                                    lastDate:
                                        DateTime.utc(DateTime.now().year - 17),
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
                            SizedBox(height: 15),
                            Text("Tipo de Documento:    "),
                            SizedBox(
                              height: 10,
                            ),
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
                            Text("Número de documento:    "),
                            SizedBox(
                              height: 10,
                            ),
                            RoundedInputTelefField(
                              icon: Icons.document_scanner,
                              hintText: "Ej. 12345678",
                              onChanged: (value_name) {
                                numdocController.text = value_name;
                              },
                              typedoc: tipdocController.text,
                            ),
                            Text("HOLA"),
                            Container(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: GestureDetector(
                                    onTap: () async {
                                      await canLaunch(
                                              "https://juntaz.com/tyc.html")
                                          ? launch(
                                              "https://juntaz.com/tyc.html")
                                          : false as Future<bool>;
                                    },
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: "Lee nuestros ",
                                            style:
                                                TextStyle(color: Colors.black)),
                                        TextSpan(
                                            text: "términos y condiciones",
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
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
                                  Expanded(
                                      child: GestureDetector(
                                    onTap: () async {
                                      await canLaunch(
                                              "https://juntaz.com/pdp.html")
                                          ? launch(
                                              "https://juntaz.com/pdp.html")
                                          : false as Future<bool>;
                                    },
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: "Lee nuestra ",
                                            style:
                                                TextStyle(color: Colors.black)),
                                        TextSpan(
                                            text: "Política de Privacidad",
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold))
                                      ]),
                                    ),
                                  ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              if (_key.currentState.validate())
                                Navigator.pop(context);
                            },
                            child: Text("Continuar"))
                      ],
                    ),
                  ),
                ),
              );
              DatabaseReference dbRef =
                  await FirebaseDatabase.instance.reference().child("Users");
              dbRef.child(signedInUser.user.uid).set({
                "email": signedInUser.user.email,
                "name": signedInUser.user.displayName,
                "apepat": "",
                "tipdoc": tipdocController.text,
                "numdoc": numdocController.text,
                "total_amount": "0.00",
                "fecha_nac": selectedbd,
                "telefono": telefonoController.text,
                "notificar": false,
                "validado": false
              }).then((res) async {
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
                        HomeScreen(user_: user_),
                  ),
                );
              });
            } else {
              user = await _auth.currentUser();
              uid = user.uid;
              db = FirebaseDatabase.instance
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
                      HomeScreen(user_: user_),
                ),
              );
            }
          }).catchError((e) {
            print(e);
          });

          break;
        default:
      }
    }).catchError((e) {
      print(e);
    });
    _progressDialog.hide();
  }

  static GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'phone',
    ],
  );

  Future<void> signInWithGoogle() async {
    _progressDialog.show();
    try {
      final account = await _googleSignIn.signIn();

      final googleAuth = await account.authentication;

      List<String> list_type = ['DNI', 'Pasaporte', 'Carnet Extranjería'];

      TextEditingController tipdocController = TextEditingController();
      TextEditingController numdocController = TextEditingController();
      TextEditingController fechaNacController = TextEditingController();
      TextEditingController telefonoController = TextEditingController();
      DateTime _dateTime;
      tipdocController.text = list_type[0];
      String selectedbd = "-";
      FirebaseUser user = null;
      final FirebaseAuth _auth = FirebaseAuth.instance;
      String uid;
      Query db = null;
      User_ user_ = new User_("NONE", "...", "...", "...", "Elegir", "...",
          "...", 0.00, null, "...", false, false);

      final AuthCredential oAuthCredential = GoogleAuthProvider.getCredential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      print(account);

      firebaseAuth.signInWithCredential(oAuthCredential).then((result) async {
        // SI ES REGISTRO
        if (result.additionalUserInfo.isNewUser) {
          await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => SingleChildScrollView(
              child: WillPopScope(
                onWillPop: () {},
                child: AlertDialog(
                  title: Text("Completa tu perfil"),
                  content: Form(
                    key: _key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Teléfono: "),
                        SizedBox(
                          height: 10,
                        ),
                        TextFieldContainer(
                          child: TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Ingresa aquí',
                                icon: Icon(Icons.phone, color: Colors.grey),
                              ),
                              controller: telefonoController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              validator: validateMobile,
                              onSaved: (String val) {
                                telefonoController.text = val;
                              }),
                        ),
                        Text("Fecha de Nacimiento: "),
                        SizedBox(
                          height: 10,
                        ),
                        ButtonTheme(
                          minWidth: MediaQuery.of(context).size.width,
                          height: 60.0,
                          splashColor: Colors.lightBlue[100],
                          buttonColor: Colors.white,
                          child: RaisedButton.icon(
                            label: Text(
                              selectedbd,
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
                                lastDate:
                                    DateTime.utc(DateTime.now().year - 17),
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
                        SizedBox(height: 15),
                        Text("Tipo de Documento:    "),
                        SizedBox(
                          height: 10,
                        ),
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
                        Text("Número de documento:    "),
                        SizedBox(
                          height: 10,
                        ),
                        RoundedInputTelefField(
                          icon: Icons.document_scanner,
                          hintText: "Ej. 12345678",
                          onChanged: (value_name) {
                            numdocController.text = value_name;
                          },
                          typedoc: tipdocController.text,
                        ),
                        Container(
                          width: double.infinity,
                          child: Row(
                            children: [
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
                                        text: "Lee nuestros ",
                                        style: TextStyle(color: Colors.black)),
                                    TextSpan(
                                        text: "términos y condiciones",
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
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
                                        text: "Lee nuestra ",
                                        style: TextStyle(color: Colors.black)),
                                    TextSpan(
                                        text: "Política de Privacidad",
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold))
                                  ]),
                                ),
                              ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          if (_key.currentState.validate())
                            Navigator.pop(context);
                        },
                        child: Text("Continuar"))
                  ],
                ),
              ),
            ),
          );
          DatabaseReference dbRef =
              await FirebaseDatabase.instance.reference().child("Users");
          dbRef.child(result.user.uid).set({
            "email": account.email,
            "name": account.displayName,
            "apepat": "",
            "tipdoc": tipdocController.text,
            "numdoc": numdocController.text,
            "total_amount": "0.00",
            "fecha_nac": selectedbd,
            "telefono": telefonoController.text,
            "notificar": false,
            "validado": false
          }).then((res) async {
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
                    HomeScreen(user_: user_),
              ),
            );
          });
        } else {
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
                  HomeScreen(user_: user_),
            ),
          );
        }
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
      /*
      final userCredential = await firebaseAuth
          .signInWithCredential(oAuthCredential)
          .then((result) {});
      FirebaseUser user = userCredential.user;
      String uid;
      uid = user.uid;
      Query db = null;
      User_ user_ = new User_("NONE", "...", "...", "...", "Elegir", "...",
          "...", 0.00, null, "...");
      db = FirebaseDatabase.instance
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
              values["telefono"]));
        });
      });
      print(
          " EN ANTES DE LOGIN:  USERID = ${user_.id} , USER@ = ${user_.email} , USERNAME = ${user_.name}");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => //Home(uid: result.user.uid)
              HomeScreen( user_: user_),
        ),
      );*/
    } catch (error) {
      print("Error en Google Sign In");
      print(error);
    }
    _progressDialog.hide();
  }

  void _loginWithGoogle() async {
    await signInWithGoogle();
  }

  abrirRedSocial(String url) async {
    await canLaunch(url)
        ? launch(url)
        : print("No se pudo abrir la aplicación");
  }

  String validateMobile(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Campo Requerido";
    } else if (!regExp.hasMatch(value)) {
      return "Sólo puede contener dígitos";
    } else if (value.length < 9) {
      return "El número debe ser de 9 cifras";
    }
    return null;
  }
}
