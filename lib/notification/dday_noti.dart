import 'package:kish2019/noti_manager.dart';
import 'package:kish2019/notification/noti.dart';
import 'package:kish2019/tool/api_helper.dart';

class DdayNoti extends Noti {
  String notiTitle = "";
  String notiContent = "";

  DdayNoti() : super("ddayNoti", 2);

  Future<void> setEnabled(bool v) async {
    await setProperty(propertyName, v);

    if (v == false) {
      notiTitle = "";
      notiContent = "";
    }
  }

  Future<bool> toggleStatus() async {
    bool newStatus = !(await isEnabled());
    await this.setEnabled(newStatus);

    if (!newStatus) NotificationManager.notiPlugin.cancel(notificationId);
    return newStatus;
  }

  @override
  Future<void> showNoti() async {
    DateTime now = DateTime.now();
    Map data = await ApiHelper.getExamDDay();

    String title;
    String content;

    if (data["invalid"] != null) {
      title = "D-Day : 정보 없음";
      content = "정보가 없습니다.";
    } else {
      // 급식의 날짜
      DateTime date = DateTime.fromMillisecondsSinceEpoch(data["timestamp"] * 1000);
      title = data["label"] + " (" + data["date"] + ")";

      if (date.month == now.month && date.day == now.day) {   // 오늘?
        content = "D - DAY";
      } else {
        int diffDays = date.difference(now).inDays + 1;
        content = "$diffDays일 남음";
      }
    }

    if(title != this.notiTitle || content != this.notiContent) {
      this.notiTitle = title;
      this.notiContent = content;
      dynamic detail =
      await getOngoingAndroidDetails("dday", "D-DAY 알림");

      NotificationManager.notiPlugin
          .show(notificationId, title, content, detail);
    }
  }
}