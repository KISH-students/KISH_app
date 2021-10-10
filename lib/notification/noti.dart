import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kish2019/noti_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Noti {
  final String propertyName;
  final int notificationId;

  Noti(this.propertyName, this.notificationId) {}

  Future<bool> isEnabled() async {
    return await getBool(this.propertyName);
  }

  Future<bool> getBool(String key) async {
    SharedPreferences sp =
    await NotificationManager.getInstance().getSharedPreferences();
    bool status = false;

    bool? data = sp.getBool(key);
    if (data != null) {
      status = data;
    }

    return status;
  }

  Future<NotificationDetails> getOngoingAndroidDetails(String id,
      String name, String desc) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        id, name, desc,
        importance: Importance.low,
        priority: Priority.low,
        onlyAlertOnce: true,
        ongoing: true,
        playSound: false,
        autoCancel: false,
        enableVibration: false,
        icon: "kish_icon");
    NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    return platformChannelSpecifics;
  }

  Future<void> setProperty(String key, bool v, {bool subTopic = false}) async {
    SharedPreferences sp =
    await NotificationManager.getInstance().getSharedPreferences();

    sp.setBool(key, v);
    if (Platform.isIOS || subTopic) {
      if (v) FirebaseMessaging.instance.subscribeToTopic(key);
      else FirebaseMessaging.instance.unsubscribeFromTopic(key);
    }
  }

  Future<void> showNoti() async {
    throw UnimplementedError();
  }
}