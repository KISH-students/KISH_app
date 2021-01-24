import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomOutlinedCard extends StatelessWidget {
  String description;
  Color color;
  Widget child;

  CustomOutlinedCard({this.color = Colors.redAccent, this.child}) {
    if (this.child == null) this.child = new Column();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(width: 0.5, color: color)),
        child: child);
  }
}
