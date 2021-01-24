import 'package:flutter/material.dart';

class DescriptionText extends StatelessWidget {
  String data;
  EdgeInsets margin;

  DescriptionText(String data,
      {this.margin = const EdgeInsets.only(top: 20, left: 25)}) {
    this.data = data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Text(data,
          style: TextStyle(
              fontSize: 13,
              fontFamily: 'NanumSquareL',
              fontWeight: FontWeight.bold,
              color: Colors.black87)),
    );
  }
}
