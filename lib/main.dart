import 'dart:io';

import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kish2019/page/kish_magazine_page.dart';
import 'package:kish2019/page/main_page.dart';
import 'package:kish2019/page/maintenance_page.dart';
import 'package:kish2019/noti_manager.dart';
import 'package:new_version/new_version.dart';
import 'package:foreground_service/foreground_service.dart';

// TODO : 알림 관련 리팩토링 및 clean
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationManager().startNoti();

  runApp(MaterialApp(
      title: 'KISH',
      theme: ThemeData(
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.grey[900]),
        ),
        fontFamily: 'NanumSquareL',
        primarySwatch: Colors.blue,
      ),
      builder: EasyLoading.init(),
      home: Home()));

  startForegroundServiceChecking();
}

void startForegroundServiceChecking() async {
  NotificationManager manager = NotificationManager.instance;

  ///this exists solely in the main app/isolate,
  ///so needs to be redone after every app kill+relaunch
  await ForegroundService.setupIsolateCommunication((data) {
    //debugPrint("main received: $data");
  });

  startForegroundUpdate();

  while (true) {
    await Future<void>.delayed(Duration(seconds: 1), () async {
      if (await manager.isDdayEnabled() || await manager.isLunchMenuEnabled()) {
        foregroundServiceStart();
      } else {
        ForegroundService.stopForegroundService();
      }
    });
  }
}

// 앱이 켜져있을 때 포그라운드 서비스를 대신하여 알림을 업데이트 합니다.
void startForegroundUpdate() async{
  if (!await ForegroundService.isBackgroundIsolate) {
    globalForegroundService();
  }

  while (true) {
    await Future<void>.delayed(Duration(seconds: 60), () async {
      if (!await ForegroundService.isBackgroundIsolate) {
        globalForegroundService();
      }
    });
  }
}

//use an async method so we can await
void foregroundServiceStart() async {
  ///if the app was killed+relaunched, this function will be executed again
  ///but if the foreground service stayed alive,
  ///this does not need to be re-done
  if (!(await ForegroundService.foregroundServiceIsStarted())) {
    await ForegroundService.setServiceIntervalSeconds(60);

    await ForegroundService.notification.startEditMode();
    await ForegroundService.notification
        .setTitle("서비스 시작됨");
    await ForegroundService.notification
        .setText("곧 알림이 업데이트됩니다.");
    await ForegroundService.notification.finishEditMode();

    ForegroundService.notification.setPriority(AndroidNotificationPriority.LOW);

    await ForegroundService.startForegroundService(globalForegroundService);
    await ForegroundService.getWakeLock();
  }
}


void globalForegroundService() async{
  NotificationManager manager = NotificationManager.instance;

  if(manager == null){
    manager = new NotificationManager();
    await manager.startNoti();
  }

  if(await manager.isLunchMenuEnabled()) await manager.showLunchMenuNotification();
  if(await manager.isDdayEnabled()) await manager.showDdayNotification();
}

class Home extends StatefulWidget {
  @override
  MainState createState() => MainState();
}

class MainState extends State<Home> {
  final PageController pageController = PageController(initialPage: 0);
  NewVersion newVersion;
  DateTime currentBackPressTime;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      currentIndex = pageController.page.toInt();
    });
    newVersion = NewVersion(context: context,
        dialogTitle: "업데이트 이용 가능", dismissText: "나중에", updateText: "업데이트 하기");
    newVersion.showAlertIfNecessary();
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,

        body: PageView(
          controller: pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            MainPage(),
            KishMagazinePage(),
            MaintenancePage(
              description: "대나무숲에서 익명으로 사연을 공유하세요",
            ),
            MaintenancePage(
              description: "학교 가정통신문을 빠르게 확인하세요",
            ),
            MaintenancePage(
              description: "도서 대출 현황을 쉽게 확인하세요",
            ),
          ],
        ), // PageView

        // bottom bar
        bottomNavigationBar: BubbleBottomBar(
          hasNotch: true,
          opacity: .2,
          currentIndex: currentIndex,
          onTap: changePage,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          //border radius doesn't work when the notch is enabled.
          elevation: 8,
          items: <BubbleBottomBarItem>[
            BubbleBottomBarItem(  // HOME
                backgroundColor: Colors.redAccent,
                icon: Icon(
                  Icons.home_outlined,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.home_outlined,
                  color: Colors.redAccent,
                ),
                title: Text("홈")),
            BubbleBottomBarItem(  // KISH MAGAZINE
                backgroundColor: Colors.black54,
                icon: Icon(
                  Icons.library_books_outlined,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.library_books_outlined,
                  color: Colors.black54,
                ),
                title: Text("매거진")),
            BubbleBottomBarItem(  // KISH 대나무숲
                backgroundColor: Colors.green,
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.green,
                ),
                title: Text("대나무숲")),
            BubbleBottomBarItem(  // KISH 가정통신문
                backgroundColor: Colors.black54,
                icon: Icon(
                  Icons.assignment_outlined,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.assignment_outlined,
                  color: Colors.black54,
                ),
                title: Text("가정통신문")),
            BubbleBottomBarItem(  // KISH 도서
                backgroundColor: Colors.brown,
                icon: Icon(
                  Icons.book_outlined,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.book_outlined,
                  color: Colors.brown,
                ),
                title: Text("도서")),
          ],
        ),
      ),
    );
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOutQuad);
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
    if (Platform.isIOS) {
      // import 'dart:io'
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      print(iosDeviceInfo.identifierForVendor); // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      print(androidDeviceInfo.androidId + "이게 uuid"); // unique ID on Android
    }
  }
}
