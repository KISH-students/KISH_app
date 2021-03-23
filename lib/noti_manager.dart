import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  static NotificationManager instance;
  static final int ID_LUNCH = 0;
  static final int ID_DDAY = 1;

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool showLunchNoti = false;
  bool showDdayNoti = false;

  static NotificationManager getInstance() {
    return instance;
  }

  NotificationManager() {
    if(instance != null) throw new Exception(["이미 다른 인스턴스가 존재합니다."]);

    instance = this;
  }

  Future<void> startNoti() async{
    await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('kish_icon');

    checkSettings();
    //await _scheduleDailyTenAMNotification();
  }

  Future<void> checkSettings() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    showDdayNoti = preferences.getBool("ddayNoti");
    showLunchNoti = preferences.getBool("lunchNoti");

    if(showDdayNoti == null) showDdayNoti = false;
    if(showLunchNoti == null) showLunchNoti = false;

    if (showLunchNoti){
      startLunchMenuNoti();
    }

    if (showDdayNoti){
      startDdayNoti();
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  // 알림 스케줄 예제입니다.
/*
  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, 2, 28);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> _scheduleDailyTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'daily scheduled notification title',
        'daily scheduled notification body',
        _nextInstanceOfTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'daily notification channel id',
              'daily notification channel name',
              'daily notification description',
              icon: "kish_icon"),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }*/

  Future<NotificationDetails> _getOngoingNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        '알림 - 종합', '알림 - 종합', '급식 및 dday 알림.',
        importance: Importance.low,
        priority: Priority.low,
        onlyAlertOnce: true,
        ongoing: true,
        playSound: false,
        autoCancel: false,
        icon: "kish_icon");
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    return platformChannelSpecifics;
  }

  Future<void> startDdayNoti() async {
    NotificationDetails platformChannelSpecifics = await _getOngoingNotification();

    await flutterLocalNotificationsPlugin.show(ID_DDAY, 'D-DAY : 불러오는 중',
        '잠시만 기다려 주세요', platformChannelSpecifics);

    _showDdayNoti(platformChannelSpecifics);

    while (true) {
      if(!showDdayNoti) {
        stopLunchMenuNoti();
        break;
      }
      await Future<void>.delayed(const Duration(seconds: 60), () async {
        _showLunchMenuNoti(platformChannelSpecifics);
      });
    }
  }

  Future<void> stopDdayNoti() async {
    await flutterLocalNotificationsPlugin.cancel(ID_DDAY);
  }

  Future<void> _showDdayNoti (NotificationDetails platformChannelSpecifics) async {
    Map data = await ApiHelper.getExamDDay();

    String title;
    String body;

    if (data["invalid"] != null) {
      title = "D-Day : 정보 없음";
      body = "정보가 없습니다.";
    }else{
      DateTime date = DateTime.fromMillisecondsSinceEpoch(data["timestamp"] * 1000);
      DateTime now = DateTime.now();
      int diffDays = date.difference(now).inDays;

      title = data["label"] + " (" + data["date"] + ")";
      body = (diffDays + 1).toString() + "일 남음";
    }

    flutterLocalNotificationsPlugin.show(ID_DDAY, title ,
        body, platformChannelSpecifics);
  }

  Future<void> startLunchMenuNoti() async {
    NotificationDetails platformChannelSpecifics = await _getOngoingNotification();

    await flutterLocalNotificationsPlugin.show(ID_LUNCH, '오늘의 급식',
        '가져오는 중', platformChannelSpecifics);

    _showLunchMenuNoti(platformChannelSpecifics);

    while (true) {
      if(!showLunchNoti) {
        stopLunchMenuNoti();
        break;
      }
      await Future<void>.delayed(const Duration(seconds: 60), () async {
        _showLunchMenuNoti(platformChannelSpecifics);
      });
    }
  }

  Future<void> stopLunchMenuNoti() async {
    await flutterLocalNotificationsPlugin.cancel(ID_LUNCH);
  }

  Future<void> _showLunchMenuNoti(NotificationDetails platformChannelSpecifics) async {
    DateTime tmpDate = DateTime.now();
    DateTime today = DateTime(tmpDate.year, tmpDate.month, tmpDate.day);
    int timestamp = (today.millisecondsSinceEpoch / 1000).round();
    bool found = false;

    List result;
    try {
      result = await ApiHelper.getLunch();
    } catch (ignore) {
      return;
    }

    result.forEach((element) {
      if (found) return;

      Map data = element;
      if (timestamp <= data["timestamp"]) {
        String date = data["date"];
        String content = (data["menu"] as String).replaceAll(",", "\n");

        flutterLocalNotificationsPlugin.show(ID_LUNCH, '오늘의 급식 - ' + date ,
            content, platformChannelSpecifics);
        found = true;
      }
    });
  }
}