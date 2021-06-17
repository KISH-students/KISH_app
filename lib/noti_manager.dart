import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager {
  static String FcmToken = "";
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static NotificationManager instance;
  static const List<String> weekdays = ["", "월", "화", "수", "목", "금", "토", "일"];
  static const DDAY_NOTIFICATION_ID = 2;
  static const LUNCH_NOTIFICATION_ID = 3;
  static const DINNER_NOTIFICATION_ID = 4;

  static bool isFcmSupported = true;

  SharedPreferences preferences;

  String ddayTitle;
  String ddayText;

  static NotificationManager getInstance() {
    return instance;
  }

  NotificationManager() {
    if(instance != null) throw new Exception(["이미 다른 인스턴스가 존재합니다."]);

    instance = this;
  }

  Future<void> init() async{
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('kish_icon');
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
      var version = iosInfo.systemVersion;
      isFcmSupported = !version.startsWith("9."); // ios 9에서 FCM이 작동하지 않습니다.
    }
  }

  Future<void> loadSharedPreferences() async{
    this.preferences = await SharedPreferences.getInstance();
  }

  Future<bool> isPropertyEnabled(String key) async {
    if (this.preferences == null) await loadSharedPreferences();
    bool result = preferences.getBool(key);

    return result == null ? false : result;
  }

  Future<bool> isDdayEnabled() async {
    return await isPropertyEnabled("ddayNoti");
  }

  Future<bool> toggleDday() async {
    bool result = !(await isDdayEnabled());
    await this.setDdayEnabled(result);

    if (!result) flutterLocalNotificationsPlugin.cancel(DDAY_NOTIFICATION_ID);
    return result;
  }

  Future<bool> toggleLunch() async {
    bool result = !(await isLunchEnabled());
    await this.setLunchEnabled(result);

    if (!result) flutterLocalNotificationsPlugin.cancel(LUNCH_NOTIFICATION_ID);
    return result;
  }

  Future<bool> toggleNewKishPost() async {
    bool result = !(await isNewKishPostEnabled());
    await this.setNewKishPostEnabled(result);

    return result;
  }

  Future<bool> toggleDinner() async {
    bool result = !(await isDinnerEnabled());
    await this.setDinnerEnabled(result);

    if (!result) flutterLocalNotificationsPlugin.cancel(DINNER_NOTIFICATION_ID);
    return result;
  }

  Future<bool> isNewKishPostEnabled() async{
    return await isPropertyEnabled("newKishPostNoti");
  }

  Future<bool> isLunchEnabled() async{
    return await isPropertyEnabled("lunchNoti");
  }

  Future<bool> isDinnerEnabled() async{
    return await isPropertyEnabled("dinnerNoti");
  }

  Future<void> setProperty(String key, bool v, {bool  subTopic = false}) async {
    if (this.preferences == null) await loadSharedPreferences();
    this.preferences.setBool(key, v);
    if (Platform.isIOS || subTopic) {
      if (v) FirebaseMessaging.instance.subscribeToTopic(key);
      else FirebaseMessaging.instance.unsubscribeFromTopic(key);
    }
  }

  Future<void> setDdayEnabled(bool v) async{
    return await setProperty("ddayNoti", v);
  }

  Future<void> setNewKishPostEnabled(bool v) async{
    return await setProperty("newKishPostNoti", v, subTopic: true);
  }

  Future<void> setLunchEnabled(bool v) async{
    return await setProperty("lunchNoti", v);
  }

  Future<void> setDinnerEnabled(bool v) async{
    return await setProperty("dinnerNoti", v);
  }

  Future<void> updateNotifications() async {
    if(await this.isLunchEnabled() || await this.isDinnerEnabled()) await this.showLunchMenuNotification();
    if(await this.isDdayEnabled()) await this.showDdayNotification();
  }

  Future<NotificationDetails> getOngoingAndroidDetails() async {
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

  Future<void> showDdayNotification () async {
    DateTime now = DateTime.now();
    /* if(now.day == ddayStartDay) return;
    ddayStartDay = now.day;*/

    Map data = await ApiHelper.getExamDDay();

    String title;
    String body;

    if (data["invalid"] != null) {
      title = "D-Day : 정보 없음";
      body = "정보가 없습니다.";
    } else {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(data["timestamp"] * 1000);
      title = data["label"] + " (" + data["date"] + ")";

      if (date.month == now.month && date.day == now.day) {
        body = "D - DAY";
      } else {
        int diffDays = date
            .difference(now)
            .inDays;

        body = (diffDays + 1).toString() + "일 남음";
      }
    }

    if(title != ddayTitle || body != ddayText) {
      this.ddayTitle = title;
      this.ddayText = body;
      dynamic detail = await getOngoingAndroidDetails();

      flutterLocalNotificationsPlugin.show(DDAY_NOTIFICATION_ID, ddayTitle, ddayText, detail);
    }
  }

  Future<void> showLunchMenuNotification() async {
    DateTime tmpDate = DateTime.now();
    DateTime today = DateTime(tmpDate.year, tmpDate.month, tmpDate.day);
    int timestamp = (today.millisecondsSinceEpoch / 1000).round();
    bool isFound = false;

    List result;
    try {
      result = await ApiHelper.getLunch();
    } catch (ignore) {
      return;
    }

    dynamic detail = await getOngoingAndroidDetails();

    result.forEach((element) async {
      if (isFound) return;

      Map data = element;
      if (timestamp <= data["timestamp"]) {
        String date = data["date"];
        String title = weekdays[DateTime.tryParse(date).weekday] + "요일";
        String content;

        if (await isLunchEnabled()) {
          content = (data["menu"] as String).replaceAll(",", "\n");
          flutterLocalNotificationsPlugin.show(
              LUNCH_NOTIFICATION_ID, "급식 알림 · " + title, content, detail);
        }

        if (await isDinnerEnabled()) {
          content = (data["dinnerMenu"] as String).replaceAll(",", "\n");
          flutterLocalNotificationsPlugin.show(
              DINNER_NOTIFICATION_ID, "석식 알림 · " + title, content, detail);
        }
        isFound = true;
      }
    });
  }
}