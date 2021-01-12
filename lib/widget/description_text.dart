import 'package:flutter/material.dart';

class DescriptionText extends StatelessWidget {
  String data;

  DescriptionText(String data){
    this.data = data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20.0, left: 25),
      child:
      Text(data,
          style: TextStyle(
              fontSize: 13,
              fontFamily: 'NanumSquareB',
              color: Colors.black87)),
    );
    return null;
  }
}
