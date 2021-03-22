import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:intl/intl.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/DetailedCard.dart';
import 'package:kish2019/widget/dday_card.dart';
import 'package:kish2019/widget/description_text.dart';
import 'package:kish2019/widget/title_text.dart';
import 'package:kish2019/noti_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  FutureBuilder lunchFutureBuilder;
  FutureBuilder ddayFutureBuilder;
  String todayDate;
  int sliderIdx = 0;

  Icon ddayNotiIcon = new Icon(Icons.alarm_off_sharp);
  Icon lunchNotiIcon = new Icon(Icons.alarm_off_sharp);

  //List<Widget> sliderItems = [];

  @override
  void initState() {
    super.initState();
    lunchFutureBuilder = FutureBuilder(
        future: ApiHelper.getLunch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              loadLunchNotiIcon();

              Widget menuWidget;
              List result = snapshot.data;

              DateTime tmpDate = DateTime.now();
              DateTime today =
              DateTime(tmpDate.year, tmpDate.month, tmpDate.day);
              int timestamp = (today.millisecondsSinceEpoch / 1000).round();
              int count = 0;
              //print("our : " + today.millisecondsSinceEpoch.toString());

              result.forEach((element) {
                if (count > 0) return;

                Map data = element;
                /*print("-------");
                          print(data["timestamp"] * 1000);
                          print(DateTime.fromMillisecondsSinceEpoch(data["timestamp"] * 1000).toString());*/
                if (timestamp <= data["timestamp"]) {
                  menuWidget = DetailedCard(
                    bottomTitle: "",
                    title: "오늘의 급식",
                    description: data["date"],
                    content: (data["menu"] as String).replaceAll(",", "\n"),
                    icon: Container(),
                    descriptionColor: Colors.black87,
                    contentTextStyle: TextStyle(
                        fontFamily: "NanumSquareL",
                        color: Color.fromARGB(255, 135, 135, 135),
                        fontWeight: FontWeight.w600),
                  );
                  count++;
                }
              });

              return Container(
                  child: menuWidget,
                  width: MediaQuery.of(context).size.width * 0.9);
            } else if (snapshot.hasError) {
              return DDayCard(
                color: Colors.redAccent,
                content: "불러올 수 없음",
              );
            }
            return YoutubeShimmer();
          } else {
            return YoutubeShimmer();
          }
        });

    ddayFutureBuilder = FutureBuilder(
      future: ApiHelper.getExamDDay(),
      builder: (context, snapshot) {
        loadDdayNotiIcon();

        List<Widget> list = [];
        Container widget = Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: new Column(
              children: list,
              crossAxisAlignment: CrossAxisAlignment.start,
            ));

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            Map data = snapshot.data;

            if (data["invalid"] != null) {
              list.add(new DDayCard(content: "정보 없음", color: DDayCard.grey));
              list.add(DescriptionText(
                'D-Day - 정보 없음',
                margin: EdgeInsets.only(left: 25, top: 5),
              ));
              return widget;
            }

            list.add(new DDayCard(
              timestamp: data["timestamp"],
              description: data["label"] + " (" + data["date"] + ")",
            ));
            return widget;
          } else if (snapshot.hasError) {
            list.add(new DDayCard(
              content: "불러오기 실패",
              color: DDayCard.grey,
            ));
            list.add(DescriptionText(
              'D-Day - 불러올 수 없어요',
              margin: EdgeInsets.only(left: 25, top: 5),
            ));
            return widget;
          }
        }
        list.add(YoutubeShimmer());
        list.add(DescriptionText(
          'D-Day - 불러오는 중',
          margin: EdgeInsets.only(left: 25, top: 5),
        ));
        return widget;
      },
    );
    /*sliderItems = [
      lunchFutureBuilder,
      examFutureBuilder,
    ];*/
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
          Container(
            margin: EdgeInsets.only(bottom: 25),
            child: TitleText('오늘의 식단을\n확인하세요'),
          ),
          /*CarouselSlider(
            options: CarouselOptions(
                aspectRatio: 2 / 1,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 10),
                enableInfiniteScroll: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    sliderIdx = index;
                  });
                }),
            items: sliderItems,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _getIndicator(sliderItems, sliderIdx),
          ),*/
          Center(
              child: Column(
                  children: [
                    Container(
                        alignment: Alignment.topRight,
                        child: FlatButton.icon(onPressed: () { updateDdayNoti(); },
                          icon: ddayNotiIcon,
                          label: Text("DDay 알림"),)),
                    ddayFutureBuilder,
                  ]
              )
          ),

          Center(
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 30),
                      alignment: Alignment.topRight,
                      child: FlatButton.icon(onPressed: updateLunchNoti,
                        icon: this.lunchNotiIcon,
                        label: Text("식단 알림"),)),
                  Container(
                      child: lunchFutureBuilder),
                ],
              )
          ),
        ],
      ),
    );
  }

  Future<void> loadDdayNotiIcon() async {
    await NotificationManager.checkSettings();
    Future<void>.delayed(Duration(milliseconds: 500), () {
      setState(() {
        ddayNotiIcon = Icon(NotificationManager.showDdayNoti ? Icons.notifications_active : Icons.notifications_active_outlined);
      });
    });
  }

  Future<void> updateDdayNoti() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool result = preferences.getBool("ddayNoti");

    if(result == null){
      result = true;
    }else{
      result = !result;
    }

    preferences.setBool("ddayNoti", result);
    NotificationManager.showDdayNoti = result;

    if(result) {
      NotificationManager.startDdayNoti();
    }else{
      NotificationManager.stopDdayNoti();
    }

    await preferences.setBool("ddayNoti", result);

    setState(() {
      ddayNotiIcon = Icon(result ? Icons.notifications_active : Icons.notifications_active_outlined);
    });
  }

  Future<void> loadLunchNotiIcon() async {
    await NotificationManager.checkSettings();
    Future<void>.delayed(Duration(milliseconds: 500), () {
      setState(() {
        lunchNotiIcon = Icon(NotificationManager.showDdayNoti ? Icons.notifications_active : Icons.notifications_active_outlined);
      });
    });
  }

  Future<void> updateLunchNoti() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool result = preferences.getBool("lunchNoti");
    if(result == null){
      result = true;
    }else{
      result = !result;
    }

    preferences.setBool("lunchNoti", result);
    NotificationManager.showDdayNoti = result;

    if(result) {
      NotificationManager.startLunchMenuNoti();
    }else{
      NotificationManager.stopLunchMenuNoti();
    }

    await preferences.setBool("lunchNoti", result);

    setState(() {
      lunchNotiIcon = Icon(result ? Icons.notifications_active : Icons.notifications_active_outlined);
    });
  }

  List<Widget> _getIndicator(List items, int index) {
    List<Widget> list = [];
    // https://pub.dev/packages/carousel_slider/example - indicator demo
    for (int i = 0; i < items.length; i++) {
      list.add(Container(
        width: 8.0,
        height: 8.0,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: i == index
              ? Color.fromRGBO(0, 0, 0, 0.9)
              : Color.fromRGBO(0, 0, 0, 0.4),
        ),
      ));
    }
    return list;
  }
}
