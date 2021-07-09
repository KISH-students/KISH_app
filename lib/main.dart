import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kish2019/page/kish_magazine_page.dart';
import 'package:kish2019/page/kish_post_list_page.dart';
import 'package:kish2019/page/library_page.dart';
import 'package:kish2019/page/main_page.dart';
import 'package:kish2019/noti_manager.dart';
import 'package:new_version/new_version.dart';

FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

// URL LAUNCHER 추후 IOS 작업 해야합니다.
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  firebaseCloudMessaging_Listeners();

  await NotificationManager().init();

  runApp(MaterialApp(
      title: 'KISH',
      theme: ThemeData(
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.grey[900]),
        ),
        fontFamily: 'NanumSquareL',
        primarySwatch: Colors.blue,
      ),
      home: Home()));

  // https://github.com/transistorsoft/flutter_background_fetch 에서
  // BackgroundFetch에 대해 참고할 수 있습니다.
  //
  // 추후 IOS 지원시 Background 관련 셋업을 해야합니다..
  if (Platform.isAndroid) {
    await initPlatformState();
    await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    BackgroundFetch.start();

    NotificationManager.instance.updateNotifications();
  }
}

Future<void> setDisplayMode() async{
  try {
    DisplayMode current = await FlutterDisplayMode.current;
    DisplayMode newMode;
    double maxFreq = -1;

    (await FlutterDisplayMode.supported).forEach((element) {
      if (element.width == current.width
          && element.height == current.height) {
        if (element.refreshRate > maxFreq) {
          newMode = element;
          maxFreq = element.refreshRate;
        }
      }
    });

    if (newMode != null) {
      FlutterDisplayMode.setMode(newMode);
    }
  } catch (e) {   // API가 지원되지 않을경우 예외가 발생할 수 있습니다.
    print ("디스플레이 모드 설정 실패");
  }
}

void firebaseCloudMessaging_Listeners() {
  _firebaseMessaging.getToken().then((token){
    NotificationManager.FcmToken = token;
  });
}

Future<void> notificationUpdateTask() async {
  NotificationManager manager = NotificationManager.instance;

  if(manager == null){
    manager = new NotificationManager();
    await manager.init();
  }

  manager.updateNotifications();
  return Future.value(true);
}

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  await notificationUpdateTask();
  print('[BackgroundFetch] JobStarted and FINISHED: $taskId');
  // Do your work here...
  BackgroundFetch.finish(taskId);
}

Future<void> initPlatformState() async {
  // Configure BackgroundFetch.
  int status = await BackgroundFetch.configure(BackgroundFetchConfig(
      minimumFetchInterval: 15,
      stopOnTerminate: false,
      enableHeadless: true,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresStorageNotLow: false,
      requiresDeviceIdle: false,
      requiredNetworkType: NetworkType.NONE,
      startOnBoot: true
  ), (String taskId) async {  // <-- Event handler
    // This is the fetch-event callback.
    print('[BackgroundFetch] JobStarted! : $taskId');
    await notificationUpdateTask();
    // IMPORTANT:  You must signal completion of your task or the OS can punish your app
    // for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }, (String taskId) async {  // <-- Task timeout handler.
    // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
    BackgroundFetch.finish(taskId);
  });
  print('[BackgroundFetch] configure success: $status');
}

class Home extends StatefulWidget {
  @override
  MainState createState() => MainState();
}

class MainState extends State<Home> {
  final PageController pageController = PageController(initialPage: 0, keepPage: true);
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await setDisplayMode();
    });
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
            /*MaintenancePage(
              description: "대나무숲에서 익명으로 사연을 공유하세요",
            ),*/
            KishPostListPage(),
            LibraryPage(),
            /*MaintenancePage(
              description: "도서 대출 현황을 쉽게 확인하세요",
            ),*/
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
          items: const <BubbleBottomBarItem>[
            const BubbleBottomBarItem(  // HOME
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
            const BubbleBottomBarItem(  // KISH MAGAZINE
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
            /*const BubbleBottomBarItem(  // KISH 대나무숲
                backgroundColor: Colors.green,
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.green,
                ),
                title: Text("대나무숲")),*/
            const BubbleBottomBarItem(  // KISH 가정통신문
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
            const BubbleBottomBarItem(  // KISH 도서
                backgroundColor: Colors.brown,
                icon: Icon(
                  Icons.book_outlined,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.book_outlined,
                  color: Colors.brown,
                ),
                title: const Text("도서")),
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
