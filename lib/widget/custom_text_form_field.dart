import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextFromField extends StatelessWidget {
  final TextEditingController controller;
  final bool isPassword;
  final String labelText;
  final IconData icon;

  CustomTextFromField(this.controller,
      {Key? key,
        this.labelText = "",
        this.icon = CupertinoIcons.app,
        this.isPassword = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
        child: TextFormField(
            key: UniqueKey(),
            controller: this.controller,
            style: TextStyle(color: Colors.white),
            enableSuggestions: !this.isPassword,
            autocorrect: !this.isPassword,
            obscureText: this.isPassword,
            obscuringCharacter: "*",
            decoration: InputDecoration(
                icon: Icon(icon, color: Colors.white54),
                fillColor: Colors.blueAccent,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF4DD0E1)),
                    borderRadius: BorderRadius.all(Radius.circular(30.0))
                ),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                    borderRadius: BorderRadius.all(Radius.circular(30.0))
                ),
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                labelText: this.labelText)
        )
    );
  }
}
