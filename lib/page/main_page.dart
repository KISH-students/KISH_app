import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:intl/intl.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/exam_card.dart';
import 'package:kish2019/widget/lunch_menu.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);
  String ddayLabel = "";
  String todayDate = "";

  @override
  _MainPageState createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    widget.todayDate = new DateFormat('yyyy-MM-dd').format(DateTime.now());
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
          Container(
            margin: const EdgeInsets.only(top: 120.0, left: 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('오늘의 식단을\n확인하세요', style: TextStyle(fontSize: 35)),
                //MyGetHttpData(),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 17),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20.0, left: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('오늘의 식단 / ' + widget.todayDate,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'NanumSquareB',
                                    color: Colors.black87)),

                          ],

                        ),
                      ),
                      //MyGetHttpData(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 280.0,
            child:
            FutureBuilder(
                future: ApiHelper.getLunch(),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    List<Widget> menuWidget = [];
                    List result = snapshot.data;

                    DateTime tmpDate = DateTime.now();
                    DateTime today = DateTime(tmpDate.year, tmpDate.month, tmpDate.day);
                    int timestamp = (today.millisecondsSinceEpoch / 1000).round();
                    int count = 0;
                    //print("our : " + today.millisecondsSinceEpoch.toString());

                    result.forEach((element) {
                      if(count > 4) return;

                      Map data = element;
                      /*print("-------");
                          print(data["timestamp"] * 1000);
                          print(DateTime.fromMillisecondsSinceEpoch(data["timestamp"] * 1000).toString());*/
                      if(timestamp <= data["timestamp"]){
                        menuWidget.add(LunchMenu(
                            menu: data["menu"],
                            detail: data["date"]));
                        count++;
                      }
                    });

                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: menuWidget,
                    );
                  }else if(snapshot.hasError){
                    return ExamCard(false, color: Colors.redAccent, content: "불러올 수 없음",);
                  }
                  return YoutubeShimmer();
                }
            ),
          ), //식단 container

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 17),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20.0, left: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('시험 D-Day - '+ widget.ddayLabel,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'NanumSquareB',
                                    color: Colors.black87)),
                          ],
                        ),
                      ),
                      //MyGetHttpData(),
                    ],
                  ),
                ),
              ),
              FutureBuilder(
                future: ApiHelper.getExamDDay(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    Map data = snapshot.data;

                    if(data["invalid"] != null) return new ExamCard(false, content: "정보 없음", color: ExamCard.grey,);
                    widget.ddayLabel = data["label"] + "(" + data["date"] + ")";
                    return new ExamCard(false, timestamp: data["timestamp"],);
                  }else if(snapshot.hasError){
                    return new ExamCard(false, content: "엥..", color: ExamCard.grey,);
                  }
                  return YoutubeShimmer();
                },
              ),
            ],
          ),

        ],
      ),
    );
  }
}