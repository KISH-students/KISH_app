import 'package:flutter/material.dart';

class DescriptionText extends StatelessWidget {
  final String data;
  final EdgeInsets margin;

  const DescriptionText(this.data,
      {this.margin = const EdgeInsets.only(top: 20, left: 25)});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Text(data,
          style: const TextStyle(
              fontSize: 13,
              fontFamily: 'NanumSquareL',
              fontWeight: FontWeight.bold,
              color: Colors.black87)),
    );
  }
}
