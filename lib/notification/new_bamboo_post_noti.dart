import 'package:firebase_messaging/firebase_messaging.dart';

import 'noti.dart';

class NewBambooPostNoti extends Noti {
  NewBambooPostNoti() : super("newBambooPost", -1);

  Future<void> setEnabled(bool v) async {
    await setProperty(propertyName, v);
    if (v) FirebaseMessaging.instance.subscribeToTopic(propertyName);
    else FirebaseMessaging.instance.unsubscribeFromTopic(propertyName);
  }

  Future<bool> toggleStatus() async {
    bool result = !(await isEnabled());
    await this.setEnabled(result);

    if (result) FirebaseMessaging.instance.subscribeToTopic(propertyName);
    else FirebaseMessaging.instance.unsubscribeFromTopic(propertyName);

    return result;
  }
}