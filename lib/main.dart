import 'dart:convert';
import 'dart:io';

import 'package:animated_card/animated_card.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kish2019/api_links.dart';
import 'package:kish2019/data_manager.dart';
import 'package:like_button/like_button.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

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

  List<Widget> launchCards = [];

  Future<DataManager> initDataManager() async {
    return await dataManager.build();
  }

  @override
  void initState() {
    super.initState();
    _getId();
    this.preserve();
    this.examDDayColor = grey;
    this.todayDate = new DateFormat('yyyy-MM-dd').format(now);
    /*FOR TEST*/
    this.launchCards.add(this.createLaunchCard('감자햄볶음밥/김가루\n두부된장국\n계란후라이\n미니핫도그&케찹\n단무지\n김치\n요구르트\n\n염도 0.7 / 876.3kcal', ""));
    this.launchCards.add(this.createLaunchCard('감자햄볶음밥/김가루\n두부된장국\n계란후라이\n미니핫도그&케찹\n단무지\n김치\n요구르트\n\n염도 0.7 / 876.3kcal', ""));
    this.launchCards.add(this.createLaunchCard('감자햄볶음밥/김가루\n두부된장국\n계란후라이\n미니핫도그&케찹\n단무지\n김치\n요구르트\n\n염도 0.7 / 876.3kcal', ""));
    /*FINISH TEST*/
  }

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      print(iosDeviceInfo.identifierForVendor); // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      print(androidDeviceInfo.androidId + "이게 dudiudiudiudi"); // unique ID on Android
    }
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
        /*appBar: AppBar(
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
        ),*/
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 230.0,
                  width: double.infinity,
                  child: Card(
                      margin: EdgeInsets.zero,
                      elevation: 12.0,
                      shadowColor: Colors.cyanAccent,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(bottomRight : Radius.circular(16.0), bottomLeft: Radius.circular(16.0))),
                      child : Stack(
                          children: [
                            WaveWidget(
                              config: CustomConfig(
                                gradients: [
                                  [Colors.cyanAccent, Colors.cyan],
                                  [Colors.lightBlueAccent, Colors.lightBlue],
                                  [Colors.tealAccent, Colors.teal],
                                  [Colors.blue, Colors.blueAccent]
                                ],
                                durations: [35000, 19440, 10800, 6000],
                                heightPercentages: [(0.20 + 0.4), (0.23 + 0.4), (0.25 + 0.4), (0.30 + 0.4)],
                                blur: MaskFilter.blur(BlurStyle.solid, 40),
                                gradientBegin: Alignment.bottomLeft,
                                gradientEnd: Alignment.topRight,
                              ),
                              waveAmplitude: 0,
                              backgroundColor: Color.fromARGB(255, 6, 6, 99),
                              size: Size(
                                double.infinity,
                                double.infinity,
                              ),
                            ),
                            Center(
                                child: Container(
                                  //margin: EdgeInsets.only(top: 40),
                                    child : Text(
                                      examDDay,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 50,
                                          fontFamily: 'NanumSquareB'),
                                    )
                                )
                            ),
                            /*Text("시험 D-DAY", style: TextStyle(
                                color: Colors.black,
                                fontSize: 50,
                                fontFamily: 'NanumSquareB'),),*/
                          ]
                      )
                  )
              ),

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



              /*Column(
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
                    height: 172.0,
                    width: double.infinity,
                  child: Card(
                    elevation: 12.0,
                    margin: EdgeInsets.only(right: 16.0, left: 16.0, bottom: 16.0),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0))),
                  child : Stack(
                    children: [
                      WaveWidget(
                    config: CustomConfig(
                      gradients: [
                        [Colors.cyanAccent, Colors.cyan],
                        [Colors.lightBlueAccent, Colors.lightBlue],
                        [Colors.tealAccent, Colors.teal],
                        [Colors.blue, Colors.blueAccent]
                      ],
                      durations: [35000, 19440, 10800, 6000],
                      heightPercentages: [0.20, 0.23, 0.25, 0.30],
                      blur: MaskFilter.blur(BlurStyle.solid, 40),
                      gradientBegin: Alignment.bottomLeft,
                      gradientEnd: Alignment.topRight,
                    ),
                    waveAmplitude: 0,
                    backgroundColor: Colors.white,
                    size: Size(
                      double.infinity,
                      double.infinity,
                    ),
                  ),
                      Center(
                          child: Text(
                            examDDay,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontFamily: 'NanumSquareB'),
                          )
                      )
                    ]
                  )
                  )
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
              ),*/

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
                  width: double.infinity,
                  child : Column(
                    children: this.launchCards,
                  )
              )
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

  Container createLaunchCard(String launchText, String id){
    return Container(
      //
      padding: EdgeInsets.only(top:20,bottom: 25,left: 15.0, right: 15.0),
      height: 300,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            blurRadius: 30,
            offset: Offset(0, 9),
            color: Colors.black.withOpacity(.2),
            spreadRadius: -15)
      ]),
      child : AnimatedCard(
        direction: AnimatedCardDirection.right, //Initial animation direction
        initDelay: Duration(milliseconds: 5), //Delay to initial animation
        duration: Duration(seconds: 1), //Initial animation duration
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11.0),
          ),
          elevation: 0,
          color: Color.fromARGB(255, 35, 39, 41),
          child: Stack(
            children : [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(left: 45),
                  child : Row(
                  children : [
                    Text("3일/",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontFamily: 'NanumSquareR'),
                    ),
                    Text("월",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'NanumSquareR'),
                ),
            ]
                ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
              child : Container(
                height: 150,
                margin: EdgeInsets.only(right: 20,left: 10),
                child : FittedBox(
                  fit:BoxFit.scaleDown,
                  child : Text(
                  launchText,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 200,
                      fontFamily: 'NanumSquareR'),
                ),),
              ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child : LikeButton(
                  size: 20,
                  circleColor:
                  CircleColor(start: Colors.orangeAccent, end: Colors.orange),
                  bubblesColor: BubblesColor(
                    dotPrimaryColor: Colors.pinkAccent,
                    dotSecondaryColor: Colors.pink,
                  ),
                  onTap: (bool isLiked) {
                    return onLikeButtonTap(isLiked, launchText);
                  },
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
                ),
              )
            ],
          )
      ),
      ),
    );
  }

  Future<bool> onLikeButtonTap(bool isLiked, String launchText) async {  // Just test
    Share.share(launchText + "\n\nKISH 어플 다운받기 !");
    return true;
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
    if(response.statusCode != 200) return "";
    print(response.body);
    return response.body;
  }

  void getDDayFromServer() async{
    String result = await this.getWebText(ApiLinks.DDAY);
    if(result != "") {
      dataManager.set("DDAY", result);
      this.parsingDDay(result);
    }
  }

  void parsingDDay(String jsonText) async{
    List<dynamic> jsonData = json.decode(jsonText);
    this.examDDayColor = grey;

    print(jsonData);

    for (int i = 0; i < jsonData.length; i++) {
      if (jsonData[i] == 0) break;

      var date = new DateTime.fromMillisecondsSinceEpoch(jsonData[i] * 1000);
      print(now.isAfter(date).toString() + i.toString());

      if (!now.isAfter(date)) {
        var diff = now.difference(date);
        int df = -diff.inDays + 1;
        this.examDDay = "D - " + df.toString();
        this.examDate = " / " + jsonData[i].toString();

        if (df > 60)
          this.examDDayColor = green;
        else if (df > 30)
          this.examDDayColor = orange;
        else
          this.examDDayColor = red;
        break;

      } else if (now.difference(date).inDays == 0) {
        this.examDate = " / " + jsonData[i].toString();
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
    final value = dataManager.get("DDAY", "[]");
    print('Offline DDAY: $value');
    if(value != "[]") {
      this.examDDay = ":/";
      parsingDDay(value);
    }
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
