import 'dart:io';

import 'package:flutter_shimmer/flutter_shimmer.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/exam_card.dart';
import 'package:kish2019/widget/lunch_menu.dart';
import 'package:device_info/device_info.dart';

void main() {
  runApp(Home());
}

class Home extends StatefulWidget {
  @override
  MainState createState() => MainState();
}

class MainState extends State<Home> {
  DateTime now = DateTime.now();
  String ddayLabel = "";
  String todayDate = "";
  List<Widget> launchCards = [];

  @override
  void initState() {
    super.initState();
    this.todayDate = new DateFormat('yyyy-MM-dd').format(now);
  }

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      print(iosDeviceInfo.identifierForVendor); // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      print(androidDeviceInfo.androidId + "이게 uuid"); // unique ID on Android
    }
  }

  void preserve() async{
  }

  @override
  Widget build(BuildContext context) {
    this.preserve();
    return MaterialApp(
      title: 'KISH',
      theme: ThemeData(
        textTheme: TextTheme(
          body1: TextStyle(color: Colors.grey[900]),
        ),
        fontFamily: 'NanumSquare',
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,

        body: SingleChildScrollView(
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
                                Text('오늘의 식단 / '+todayDate,
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
                          if(count > 1) return;

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
                                Text('시험 D-Day - '+ ddayLabel,
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
                        ddayLabel = data["label"] + "(" + data["date"] + ")";
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
        ),
        bottomNavigationBar: CupertinoTabBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text("Home")),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), title: Text("설정")),
          ],
          backgroundColor: Colors.grey[100],
        ),
      ),
    );
  }

  void reload() async{
    await Future.delayed(Duration(seconds: 1));
    setState(() {

    });
}

  void loading(BuildContext context){
    Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("TEST"),
          duration: Duration(seconds: 3),
        )
    );
  }
}
