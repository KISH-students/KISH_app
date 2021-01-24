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
  Color iconColor;
  IconData icon;

  DetailedCard({this.title = "", this.bottomTitle = "",
    this.descriptionColor = Colors.black, this.description = "", this.content = "",
    this.icon = Icons.title, this.iconColor = Colors.blueAccent,
    this.contentTextStyle = const TextStyle(color: Colors.black)});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      CustomOutlinedCard(
        color: Colors.black87,
        child: Container(
          padding: EdgeInsets.only(left: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    this.icon,
                    size: 25,
                    color: iconColor,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(" " + title,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontFamily: "KOTRA")),
                          Text(description,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontFamily: "NanumSquareR",
                                color: descriptionColor
                            ),),
                          Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text(this.content, style: contentTextStyle,))
                        ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      DescriptionText(bottomTitle, margin: EdgeInsets.only(left: 25, top: 5),),
    ]);
  }
}
