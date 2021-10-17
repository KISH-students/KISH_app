import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/login_view.dart';

import 'noti.dart';

class BambooNoti extends Noti {
  BambooNoti() : super("BambooNoti", -1);

  Future<void> setEnabled(bool v) async {
    await ApiHelper.toggleBambooNotification(v, LoginView.seq);
    await setProperty(propertyName, v);
  }

  Future<bool> toggleStatus() async {
    bool result = !(await isEnabled());
    await this.setEnabled(result);
    return result;
  }
}