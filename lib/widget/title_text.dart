import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  static const double size1 = 35;
  static const double size2 = 30;
  static const double size3 = 25;

  final double size;
  final double top;
  final String data;

  const TitleText(this.data, {this.size = size1, this.top = 120.0});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: top, left: 17),
        child: Text(data, style: TextStyle(fontSize: size)));
  }
}
