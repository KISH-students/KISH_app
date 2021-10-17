import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:intl/intl.dart';
import 'package:kish2019/main.dart';
import 'package:kish2019/page/bamboo_page.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/DetailedCard.dart';
import 'package:kish2019/widget/bamboo_post_viewer.dart';
import 'package:kish2019/widget/dday_card.dart';
import 'package:kish2019/widget/description_text.dart';
import 'package:kish2019/widget/post_webview.dart';
import 'package:kish2019/widget/title_text.dart';
import 'package:kish2019/noti_manager.dart';
import 'package:kish2019/kish_api.dart';
import 'package:notification_permissions/notification_permissions.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> with AutomaticKeepAliveClientMixin<MainPage>{
  Widget? lunchFutureBuilder;
  late Widget ddayFutureBuilder;
  String? todayDate;
  int sliderIdx = 0;

  Widget ddayNotiIcon = CupertinoActivityIndicator();
  Widget lunchNotiIcon = CupertinoActivityIndicator();
  Widget dinnerNotiIcon = CupertinoActivityIndicator();

  @override
  void initState() {
    super.initState();
    List<Widget> list = [];
    Container widget = Container(
        child: new Column(
          children: list,
          crossAxisAlignment: CrossAxisAlignment.start,
        ));

    list.add(YoutubeShimmer());
    list.add(DescriptionText(
      'D-Day - 불러오는 중',
      margin: EdgeInsets.only(left: 25, top: 5),
    ));
    ddayFutureBuilder = widget;

    lunchFutureBuilder = YoutubeShimmer();

    todayDate = new DateFormat('yyyy-MM-dd').format(DateTime.now());
    initWidgets();

    Future.delayed(Duration(seconds: 1), () {
      FirebaseMessaging.instance.getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          if (message.data["type"] == "newPost") {
            MyApp.navigatorKey.currentState!.push(
                MaterialPageRoute(
                    builder: (context) =>   // 새 페이지를 띄웁니다
                    PostWebView(  // KISH 게시물 웹뷰 위젯
                        menu: message.data["menu"],
                        id: message.data["id"]
                    )
                )
            );
          } else if (message.data["type"] == "newBambooPost") {
            MyApp.navigatorKey.currentState!.push(
                MaterialPageRoute(
                    builder: (context) {
                      int id = int.parse(message.data["post_id"]);
                      return new Scaffold(
                          body: BambooPostViewer(id),
                      );
                    })
            );
          } else if (message.data["type"] == "newBambooComment") {
            MyApp.navigatorKey.currentState!.push(
                MaterialPageRoute(
                    builder: (context) {
                      int postId = int.parse(message.data["post_id"]);
                      int commentId = int.parse(message.data["comment_id"]);
                      return new Scaffold(
                        body: BambooPostViewer(postId, commentIdToView: commentId,),
                      );
                    })
            );
          }
        }
      });
    });
  }

  Future<void> initWidgets() async {
    if (!this.mounted) {
      await Future<void>.delayed(Duration(milliseconds: 10), () {
        initWidgets();
      });
    } else {
      await loadDdayNotiIcon();
      await loadLunchNotiIcon();
      await loadDinnerNotiIcon();
      setState(() {});

      if (NotificationManager.getInstance().preferences == null) {
        await NotificationManager.getInstance().loadSharedPreferences();
      }

      lunchFutureBuilder = FutureBuilder(
          future: ApiHelper.getLunch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getLunchWidget("오늘의 중식", snapshot.data),
                      getLunchWidget("오늘의 석식", snapshot.data,
                          containerMargin: EdgeInsets.only(left: 10),
                          isDinner: true),
                    ]
                );
              } else {
                return DDayCard(
                  color: Colors.redAccent,
                  content: "불러오지 못했어요",
                );
              }
            } else {
              String? cachedJson = NotificationManager.getInstance().preferences!
                  .getString(ApiHelper.getCacheKey(KISHApi.GET_LUNCH, {"date": ApiHelper.getTodayDateForLunch()}));
              if (cachedJson != null) {
                dynamic data;
                try {
                  data = json.decode(cachedJson);
                } catch (e) {
                  print(e);
                  return YoutubeShimmer();
                }

                return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 40, right: 40),
                        child: LinearProgressIndicator(backgroundColor: Colors.blueGrey, minHeight: 1,),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            getLunchWidget("오늘의 중식", data),
                            getLunchWidget("오늘의 석식", data,
                                containerMargin: EdgeInsets.only(left: 10),
                                isDinner: true),
                          ]
                      ),
                    ]);
              }
              return YoutubeShimmer();
            }
          });

      ddayFutureBuilder = FutureBuilder(
        future: ApiHelper.getExamDDay(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return getDdayWidget(snapshot.data as Map);
            } else if (snapshot.hasError) {
              return getDdayWidget(null);
            }
          }

          String? cachedJson = NotificationManager.getInstance().preferences!
              .getString(ApiHelper.getCacheKey(KISHApi.GET_EXAM_DATES, {}));
          if (cachedJson != null) {
            dynamic data;
            try {
              data = json.decode(cachedJson);
            } catch(e) {
              print(e);
              return YoutubeShimmer();
            }
            return Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    child: LinearProgressIndicator(backgroundColor: Colors.orangeAccent,  minHeight: 1),
                  ),
                  getDdayWidget(data.isEmpty ? null : data[0]),
                ]
            );
          }

          List<Widget> list = [];
          Container widget = Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: new Column(
                children: list,
                crossAxisAlignment: CrossAxisAlignment.start,
              ));

          list.add(YoutubeShimmer());
          list.add(DescriptionText(
            'D-Day - 불러오는 중',
            margin: EdgeInsets.only(left: 25, top: 5),
          ));
          return widget;
        },
      );

      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {await initWidgets();},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: 17),
                child: Center(
                  child: FlatButton(
                    onPressed: () { _showAppInfoDialog(context); },
                    child: Image(image: AssetImage("images/kish_title_logo.png"), height: 59, width:  MediaQuery.of(context).size.width * 0.3,),
                  ),),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 25),
                child: TitleText('오늘의 식단을\n확인하세요', top: 50.0,),
              ),
              Center(
                  child: Column(
                      children: [
                        Container(
                            alignment: Alignment.topRight,
                            child: FlatButton.icon(
                              onPressed: Platform.isIOS ? (){} : updateDdayNoti,  // ios에선 표시 안 함
                              icon: ddayNotiIcon,
                              label: Text(Platform.isIOS ? "" : "DDay 알림"),)),
                        ddayFutureBuilder,
                      ]
                  )
              ),

              Center(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Stack(
                            children: [
                              Container(
                                  alignment: Alignment.topLeft,
                                  child: FlatButton.icon(
                                    onPressed: Platform.isIOS ? (){} : updateLunchNoti,
                                    icon: this.lunchNotiIcon,
                                    label: Text(Platform.isIOS ? "" : "중식 알림"),)),
                              Container(
                                  alignment: Alignment.topRight,
                                  child: FlatButton.icon(
                                    onPressed: Platform.isIOS ? (){} : updateDinnerNoti,
                                    icon: this.dinnerNotiIcon,
                                    label: Text(Platform.isIOS ? "" : "석식 알림"),)),
                            ]
                        ),
                      ),
                      Container(
                          child: lunchFutureBuilder),
                    ],)
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: BambooPosts(),
              )
            ],),
        ),
      ),
    );
  }

  Widget getLunchWidget(String cardTitle, dynamic data, {EdgeInsets? containerMargin, bool isDinner = false}) {
    try {
      if (data != null) {
        Widget? menuWidget;

        DateTime tmpDate = DateTime.now();
        DateTime today =
        DateTime(tmpDate.year, tmpDate.month, tmpDate.day);
        int timestamp = (today.millisecondsSinceEpoch / 1000).round();
        int count = 0;

        data.forEach((element) {
          if (count > 0) return;

          Map data = element;
          // 석식 : dinnerMenu | 중식 : "menu"
          String? menu = (isDinner
              ? data["dinnerMenu"]
              : data["menu"]) as String?;

          if (timestamp <= data["timestamp"]) {
            menuWidget = DetailedCard(
              bottomTitle: "",
              title: cardTitle,
              description: data["date"],
              content: menu!.replaceAll(",", "\n"),
              icon: Container(),
              descriptionColor: Colors.black87,
              contentTextStyle: const TextStyle(
                  fontFamily: "NanumSquareL",
                  color: Color.fromARGB(255, 135, 135, 135),
                  fontWeight: FontWeight.w600),
            );
            count++;
          }
        });

        if (menuWidget == null) {
          menuWidget = DetailedCard(
            bottomTitle: "",
            title: cardTitle,
            description: "",
            content: "정보 없음\n\n시간대가 올바른지\n확인하십시오.",
            icon: Container(),
            descriptionColor: Colors.black87,
            contentTextStyle: const TextStyle(
                fontFamily: "NanumSquareL",
                color: Color.fromARGB(255, 135, 135, 135),
                fontWeight: FontWeight.w600),
          );
        }

        return Container(
            margin: containerMargin,
            child: menuWidget,
            width: (MediaQuery
                .of(context)
                .size
                .width * 0.9) / 2
        );
      } else {
        return DDayCard(
          color: Colors.redAccent,
          content: "불러올 수 없음",
        );
      }
    } catch (e) {
      return DetailedCard(
        bottomTitle: "",
        title: cardTitle,
        description: "",
        content: "오류가 발생하였습니다.",
        icon: Container(),
        descriptionColor: Colors.black87,
        contentTextStyle: const TextStyle(
            fontFamily: "NanumSquareL",
            color: Color.fromARGB(255, 135, 135, 135),
            fontWeight: FontWeight.w600),
      );
    }
  }

  Widget getDdayWidget(Map? data) {
    List<Widget> list = [];
    Container widget = Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: new Column(
          children: list,
          crossAxisAlignment: CrossAxisAlignment.start,
        ));

    if (data != null) {
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
    } else {
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

  Future<void> loadDdayNotiIcon() async {
    if (Platform.isIOS) {
      ddayNotiIcon = Container();
      return;
    }

    NotificationManager manager = NotificationManager.getInstance();
    ddayNotiIcon = Icon(
        await manager.ddayNoti.isEnabled()
            ? Icons.notifications_active
            : Icons.notifications_active_outlined);
  }

  Future<void> loadLunchNotiIcon() async {
    if (Platform.isIOS) {
      lunchNotiIcon = Container();
      return;
    }
    NotificationManager manager = NotificationManager.getInstance();
    lunchNotiIcon = Icon(
        await manager.lunchMenuNoti.isLunchEnabled()
            ? Icons.notifications_active
            : Icons.notifications_active_outlined);
  }

  Future<void> loadDinnerNotiIcon() async {
    if (Platform.isIOS) {
      dinnerNotiIcon = Container();
      return;
    }
    NotificationManager manager = NotificationManager.getInstance();
    dinnerNotiIcon = Icon(
        await manager.lunchMenuNoti.isDinnerEnabled()
            ? Icons.notifications_active
            : Icons.notifications_active_outlined);
  }

  Future<void> updateDdayNoti() async{
    NotificationManager manager = NotificationManager.getInstance();

    bool result = await manager.ddayNoti.toggleStatus();
    setState(() {
      ddayNotiIcon = Icon(result ? Icons.notifications_active : Icons.notifications_active_outlined);
    });

    await manager.updateNotifications();
  }

  Future<void> updateDinnerNoti() async{
    NotificationManager manager = NotificationManager.getInstance();

    bool result = await manager.lunchMenuNoti.toggleDinner();
    setState(() {
      dinnerNotiIcon = Icon(result ? Icons.notifications_active : Icons.notifications_active_outlined);
    });

    await manager.updateNotifications();
  }

  Future<void> updateLunchNoti() async{
    NotificationManager manager = NotificationManager.getInstance();

    bool result = await manager.lunchMenuNoti.toggleLunch();
    setState(() {
      lunchNotiIcon = Icon(result ? Icons.notifications_active : Icons.notifications_active_outlined);
    });

    await manager.updateNotifications();
  }

  @override
  bool get wantKeepAlive => true;
}

