import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  static const double size1 = 35;
  static const double size2 = 30;
  static const double size3 = 25;

  double size;
  double top;
  String data;

  TitleText(String data, {size = size1, top = 120.0}) {
    this.data = data;
    this.top = top;
    this.size = size;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: top, left: 17),
        child: Text(data, style: TextStyle(fontSize: size)));
  }
}
