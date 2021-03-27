import 'package:foreground_service/foreground_service.dart';
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

  final List<String> weekdays = ["", "월", "화", "수", "목", "금", "토", "일"];

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  SharedPreferences preferences;

  int ddayNotiId;
  String ddayTitle;
  String ddayText;
  String lunchMenuTitle;
  String lunchMenuText;

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
/*    SharedPreferences preferences = await SharedPreferences.getInstance();

    showDdayNoti = preferences.getBool("ddayNoti");
    showLunchNoti = preferences.getBool("lunchNoti");*/

    /*if(showDdayNoti == null) showDdayNoti = false;
    if(showLunchNoti == null) showLunchNoti = false;

    if (showLunchNoti){
      startLunchMenuNoti();
    }

    if (showDdayNoti){
      startDdayNoti();
    }

    if (this.showDdayNoti || this.showLunchNoti) {
      main
    } else {
      await ForegroundService.stopForegroundService();
    }*/
  }

  Future<void> loadSharedPreferences() async{
    this.preferences = await SharedPreferences.getInstance();
  }

  Future<bool> isDdayEnabled() async {
    if(this.preferences == null) await loadSharedPreferences();
    return preferences.getBool("ddayNoti");
  }

  Future<bool> isLunchMenuEnabled() async{
    if(this.preferences == null) await loadSharedPreferences();
    return preferences.getBool("lunchNoti");
  }

  Future<void> setDdayEnabled(bool v) async{
    if(this.preferences == null) await loadSharedPreferences();
    this.preferences.setBool("ddayNoti", v);
  }

  Future<void> setLunchMenuEnabled(bool v) async{
    if(this.preferences == null) await loadSharedPreferences();
    this.preferences.setBool("lunchNoti", v);
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
    tz.TZDateTime(tz.local, now.year, now.month, now.day, now.hour);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(minutes: 1));
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

  Future<NotificationDetails> getOngoingNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        '알림 - 종합', '알림 - 종합', '급식 및 dday 알림.',
        importance: Importance.low,
        priority: Priority.low,
        onlyAlertOnce: true,
        ongoing: true,
        playSound: false,
        autoCancel: false,
        enableVibration: false,
        icon: "kish_icon");
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    return platformChannelSpecifics;
  }

/*
  Future<void> startDdayNoti() async {
    NotificationDetails platformChannelSpecifics = await getOngoingNotification();

    await flutterLocalNotificationsPlugin.show(ID_DDAY, 'D-DAY : 불러오는 중',
        '잠시만 기다려 주세요', platformChannelSpecifics);

    showDdayNotification(platformChannelSpecifics);

    while (true) {
      if(!showDdayNoti) {
        stopDdayNoti();
        break;
      }
      await Future<void>.delayed(const Duration(seconds: 60), () async {
        showDdayNotification(platformChannelSpecifics);
      });
    }
  }

  Future<void> stopDdayNoti() async {
    await flutterLocalNotificationsPlugin.cancel(ID_DDAY);
  }
*/

  Future<void> showDdayNotification () async {
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

    int notiId = await this.isLunchMenuEnabled() ? 2 : 1;

    if(title != ddayTitle || body != ddayText || ddayNotiId != notiId) {
      this.ddayTitle = title;
      this.ddayText = body;
      this.ddayNotiId = notiId;
      dynamic detail = await getOngoingNotification();

      flutterLocalNotificationsPlugin.show(notiId, ddayTitle, ddayText, detail);
    }

    /*flutterLocalNotificationsPlugin.show(ID_DDAY, title ,
        body, platformChannelSpecifics);*/
  }

/*  Future<void> startLunchMenuNoti() async {
    NotificationDetails platformChannelSpecifics = await getOngoingNotification();

    await flutterLocalNotificationsPlugin.show(ID_LUNCH, '오늘의 급식',
        '가져오는 중', platformChannelSpecifics);

    showLunchMenuNotification(platformChannelSpecifics);

    while (true) {
      if(!showLunchNoti) {
        stopLunchMenuNoti();
        break;
      }
      await Future<void>.delayed(const Duration(seconds: 60), () async {
        //stopLunchMenuNoti();
        showLunchMenuNotification(platformChannelSpecifics);
      });
    }
  }*/

/*  Future<void> stopLunchMenuNoti() async {
    await flutterLocalNotificationsPlugin.cancel(ID_LUNCH);
  }*/
  int i =1;
  Future<void> showLunchMenuNotification() async {
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

    dynamic detail = await getOngoingNotification();

    result.forEach((element) {
      if (found) return;

      Map data = element;
      if (timestamp <= data["timestamp"]) {
        String date = data["date"];
        String content = (data["menu"] as String).replaceAll(",", "\n");

        String title = "급식 알림 ·" + weekdays[DateTime.tryParse(date).weekday] + "요일";
        String text = content;

        if(title != ddayTitle || text != ddayText) {
          this.ddayTitle = title;
          this.ddayText = text;
/*
          ForegroundService.notification.startEditMode();
          ForegroundService.notification.setTitle(this.notiTitle);
          ForegroundService.notification.setText(this.notiText);*/
          flutterLocalNotificationsPlugin.show(1, ddayTitle, ddayText, detail);
        }
        found = true;
      }
    });
  }
}