void _showAppInfoDialog(BuildContext context) {
  showAboutDialog(context: context,
      applicationName: "하노이한국국제학교 - KISH 어플리케이션",
      children: [
        Text('이 어플리케이션은 하노이한국국제학교의 공식 어플리케이션이 아닙니다.\n'
            '제공된 정보 중 오류가 포함되어 있을 수 있습니다.\n'
            '문제 발생시 카카오톡 아이디 j203775으로 연락해주세요.\n'),
        Text("유정욱,이동주,이찬영,김태형,김나현,조현정,김재원,고성준,김태운,김경재,박지민,김선우",
          overflow: TextOverflow.clip,),
        Text("\n개발에 기여 해보세요.\nhttps://github.com/KISH-students"),
      ]
  );
}

class BambooPosts extends StatelessWidget {
  const BambooPosts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text("익명 게시물",
                  style: TextStyle(color: Color.fromARGB(220, 43, 43, 43),
                      fontSize: 20,
                      fontFamily: "CRB"))
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.4),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: FutureBuilder(builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Text("오류가 발생했습니다.");
                }
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  List data = snapshot.data as List;
                  List<Widget> posts = [];
                  data.forEach((element) {
                    Widget post = MaterialButton(onPressed: () {MainState.instance!.changePage(2);},
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(element['bamboo_title'], style: TextStyle(fontWeight: FontWeight.bold,)),
                              Container(height: 4),
                              Text(element['bamboo_content'])
                            ])
                    );
                    posts.add(post);
                    posts.add(Divider());
                  });
                  posts.removeLast(); //마지막 Divider 제거
                  return Column(children: posts,
                    crossAxisAlignment: CrossAxisAlignment.start,);
                } else {
                  return CupertinoActivityIndicator();
                }
              },
                  future: ApiHelper.getBambooPosts(0)),
            ),
          ),
        ]);
  }
}
