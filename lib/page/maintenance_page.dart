import 'package:flutter/material.dart';

class MaintenancePage extends StatelessWidget {
  late String title;
  late String des;

  MaintenancePage({title: "COMMING\nSOON", description: ""}) {
    this.title = title;
    this.des = description;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 35),
          ),
          Text(des,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'NanumSquare',
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}
