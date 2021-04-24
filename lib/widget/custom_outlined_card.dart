import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomOutlinedCard extends StatelessWidget {
  final Color borderColor;
  final Widget child;
  final double borderWidth;

  const CustomOutlinedCard({
    this.borderColor = Colors.redAccent,
    this.borderWidth = 0.5,
    this.child = const Text("")});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(width: borderWidth, color: borderColor)),
        child: child);
  }
}
