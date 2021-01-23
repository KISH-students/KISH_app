import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:intl/intl.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/description_text.dart';
import 'package:kish2019/widget/exam_card.dart';
import 'package:kish2019/widget/lunch_menu.dart';
import 'package:kish2019/widget/title_text.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  FutureBuilder lunchFutureBuilder;
  FutureBuilder examFutureBuilder;
  String todayDate;

  @override
  void initState() {
    super.initState();
    lunchFutureBuilder = FutureBuilder(
        future: ApiHelper.getLunch(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              List<Widget> menuWidget = [];
              List result = snapshot.data;

              DateTime tmpDate = DateTime.now();
              DateTime today = DateTime(
                  tmpDate.year, tmpDate.month, tmpDate.day);
              int timestamp = (today.millisecondsSinceEpoch / 1000)
                  .round();
              int count = 0;
              //print("our : " + today.millisecondsSinceEpoch.toString());

              result.forEach((element) {
                if (count > 4) return;

                Map data = element;
                /*print("-------");
                          print(data["timestamp"] * 1000);
                          print(DateTime.fromMillisecondsSinceEpoch(data["timestamp"] * 1000).toString());*/
                if (timestamp <= data["timestamp"]) {
                  menuWidget.add(LunchMenu(
                      menu: (data["menu"] as String).replaceAll(
                          ",", "\n"),
                      detail: data["date"]));
                  count++;
                }
              });

              return ListView(
                scrollDirection: Axis.horizontal,
                children: menuWidget,
              );
            } else if (snapshot.hasError) {
              return ExamCard(
                false, color: Colors.redAccent, content: "불러올 수 없음",);
            }
            return YoutubeShimmer();
          }else{
            return YoutubeShimmer();
          }
        }
    );

    examFutureBuilder = FutureBuilder(
      future: ApiHelper.getExamDDay(),
      builder: (context, snapshot) {
        List<Widget> list = [];
        Column column = new Column(children: list, crossAxisAlignment: CrossAxisAlignment.start,);

        if(snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            Map data = snapshot.data;

            if (data["invalid"] != null) {
              list.add(DescriptionText('D-Day - 정보 없음'));
              list.add(
                  new ExamCard(false, content: "정보 없음", color: ExamCard.grey));
              return column;
            }

            list.add(DescriptionText('D-Day - '+ data["label"] + "(" + data["date"] + ")"));
            list.add(new ExamCard(false, timestamp: data["timestamp"],));
            return column;

          } else if (snapshot.hasError) {
            list.add(DescriptionText('D-Day - 불러올 수 없음'));
            list.add(new ExamCard(false, content: "엥...", color: ExamCard.grey,));
            return column;
          }
        }
        list.add(DescriptionText('D-Day - 불러오는 중'));
        list.add(YoutubeShimmer());
        return column;
      },
    );
    todayDate = new DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleText('오늘의 식단을\n확인하세요'),
          DescriptionText('오늘의 식단 / ' + todayDate),
          Container(
              height: 280.0,
              child:lunchFutureBuilder
          ), //식단 container

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              examFutureBuilder,
            ],
          ),
        ],
      ),
    );
  }
}