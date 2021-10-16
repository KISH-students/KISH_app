import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kish2019/notification/dday_noti.dart';
import 'package:kish2019/notification/lunch_menu_noti.dart';
import 'package:kish2019/notification/new_bamboo_post_noti.dart';
import 'package:kish2019/notification/new_kish_post_noti.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager {
  static NotificationManager? _instance;
  static final FlutterLocalNotificationsPlugin notiPlugin =
  FlutterLocalNotificationsPlugin();

  static String? FcmToken = "";
  static bool isFcmSupported = true;
  late DdayNoti ddayNoti;
  late LunchMenuNoti lunchMenuNoti;
  late NewKishPostNoti newKishPostNoti;
  late NewBambooPostNoti newBambooPostNoti;

  SharedPreferences? preferences;

  static NotificationManager getInstance() {
    if (_instance == null) {
      _instance = new NotificationManager();
    }
    return _instance as NotificationManager;
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
    this.newBambooPostNoti = new NewBambooPostNoti();
  }

  static Future<bool> checkIosNotificationPermission() async {
    PermissionStatus permissionStatus = await NotificationPermissions.getNotificationPermissionStatus();
    return permissionStatus == PermissionStatus.granted;
  }

  static Future<void> requestIosNotificationPermission() async {
    await NotificationPermissions.requestNotificationPermissions(iosSettings: const NotificationSettingsIos(
        sound: true,
        badge: true,
        alert: true
    ), openSettings: true);
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