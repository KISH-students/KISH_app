import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kish2019/widget/custom_outlined_card.dart';

class DDayCard extends StatelessWidget {
  static const Color grey = const Color(0xFF4B515D);
  /*
  static const Color red = const Color(0xFFfc5151);
  static const Color orange = const Color(0xFFffba2f);
  static const Color green = const Color(0xFF00C851);
  */

  String description;
  Color? color;
  int? timestamp;

  String ddayText = ":/";

  DDayCard({
    this.timestamp: 0,
    this.description: "",
    this.color: grey,
    String? content
  }) {
    if (timestamp != null && timestamp!.isNaN == false) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
      DateTime now = DateTime.now();
      int diffDays = date.difference(now).inDays;

      /*if (diffDays > 45) {
        color = green;
      } else if (diffDays > 25) {
        color = orange;
      } else {
        color = red;
      }*/

      if (content == null) {
        if (date.month == now.month && date.day == now.day) {
          ddayText = "D - DAY";
        } else {
          ddayText = "D - " + (diffDays + 1).toString();
        }
      } else {
        ddayText = content;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            color: Color(0xff101021),
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(width: 0.5, color: color!)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _DdayText(this.ddayText),
            Text(description,
              style: TextStyle(color: Colors.white70),)
          ],
        ));
  }
}

class _DdayText extends StatelessWidget {
  final content;
  const _DdayText(this.content, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: TextStyle(
        color: Colors.white,
        fontSize: 50,
        fontFamily: 'NanumSquare',
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
