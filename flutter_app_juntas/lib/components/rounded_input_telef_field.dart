import 'package:flutter/material.dart';
import 'package:firebase_authentication_tutorial/components/text_field_container.dart';
import 'package:firebase_authentication_tutorial/constants.dart';

class RoundedInputTelefField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final typedoc;
  const RoundedInputTelefField({
    Key key,
    this.hintText,
    this.icon = Icons.person,
    this.onChanged,
    this.typedoc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var length_doc=8;
    if(typedoc=="DNI"){
      length_doc=8;
    }else if(typedoc=="Pasaporte"){
      length_doc=9;
    }else if(typedoc=="Carnet Extranjería"){
      length_doc=9;
    }
    return TextFieldContainer(

      child: TextField(
        onChanged: onChanged,
        maxLengthEnforced: true,
        keyboardType: TextInputType.number,
        maxLength: length_doc,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(

          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
  String validateMobile(String value) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return 'Please enter mobile number';
    }
    else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }
}
