import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kish2019/notification/dday_noti.dart';
import 'package:kish2019/notification/lunch_menu_noti.dart';
import 'package:kish2019/notification/new_kish_post_noti.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager {
  static late NotificationManager instance;
  static final FlutterLocalNotificationsPlugin notiPlugin =
  FlutterLocalNotificationsPlugin();

  static String? FcmToken = "";
  static bool isFcmSupported = true;
  late DdayNoti ddayNoti;
  late LunchMenuNoti lunchMenuNoti;
  late NewKishPostNoti newKishPostNoti;

  SharedPreferences? preferences;

  static NotificationManager getInstance() {
    return instance;
  }

  NotificationManager() {
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

    this.lunchMenuNoti = new LunchMenuNoti();
    this.ddayNoti = new DdayNoti();
    this.newKishPostNoti = new NewKishPostNoti();
  }

  Future<void> loadSharedPreferences() async{
    this.preferences = await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> getSharedPreferences() async{
    if (this.preferences == null) await loadSharedPreferences();
    return this.preferences as SharedPreferences;
  }

  Future<void> updateNotifications() async {
    if(await lunchMenuNoti.isLunchEnabled() || await lunchMenuNoti.isDinnerEnabled()) {
      await lunchMenuNoti.showNoti();
    }

    if(await ddayNoti.isEnabled()) await ddayNoti.showNoti();
  }
}