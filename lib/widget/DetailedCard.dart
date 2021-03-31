import 'package:flutter/material.dart';
import 'package:kish2019/widget/custom_outlined_card.dart';

import 'description_text.dart';

class DetailedCard extends StatelessWidget {
  String bottomTitle;
  String title;
  String description;
  String content;
  TextStyle contentTextStyle;
  Color descriptionColor;
  Widget icon;

  DetailedCard(
      {this.title = "",
        this.bottomTitle = "",
        this.descriptionColor = Colors.black,
        this.description = "",
        this.content = "",
        this.icon,
        this.contentTextStyle = const TextStyle(color: Color.fromARGB(255, 135, 135, 135))});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomOutlinedCard(
        borderColor: Color.fromARGB(85, 155, 155, 155),
        borderWidth: 1.5,
        child:  Container(
          padding: EdgeInsets.only(left: 20, top: 20),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        child: icon
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: TextStyle(
                                    color: Color.fromARGB(220, 43, 43, 43),
                                    fontSize: 20,
                                    fontFamily: "CRB")),
                            Text(
                              description,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontFamily: "NanumSquareR",
                                  color: descriptionColor),
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Text(
                                  this.content,
                                  style: contentTextStyle,
                                ))
                          ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      DescriptionText(
        bottomTitle,
        margin: EdgeInsets.only(left: 25, top: 5),
      ),
    ]);
  }
}
