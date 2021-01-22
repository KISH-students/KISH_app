import 'package:flutter/material.dart';

class ExamCard extends StatefulWidget{
  static Color grey = new Color(0xFF4B515D);
  static Color red = new Color(0xFFfc5151);
  static Color orange = new Color(0xFFffba2f);
  static Color green = new Color(0xFF00C851);

  Color nowColor;
  Widget custom;

  ExamCard(bool useCustomWidget, {Widget widget, String content: "", Color color, num timestamp}){
    if(color == null){
      nowColor = grey;
      if(!useCustomWidget && timestamp != null && !timestamp.isNaN) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        DateTime now = DateTime.now();
        int diffDays = date
            .difference(now)
            .inDays;

        if (diffDays > 45) nowColor = green;
        else if(diffDays > 25) nowColor = orange;
        else nowColor = red;


        if(content == "") {
          if(date.day == now.day) setDefWidget("D - DAY");
          else setDefWidget("D - " + (diffDays + 1).toString());
        }
      }
    }else nowColor = color;

    if(useCustomWidget) custom = widget;
    else if(content != "") setDefWidget(content);
  }

  void setDefWidget(String content){
    custom = Text(content,
      style: TextStyle(
          color: Colors.white,
          fontSize: 50,
          fontFamily: 'NanumSquareB'),);
  }

  @override
  State<StatefulWidget> createState() {
    return new _ExamCard();
  }
}

class _ExamCard extends State<ExamCard>{

  @override
  Widget build(BuildContext context) {
    return
      Container(
          padding: EdgeInsets.only(top:20,bottom: 25,right: 25.0, left: 25.0),
          child: Column(children: [
            Container(
              height: 170,
              width: double.infinity,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 15),
                    color: widget.nowColor.withOpacity(.6),
                    spreadRadius: -15)
              ]),

              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                //elevation: 10.0,
                color: widget.nowColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                        child: widget.custom)
                  ],
                ),
              ),
            ),
            //)
          ]));
  }

}
