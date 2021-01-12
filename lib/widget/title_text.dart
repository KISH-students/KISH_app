import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  static const double size1 = 35;
  static const double size2 = 30;
  static const double size3 = 25;

  double size;
  String data;

  TitleText(String data, {size = size1}){
    this.data = data;
    this.size = size;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 120.0, left: 17),
        child: Text(data,
            style: TextStyle(fontSize: size)
        )
    );
  }
}
