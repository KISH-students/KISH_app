import 'package:kish2019/noti_manager.dart';
import 'package:kish2019/notification/noti.dart';
import 'package:kish2019/tool/api_helper.dart';

class LunchMenuNoti extends Noti {
  static const List<String> weekdays = ["", "월", "화", "수", "목", "금", "토", "일"];
  final String lunchName = "lunchNoti";
  final String dinnerName = "dinnerNoti";
  final int lunchNotiId = 3;
  final int dinnerNotiId = 4;

  LunchMenuNoti() : super ("lunchNoti", 3);

  @override
  Future<bool> isEnabled() {
    throw Exception();  // 사용 금지
  }

  Future<void> setLunchEnabled(bool b) async {
    await setProperty(lunchName, b);
  }

  Future<void> setDinnerEnabled(bool b) async {
    await setProperty(dinnerName, b);
  }

  Future<bool> toggleLunch() async {
    bool newStatus = !(await isLunchEnabled());
    await this.setLunchEnabled(newStatus);

    if (!newStatus) NotificationManager.notiPlugin.cancel(lunchNotiId);
    return newStatus;
  }

  Future<bool> toggleDinner() async {
    bool newStatus = !(await isDinnerEnabled());
    await this.setDinnerEnabled(newStatus);

    if (!newStatus) NotificationManager.notiPlugin.cancel(dinnerNotiId);
    return newStatus;
  }

  Future<bool> isLunchEnabled() async {
    return getBool(this.lunchName);
  }

  Future<bool> isDinnerEnabled() async {
    return getBool(this.dinnerName);
  }

  @override
  Future<void> showNoti() async {
    DateTime tmpDate = DateTime.now();
    DateTime today = DateTime(tmpDate.year, tmpDate.month, tmpDate.day);
    int timestamp = (today.millisecondsSinceEpoch / 1000).round();
    bool foundMenu = false;

    List? result;
    try {
      result = await ApiHelper.getLunch();
    } catch (ignore) {
      return;
    }

    dynamic detail = await getOngoingAndroidDetails("급식", "급식 알림", "석식을 포함한 급식 메뉴 알림이 표시됩니다.");

    result!.forEach((element) async {
      if (foundMenu) return;

      Map data = element;
      if (timestamp <= data["timestamp"]) {
        String date = data["date"];
        String title = weekdays[DateTime.tryParse(date)!.weekday] + "요일";
        String content;

        if (await isLunchEnabled()) {
          content = data["menu"];
          NotificationManager.notiPlugin.show(
              lunchNotiId, "급식 알림 · " + title, content, detail);
        }

        if (await isDinnerEnabled()) {
          content = data["dinnerMenu"];
          NotificationManager.notiPlugin.show(
              dinnerNotiId, "석식 알림 · " + title, content, detail);
        }
        foundMenu = true;
      }
    });
  }
}