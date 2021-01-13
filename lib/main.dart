import 'dart:io';

import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:kish2019/page/kish_magazine_page.dart';
import 'package:kish2019/page/maintenance_page.dart';
import 'file:///C:/Users/vojou/Desktop/Hancho/nk3/KISH_app/lib/page/main_page.dart';
import 'package:device_info/device_info.dart';

void main() {
  runApp(Home());
}

class Home extends StatefulWidget {
  @override
  MainState createState() => MainState();
}

class MainState extends State<Home> {
  final PageController pageController = PageController( initialPage: 0 );
  DateTime currentBackPressTime;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      currentIndex = pageController.page.toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KISH',
      theme: ThemeData(
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.grey[900]),
        ),
        fontFamily: 'NanumSquare',
        primarySwatch: Colors.blue,
      ),
      builder: EasyLoading.init(),
      home: WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          backgroundColor: Colors.white,

          body: PageView(
            controller: pageController,
            physics: NeverScrollableScrollPhysics(),
            children : [
              MainPage(),
              KishMagazinePage(),
              MaintenancePage(description: "대나무숲에서 익명으로 사연을 공유하세요",),
              MaintenancePage(description: "학교 가정통신문을 빠르게 확인하세요",),
              MaintenancePage(description: "도서 대출 현황을 쉽게 확인하세요",),
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
                  backgroundColor: Colors.deepPurple,
                  icon: Icon(
                    Icons.assignment_outlined,
                    color: Colors.black,
                  ),
                  activeIcon: Icon(
                    Icons.assignment_outlined,
                    color: Colors.deepPurple,
                  ),
                  title: Text("대나무숲")),
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

  // From https://stackoverflow.com/questions/53496161
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "종료하려면 한번 더 누르세요");
      return Future.value(false);
    }
    return Future.value(true);
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
}
