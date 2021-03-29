import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static NotificationManager instance;

  final List<String> weekdays = ["", "월", "화", "수", "목", "금", "토", "일"];

  SharedPreferences preferences;

  int ddayStartDay = -1;
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

  Future<void> init() async{
    await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('kish_icon');
  }

  Future<void> loadSharedPreferences() async{
    this.preferences = await SharedPreferences.getInstance();
  }

  Future<bool> isDdayEnabled() async {
    if(this.preferences == null) await loadSharedPreferences();
    bool result =  preferences.getBool("ddayNoti");

    return result == null ? false : result;
  }

  Future<bool> isLunchMenuEnabled() async{
    if(this.preferences == null) await loadSharedPreferences();
    bool result = preferences.getBool("lunchNoti");

    return result == null ? false : result;
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

  Future<void> updateNotifications() async {
    if(await this.isLunchMenuEnabled()) await this.showLunchMenuNotification();
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
    }else{
      DateTime date = DateTime.fromMillisecondsSinceEpoch(data["timestamp"] * 1000);
      int diffDays = date.difference(now).inDays;

      title = data["label"] + " (" + data["date"] + ")";
      body = (diffDays + 1).toString() + "일 남음";
    }

    int notificationId = await this.isLunchMenuEnabled() ? 2 : 1;

    if(title != ddayTitle || body != ddayText || ddayNotiId != notificationId) {
      this.ddayTitle = title;
      this.ddayText = body;
      this.ddayNotiId = notificationId;
      dynamic detail = await getOngoingAndroidDetails();

      flutterLocalNotificationsPlugin.show(notificationId, ddayTitle, ddayText, detail);
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

    result.forEach((element) {
      if (isFound) return;

      Map data = element;
      if (timestamp <= data["timestamp"]) {
        String date = data["date"];
        String content = (data["menu"] as String).replaceAll(",", "\n");

        String title = "급식 알림 ·" + weekdays[DateTime.tryParse(date).weekday] + "요일";
        String text = content;

        if(title != ddayTitle || text != ddayText) {
          this.ddayTitle = title;
          this.ddayText = text;

          flutterLocalNotificationsPlugin.show(1, ddayTitle, ddayText, detail);
        }
        isFound = true;
      }
    });
  }
}