import 'dart:math';

import 'package:firebase_authentication_tutorial/components/text_field_container.dart';
import 'package:firebase_authentication_tutorial/models/user_model.dart';
import 'package:firebase_authentication_tutorial/widgets/my_progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_authentication_tutorial/Screens/Login/components/background.dart';
import 'package:firebase_authentication_tutorial/Screens/Signup/signup_screen.dart';
import 'package:firebase_authentication_tutorial/components/already_have_an_account_acheck.dart';
import 'package:firebase_authentication_tutorial/components/rounded_button.dart';
import 'package:firebase_authentication_tutorial/components/rounded_input_field.dart';
import 'package:firebase_authentication_tutorial/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_authentication_tutorial/Screens/Home/home.dart';
import 'package:firebase_authentication_tutorial/Screens/Home/screens.dart';
import 'package:firebase_authentication_tutorial/models/model_app.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Body extends StatefulWidget {
  final App app;
  Body({this.app});
  @override
  State<StatefulWidget> createState() => new _Body();
}

class _Body extends State<Body> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  ProgressDialog _progressDialog;
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool checkRememberEmail = true;
  SharedPreferences prefs;

  @override
  void initState() {
    _progressDialog =
        MyProgressDialog.createProgressDialog(context, "Espere un momento...");
    initPref();
    super.initState();
  }

  initPref() async{
    prefs = await SharedPreferences.getInstance();
    emailController.text = prefs.getString('email');
    print(prefs.getString('email'));
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "INGRESAR",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              SvgPicture.asset(
                "assets/icons/login.svg",
                height: size.height * 0.3,
              ),
              SizedBox(height: size.height * 0.01),
              
              RoundedInputField(
                controller: emailController,
                hintText: "Email",
                /*onChanged: (value_email) {
                  emailController.text = value_email;
                },*/
              ),
              RoundedPasswordField(
                onChanged: (value_pass) {
                  passwordController.text = value_pass;
                },
              ),
              Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                flex: 8,
                child: Text(
                  "Recordar este correo",
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
              Checkbox(
                //activeColor: AppTheme.VERDE,
                value: checkRememberEmail,
                onChanged: (value) =>
                    setState(() => checkRememberEmail = value),
              ),
            ],
          ),
              SizedBox(height: size.height * 0.01),
              GestureDetector(
                child: Container(
                  child: Text(
                    "¿Olvidaste tu contraseña?",
                    style: TextStyle(color: Colors.black54),
                  ),
                  padding: EdgeInsets.all(5),
                ),
                onTap: () async {
                  TextEditingController resetEmail = TextEditingController();
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Restablece tu contraseña"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                "Ingresa tu correo electrónico registrado para restablecer tu contraseña"),
                            TextField(
                              controller: resetEmail,
                            )
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Atrás"),
                          ),
                          TextButton(
                            onPressed: () async =>
                                await sendResetPasswordLink(resetEmail.text),
                            child: Text("Enviar"),
                          )
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: size.height * 0.01),
              AlreadyHaveAnAccountCheck(
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
              SizedBox(height: size.height * 0.01),
              RoundedButton(
                text: "INGRESAR",
                press: () {
                  //print(emailController.text); print(passwordController.text);
                  _progressDialog.show();
                  loginWithJuntasAccount();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> sendResetPasswordLink(String email) async {
    if(email.length < 1) return null;
    ProgressDialog _progressDialog2;
    try {
      _progressDialog2 = MyProgressDialog.createProgressDialog(
          context, "Espere un momento...");
      _progressDialog2.show();
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _progressDialog2.hide();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                content: Text(
                    "Se te ha enviado un correo a $email para restablecer tu contraseña"),
                actions: [
                  TextButton(
                    child: Text("Aceptar"),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  )
                ]);
          });
      return null;
    } catch (e) {
      _progressDialog2.hide();
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                content: Text(e.toString().contains("ERROR_USER_NOT_FOUND")
                    ? "No se encontró ningún usuario registrado con ese correo"
                    : e.toString().contains("ERROR_INVALID_EMAIL")
                        ? "El Email que ingresaste es incorrecto"
                        : e.toString()),
                actions: [
                  TextButton(
                    child: Text("Aceptar"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ]);
          });
      _progressDialog2.hide();
    }
  }

  void mostrarDialogo(bool good, String title) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Row(
          children: [
            Icon(
              good ? Icons.check : Icons.error,
              color: good ? Colors.green : Colors.red,
            ),
            Text(
              "  $title",
              maxLines: 3,
            )
          ],
        ),
      ),
    );
    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(context);
  }

  void loginWithJuntasAccount() async {
    FirebaseAuth auth = FirebaseAuth.instance;

// Wait for the user to complete the reCAPTCHA & for an SMS code to be sent.
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((result) async {
      if(result.user.isEmailVerified == false) {
        _progressDialog.hide();
        isLoading = false;
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                content: Text(
                    "Aun no has verificado tu correo electrónico"),
                actions: [
                  TextButton(
                    child: Text("Entendido"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ]);
          });
          return;
      }
      isLoading = false;
      _progressDialog.hide();
      FirebaseUser user = null;
      final FirebaseAuth _auth = FirebaseAuth.instance;
      String uid;
      Query db = null;
      User_ user_ = new User_("NONE", "...", "...", "...", "Elegir", "...",
          "...", 0.00, null, "...", false);
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
              values["notificar"] as bool));
        });
      });

      print(
          " EN ANTES DE LOGIN:  USERID = ${user_.id} , USER@ = ${user_.email} , USERNAME = ${user_.name}");
      
      if(checkRememberEmail)
        prefs.setString("email", emailController.text);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              //Home(uid: result.user.uid)
              HomeScreen(user_: user_),
        ),
      );
    }).catchError((err) {
      print(err.message);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(err.message == "Given String is empty or null"
                  ? "No se han llenado los campos correctamente"
                  : err.message == "The email address is badly formatted."
                      ? "Formato de correo inválido"
                      : err.message.toString().contains("is no user record")
                          ? "Usuario o contraseña inválidos"
                          : err.message
                                  .toString()
                                  .contains("password is invalid")
                              ? "La contraseña es inválida o el usuario no tiene una contraseña"
                              : err.message),
              actions: [
                ElevatedButton(
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
