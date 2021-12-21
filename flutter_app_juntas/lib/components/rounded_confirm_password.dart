import 'package:flutter/material.dart';
import 'package:firebase_authentication_tutorial/components/text_field_container.dart';
import 'package:firebase_authentication_tutorial/constants.dart';
class RoundedConfirmPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const RoundedConfirmPasswordField({
    Key key,
    this.onChanged,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => new _RoundedConfirmPasswordFieldState();
}
class _RoundedConfirmPasswordFieldState extends State<RoundedConfirmPasswordField> {
//class RoundedPasswordField extends StatelessWidget {
  bool _passwordVisible;
  @override
  void initState() {
    _passwordVisible = true;
  }

  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: _passwordVisible,
        onChanged: widget.onChanged,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          hintText: "Confirmar contraseña",
          icon: Icon(
            Icons.lock,
            color: kPrimaryColor,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              // Based on passwordVisible state choose the icon
              _passwordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Theme.of(context).primaryColorDark,
            ),
            onPressed: () {
              // Update the state i.e. toogle the state of passwordVisible variable
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
