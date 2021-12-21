import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_authentication_tutorial/constants.dart';
//import 'package:firebase_authentication_tutorial/PacientHistory.dart';
//import 'package:firebase_authentication_tutorial/contacts.dart';
//import 'package:firebase_authentication_tutorial/doctor_info.dart';
//import 'package:firebase_authentication_tutorial/SearchPacientEmail.dart';
//import 'package:firebase_authentication_tutorial/test.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
//import 'package:firebase_authentication_tutorial/Firebase_Real_Time.dart';
//import 'package:firebase_authentication_tutorial/TimeSerieGraphic.dart';
import 'package:firebase_authentication_tutorial/global.dart';
import 'package:firebase_authentication_tutorial/models/tab_navigation_item.dart';
import 'package:firebase_authentication_tutorial/models/user_model.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/hello_page.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/list_transactions.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/pay_junta_page.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/detail_junta_page.dart';
import 'package:firebase_authentication_tutorial/Screens/Juntas/list_junta_users.dart';
import 'package:firebase_authentication_tutorial/models/junta_group_model.dart';
import 'package:firebase_authentication_tutorial/constants.dart';
//import 'package:firebase_authentication_tutorial/pages/SecondJuntaHomeContact.dart';
//import 'package:firebase_authentication_tutorial/pages/SecondJuntaHome.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
//import 'package:firebase_authentication_tutorial/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
class JuntaHome extends StatefulWidget {
  JuntaHome({this.user_,this.code_junta});
  final User_ user_;

  final String title = "Juntas";
  final String code_junta;
  _JuntaHomeState createState() => _JuntaHomeState();
}
class _JuntaHomeState extends State<JuntaHome> {
  Query ref;
  int _currentIndex = 0;
  int uniq=0;
  JuntaInfo junta_info = JuntaInfo("","","",0.0,"","",0.0,"","","","","","",null,null, "");

  void initState() {
    super.initState();
    getCurrentUser();
  }

  getCurrentUser() async {
    // Similarly we can get email as well
    //final uemail = user.email;
    final  db = await FirebaseDatabase.instance.reference().child("Juntas_Info").orderByKey().equalTo(widget.code_junta.toString());
    print("#####");
    updateProfile(db);
  }
  void updateProfile(Query db) {
    print("code: "+ widget.code_junta);
    print("nombre db: "+db.path.toString());
    db.once().then((DataSnapshot snapshot){
      //name_user=snapshot.value['name'];
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key,values) {
        //print("nombre: "+values["name"]);
        //name_user=values["name"].toString();
        //doctor = new Doctor(values[widget.uid], values["name"], values["surname"], values["age"], values["sex"], values["email"], values["speciality"],values["bio"],values["phone"]);
        //print("test "+doctor.Name.toString());
        /*values[widget.uid]??"";
        values["name"]??"";
        values["surname"]??"";
        values["age"]??"";
        values["sex"]??"";
        values["email"]??"";
        values["speclity"]??"";
        values["bio"]??"";
        values["phone"]??"";*/
        setState(() => junta_info = new JuntaInfo(key, values["name_junta"], widget.code_junta.toString(),double.parse(values["aporte"]), values["aporte_day"], values["pago_date"], double.parse(values["total_amount"]), values["creator_email"],values["creator_phone"],values["create_date"],values["creator_name"],values["id_creator"],values["coin_type"],int.parse(values["turno"]),int.parse(values["pendientes"]), values["type_junta"]));
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    //Future.delayed(Duration.zero, () => showAlert(context));
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          for (final tabItem in TabNavigationItem.items)
            if(tabItem.index==3) ListTransactions(user_: widget.user_,junta_info: junta_info,junta_code: widget.code_junta,) //            userId: _userId, auth: widget.auth, onSignedOut: _onSignedOut,
            else if(tabItem.index==2) ListJuntaUsers(user_: widget.user_,junta_info: junta_info,junta_code: widget.code_junta,)
            else if(tabItem.index==1) PayJunta(user_: widget.user_,junta_info: junta_info,junta_code: widget.code_junta,)
            else if(tabItem.index==0) DetailJunta(user_: widget.user_,junta_info: junta_info,),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: kPrimaryLightColor,
        color: kPrimaryColor,
        buttonBackgroundColor: kPrimaryLightColor,
        height: 60,
        animationDuration: Duration(
          milliseconds: 200,
        ),
        index: 0,
        animationCurve: Curves.bounceInOut,
        items: <Widget>[
          Icon(Icons.description, size: 30, color: darkBlue),
          Icon(Icons.contact_mail, size: 30, color: darkBlue),
          Icon(Icons.payment, size: 30, color: darkBlue),
          Icon(Icons.history, size: 30, color: darkBlue),
        ],
        onTap: (int index) => setState(() => _currentIndex = index),

      ),
      /*      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (int index) => setState(() => _currentIndex = index),
        items: <BottomNavigationBarItem>[
          for (final tabItem in TabNavigationItem.items)
            BottomNavigationBarItem(
              icon: tabItem.icon,
              title: tabItem.title,
            ),
        ],
      ),*/
      /*
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.white,
          color: Colors.blue,
          buttonBackgroundColor: Colors.blue,
          height: 60,
          animationDuration: Duration(
            milliseconds: 200,
          ),
          index: 0,
          animationCurve: Curves.bounceInOut,
          items: <Widget>[
            Icon(Icons.JuntaHome, size: 30, color: Colors.white),
            Icon(Icons.blur_circular, size: 30, color: Colors.red),
            Icon(Icons.blur_circular, size: 30, color: Colors.green),
            Icon(Icons.blur_circular, size: 30, color: Colors.yellow),

          ],
          onTap: (index) {
            if(index==0){

            }
            if(index>0){
              print(index);
              JuntaHomeSearchPacientEmail(uid:this.uid,index: index);
            }
            //Handle button tap
          },
        ),*/
    );
  }
}
/*
class JuntaHome_Stage extends StatefulWidget{
  final String uid;
  JuntaHome_Stage({key key, this.uid}): super(key:key);
  @override
  _JuntaHome_StageState createState()=>_JuntaHome_StageState();
}
class _JuntaHome_StageState extends State<NavigateDrawer>{}*/

