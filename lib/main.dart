import 'dart:io';

import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'file:///C:/Users/vojou/Desktop/Hancho/nk3/KISH_app/lib/page/main_page.dart';
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
  final PageController pageController = PageController( initialPage: 0, );
  DateTime now = DateTime.now();
  List<Widget> launchCards = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        currentIndex = pageController.page.toInt();
      });
    });
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
          bodyText1: TextStyle(color: Colors.grey[900]),
        ),
        fontFamily: 'NanumSquare',
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,

        body: PageView(
          controller: pageController,
          physics:new NeverScrollableScrollPhysics(),
          children : [
            MainPage(),
            MainPage(),
            MainPage(),
            MainPage(),
          ],
        ),// PageView

        // bottom bar
        bottomNavigationBar: BubbleBottomBar(
          hasNotch: true,
          opacity: .2,
          currentIndex: currentIndex,
          onTap: changePage,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                  16)), //border radius doesn't work when the notch is enabled.
          elevation: 8,
          items: <BubbleBottomBarItem>[
            BubbleBottomBarItem(
                backgroundColor: Colors.red,
                icon: Icon(
                  Icons.dashboard,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.dashboard,
                  color: Colors.red,
                ),
                title: Text("Home")),
            BubbleBottomBarItem(
                backgroundColor: Colors.deepPurple,
                icon: Icon(
                  Icons.bookmark,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.bookmark,
                  color: Colors.deepPurple,
                ),
                title: Text("kish magazine")),
            BubbleBottomBarItem(
                backgroundColor: Colors.indigo,
                icon: Icon(
                  Icons.assignment,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.assignment,
                  color: Colors.indigo,
                ),
                title: Text("가정통신문")),
            BubbleBottomBarItem(
                backgroundColor: Colors.deepPurple,
                icon: Icon(
                  Icons.account_balance,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.bookmark,
                  color: Colors.deepPurple,
                ),
                title: Text("kish magazine")),
            BubbleBottomBarItem(
                backgroundColor: Colors.green,
                icon: Icon(
                  Icons.book,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.book,
                  color: Colors.green,
                ),
                title: Text("학교 도서")),
          ],
        ),
      ),
    );
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
      pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.easeInOutQuad);
      //pageController.jumpToPage(currentIndex);
    });
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
