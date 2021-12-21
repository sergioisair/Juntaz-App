import 'package:flutter/material.dart';
import 'package:firebase_authentication_tutorial/components/text_field_container.dart';
import 'package:firebase_authentication_tutorial/constants.dart';

class DropDownButton extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final List<String> list_type;
  const DropDownButton({
    Key key,
    this.onChanged,
    this.list_type,
  }) : super(key: key);

  @override
  _DropDownButton createState() => _DropDownButton();
}

class _DropDownButton extends State<DropDownButton> {

  String dropdownValue;
  void initState() {
    super.initState();
    dropdownValue= widget.list_type[0];
  }
  @override
  Widget build(BuildContext context) {

    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: widget.list_type
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}