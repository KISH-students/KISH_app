import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kish2019/api_links.dart';
import 'package:kish2019/constants.dart';
import 'package:kish2019/data_manager.dart';
import 'package:like_button/like_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

DataManager dataManager;

void main() {
  dataManager = new DataManager();
  runApp(Home());
}

class Home extends StatefulWidget {
  @override
  MainState createState() => MainState();
}

class MainState extends State<Home> {
  final Color grey = new Color(0xFF4B515D);
  final Color red = new Color(0xFFfc5151);
  final Color orange = new Color(0xFFffba2f);
  final Color green = new Color(0xFF00C851);

  String examDDay = "불러오는 중"; // 시험 D-Day 카운트
  String examDate = ""; // 시험 날짜
  String grade = "high";  // 학년ID
  String selection = "";  // 학년

  DateTime now = DateTime.now();
  Color examDDayColor;

  String todayDate = "";

  Future<DataManager> initDataManager() async {
    return await dataManager.build();
  }

  @override
  void initState() {
    super.initState();

    this.preserve();
    this.examDDayColor = grey;
    this.todayDate = new DateFormat('yyyy-MM-dd').format(now);
  }

  void preserve() async{
    dataManager.preferences = await SharedPreferences.getInstance();

    this.loadGrade();
    this.loadDDAY ();
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          backgroundColor: Color(0xFFf9f9f9),
          elevation: 0.8,
          centerTitle: true,
          title:  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child : Text(this.selection, style: TextStyle(color: Colors.black87, fontFamily: 'NanumSquareB'),),
                padding: EdgeInsets.only(left: 15.0),
              ),
              PopupMenuButton(
                padding: EdgeInsets.only(right: 15.0),
                onSelected: onChangeGrade,
                //icon: Icon(Icons, color: Colors.lightBlueAccent),
                elevation: 3.2,
                onCanceled: () {
                  print('You have not chossed anything');
                },
                tooltip: 'This is tooltip',
                itemBuilder: (BuildContext context) {
                  return Constants.choices.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              )
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 40.0, left: 17),
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
                                Text('시험 D-Day'+examDate,
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
                                color: examDDayColor.withOpacity(.6),
                                spreadRadius: -15)
                          ]),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            //elevation: 10.0,
                            color: examDDayColor,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Center(
                                    child: Text(
                                      examDDay,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 50,
                                          fontFamily: 'NanumSquareB'),
                                    ))
                              ],
                            ),
                          ),
                        )
                        // )
                        //)
                      ]))
                ],
              ),
              Container(
                  padding: EdgeInsets.only(top:20,bottom: 25,right: 25.0, left: 25.0),
                  child: Column(children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            blurRadius: 18,
                            offset: Offset(0, 15),
                            color: examDDayColor.withOpacity(.6),
                            spreadRadius: -15)
                      ]),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        //elevation: 10.0,
                        color: examDDayColor,
                        child: Column(

                          children: <Widget>[
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children :<Widget>[ Center(
                                  child: Text(
                                    '감자햄볶음밥/김가루\n두부된장국\n계란후라이\n미니핫도그&케찹\n단무지\n김치\n요구르트',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontFamily: 'NanumSquareB'),
                                  )),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  '염도 0.7 / 876.3kcal',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'NanumSquareB'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    // )
                    //)
                  ])),


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
                                LikeButton(
                                  size: 20,
                                  circleColor:
                                  CircleColor(start: Colors.orangeAccent, end: Colors.orange),
                                  bubblesColor: BubblesColor(
                                    dotPrimaryColor: Colors.pinkAccent,
                                    dotSecondaryColor: Colors.pink,
                                  ),
                                  likeBuilder: (bool isLiked) {
                                    return Icon(
                                      Icons.favorite,
                                      color: isLiked ? Colors.pinkAccent : Colors.grey,
                                      size: 20,
                                    );
                                  },
                                  likeCount: 0,
                                  countPostion: CountPostion.left,
                                  countBuilder: (int count, bool isLiked, String text) {
                                    var color = isLiked ? Colors.pinkAccent : Colors.grey;
                                    Widget result;
                                    if (count == 0) {
                                      result = Text(
                                        "",
                                        style: TextStyle(color: color),
                                      );
                                    } else
                                      result = Text(
                                        text,
                                        style: TextStyle(color: color),
                                      );
                                    return result;
                                  },
                                ),
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
                  ListView(
                    scrollDirection: Axis.horizontal,
                    children: [Container(
                      //
                      padding: EdgeInsets.only(top:20,bottom: 25,left: 15.0, right: 15.0),
                      height: 300,
                      width: 200,
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            blurRadius: 30,
                            offset: Offset(0, 9),
                            color: Colors.black.withOpacity(.2),
                            spreadRadius: -15)
                      ]),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11.0),
                        ),
                        elevation: 0,
                        color: Colors.white,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 10,left: 10, top : 30),
                              child : FittedBox(fit:BoxFit.fitWidth,  child : Text(
                                '감자햄볶음밥/김가루\n두부된장국\n계란후라이\n미니핫도그&케찹\n단무지\n김치\n요구르트\n\n염도 0.7 / 876.3kcal',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontFamily: 'NanumSquareR'),
                              ),),
                            ),
                          ],
                        ),
                      ),
                    ),

                      Container(
                        //
                        padding: EdgeInsets.only(top:20,bottom: 25,left: 15.0, right: 15.0),
                        height: 280,
                        width: 200,
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              blurRadius: 30,
                              offset: Offset(0, 9),
                              color: Colors.black.withOpacity(.2),
                              spreadRadius: -15)
                        ]),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11.0),
                          ),
                          elevation: 0,
                          color: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(right: 12,left: 12, top : 30),
                                child : FittedBox(fit:BoxFit.fitWidth,  child : Text(
                                  '감자햄볶음밥/김가루\n두부된장국\n계란후라이\n미니핫도그&케찹\n단무지\n김치\n요구르트\n\n염도 0.7 / 876.3kcal',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontFamily: 'NanumSquareR'),
                                ),),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )

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


  void onChangeGrade(String choice) async{
    this.selection = choice;
    dataManager.set("grade", selection);
    loadDDAY();
    setState(() {

    });

  }

  Future<String> getWebText(String url) async {
    var response = await http.get(
      Uri.encodeFull(url),
    );
    print(response.body);
    return response.body;
  }

  void getDDayFromServer() async{
    String result = await this.getWebText(ApiLinks.DDAY);
    this.parsingDDay(result);
  }

  void parsingDDay(String jsonText) async{
    if(!jsonText.contains("high")) return; // 잘못된 값을 반환했을 경우 return
    dataManager.set("DDAY", jsonText);

    Map jsonData = json.decode(jsonText);
    this.examDDay = ":/";
    this.examDDayColor = grey;

    print(jsonData);

    for (int i = 0; i < jsonData[this.grade].length; i++) {
      if (jsonData[this.grade][i] == 0) break;

      var date = new DateTime.fromMillisecondsSinceEpoch(jsonData[this.grade][i] * 1000);
      print(now.isAfter(date).toString() + i.toString());

      if (!now.isAfter(date)) {
        var diff = now.difference(date);
        int df = -diff.inDays + 1;
        this.examDDay = "D - " + df.toString();
        this.examDate = " / " + jsonData[this.grade + "s"][i].toString();

        if (df > 60)
          this.examDDayColor = green;
        else if (df > 30)
          this.examDDayColor = orange;
        else
          this.examDDayColor = red;
        break;

      } else if (now.difference(date).inDays == 0) {
        this.examDate = " / " + jsonData[this.grade + "s"][i].toString();
        this.examDDay = "D-DAY";
        this.examDDayColor = red;
        break;
      }
    }
    setState((){});
  }

  void loading(BuildContext context){
    Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("TEST"),
          duration: Duration(seconds: 3),
        )
    );
  }

  loadDDAY () async {
    final value = dataManager.get("DDAY", "{}");
    print('Offline DDAY: $value');
    if(value == "{}") return;
    parsingDDay(value);
    getDDayFromServer();
  }

  void loadGrade(){
    String grade = dataManager.get("grade", "중고등");
    switch(grade){
      case "초등" :
        {
          this.grade = "high";
        }
        break;
      case "중고등" :
        {
          this.grade = "high";
        }
        break;
      case "12학년" :
        {
          this.grade = "highest";
        }
        break;
      default :  {
        this.grade = "high";
      }
      break;
    }
    this.selection = grade;
    setState((){});
  }
}


// Create a stateful widget
class MyGetHttpData extends StatefulWidget {
  @override
  MyGetHttpDataState createState() => MyGetHttpDataState();
}

// Create the state for our stateful widget
class MyGetHttpDataState extends State<MyGetHttpData> {
  String data = "준비중";
  String body = "준비중";

  Future<String> getJSONData() async {
    var response = await http.get(
      Uri.encodeFull(ApiLinks.VIEW_COUNT),
    );

    print(response.body);
    this.body = response.body;
    setState(() {
      var dataConvertedToJSON = json.decode(response.body);
      data = dataConvertedToJSON['request'];
    });

    return "Successfull";
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(this.body),
      Text(this.data),
    ]);
  }

  @override
  void initState() {
    super.initState();

    this.getJSONData();
  }
}
