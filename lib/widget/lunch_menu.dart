import 'dart:core';

import 'package:flutter/material.dart';

class LunchMenu extends StatefulWidget {
  final String menu;
  final String detail;

  LunchMenu({
    this.menu,
    this.detail = ""
});

  @override
  State<StatefulWidget> createState() {
    return new _LunchMenu();
  }

}

class _LunchMenu extends State<LunchMenu>{
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top:20,bottom: 25,left: 15.0, right: 15.0),
      height: 300,
      width: 200,
      decoration: BoxDecoration(  // 카드 그림자
          boxShadow: [
            BoxShadow(
                blurRadius: 30,
                offset: Offset(0, 9),
                color: Color.fromARGB(50, 105, 109, 110),
                spreadRadius: -15)
          ]),

      child: Card(  // 급식 카드 부분
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11.0),
        ),
        elevation: 0,
        color: Colors.white,

        child: Container(   // TODO : 필요 없을경우 Container 제거

          child : Column(     // 급식 메뉴 및 detail 표시용 Column
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10,left: 10, top : 30),

                child : FittedBox(
                  fit:BoxFit.fitWidth,

                  child : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(   // 급식 메뉴 부분
                        widget.menu,
                        style: TextStyle(
                            color: Color(0XFF6C6C6C),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NanumSquareR'),
                      ),
                      Container(    // detail 부분
                        margin: EdgeInsets.only(top: 20),
                        child : Text(
                          widget.detail,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontFamily: 'NanumSquare'),
                        ),
                      ),
                    ], ), ),
              ),

            ],
          ),
        ),
      ),
    );
  }

}