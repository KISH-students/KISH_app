import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kish2019/kish_api.dart';
import 'package:kish2019/noti_manager.dart';
import 'package:kish2019/widget/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Method { get, post }

class ApiHelper {
  static const _androidIdPlugin = AndroidId();

  static Future<String> request(
      String api, Method method, Map<String, String?> params, {doCache: true, int timeout = 10}) async {
    String url = api;
    late http.Response response;

    if (method == Method.get) {
      url += "?";

      params.forEach((key, value) {
        assert (value != null);
        url += "$key=$value&";
      });
    }
    url = Uri.encodeFull(url);
    Uri uri = Uri.parse(url);

    try {
      if (method == Method.get) {
        response = await http.get(uri).timeout(Duration(seconds: timeout));
      } else {
        response = await http.post(uri, body: params).timeout(Duration(seconds: timeout));
      }

      if (doCache) {
        saveResult(getCacheKey(api, params), response.body);
      }
    } catch (e) {
      print(e.toString() + "  ____________________+");
      String? cache = await getCachedResult(getCacheKey(api, params));
      if(cache != null) return cache;
    }
    return response.body;
  }

  static void saveResult(String key, String json) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json);
  }

  static Future<String?> getCachedResult(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static String getCacheKey(String api, Map<String, dynamic> params) {
    return "cache_" + api + "::" + params.toString();
  }

  static Future<String> getUuid() async {
    var deviceInfo = DeviceInfoPlugin();
    String uuid;

    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      uuid = iosDeviceInfo.identifierForVendor!;
    } else {
      uuid = (await _androidIdPlugin.getId())!;
    }

    return uuid;
  }

  static String getTodayDateForLunch() {
    String ym;
    String ymd;
    DateFormat formatter = new DateFormat('yyyy-MM-dd');
    DateTime now = DateTime.now();

    ymd = formatter.format(now);
    formatter = new DateFormat('yyyy-MM');
    ym = formatter.format(now);

    return ymd;
  }

  static Future<List?> getLunch({date: ""}) async {
    if (date == "") {
      date = getTodayDateForLunch();
    }

    String rsJson =
    await request(KISHApi.GET_LUNCH, Method.get, {"date": date});
    List? menuList = json.decode(rsJson);
    return menuList;
  }

  static Future<Map> getExamDDay() async {
    String resultJson = await request(KISHApi.GET_EXAM_DATES, Method.get, {});
    List examDates = json.decode(resultJson);
    Map? resultMap = examDates.length > 0 ? examDates[0] : null;

    if (resultMap == null) {
      resultMap = {"invalid": true};
    }

    return resultMap;
  }

  @Deprecated("더이상 사용되지 않는 API입니다.")
  static Future<List?> getMagazineArticleList({String path: ""}) async {
    String resultJson =
    await request(KISHApi.GET_MAGAZINE_ARTICLE, Method.get, {"path": path, "ios": Platform.isIOS.toString()});
    return json.decode(resultJson);
  }

  static Future<List?> getMagazineHome({String? parent, String? category}) async {
    String resultJson =
    await request(KISHApi.GET_MAGAZINE_HOME, Method.get, {"parent": parent, "category": category, "ios": Platform.isIOS.toString()});
    return json.decode(resultJson);
  }

  static Future<List?> getMagazineParentList() async {
    String resultJson =
    await request(KISHApi.GET_MAGAZINE_PARENT_LIST, Method.get, {});
    return json.decode(resultJson);
  }

  static Future<List?> getMagazineCategoryList({String? parent}) async {
    String resultJson =
    await request(KISHApi.GET_MAGAZINE_CATEGORY_LIST, Method.get, {"parent": parent});
    return json.decode(resultJson);
  }

  static Future<List?> searchPost(String? keyword, int index) async {
    String result = await request(KISHApi.SEARCH_POST, Method.get, {"keyword": keyword, "index": index.toString()}, doCache: false);
    return json.decode(result);
  }

  static Future<List?> getPostsByMenu(String menu, String index) async {
    String result = await request(KISHApi.GET_POSTS_BY_MENU, Method.get, {"menu": menu, "page": index}, doCache: false);
    return json.decode(result);
  }

  static Future<List?> getLastUpdatedMenuList() async {
    String result = await request(KISHApi.GET_LAST_UPDATED_MENU_LIST, Method.get, {}, doCache: false);
    return json.decode(result);
  }

  static Future<List?> getPostAttachments(String? menu, String? id) async {
    String result = await request(KISHApi.GET_POST_ATTACHMENTS, Method.get, {"menu": menu, "id": id}, doCache: false);
    return json.decode(result);
  }

  static Future<List?> getPostListHomeSummary() async {
    String result = await request(KISHApi.GET_POST_LIST_HOME_SUMMARY, Method.get, {});
    return json.decode(result);
  }

  static Future<Map?> loginToLibrary(String? id, String? pw) async {
    String uuid = await getUuid();

    String result = await request(
        KISHApi.LIBRARY_LOGIN,
        Method.post,
        {
          'uuid': uuid,
          'id': id,
          'pwd': pw,
          'fcm': NotificationManager.FcmToken
        },
        doCache: false);
    return json.decode(result);
  }

  static Future<void> logoutFromLibrary() async {
    String result = await request(
        KISHApi.LIBRARY_LOGOUT,
        Method.post,
        {
          'seq': LoginView.seq,
          'fcm': NotificationManager.FcmToken
        },
        doCache: false);
  }

  static Future<Map?> getLibraryMyInfo() async {
    String uuid = await getUuid();

    String result = await request(KISHApi.LIBRARY_MY_INFO, Method.get, {"uuid": uuid}, doCache: false);
    return json.decode(result);
  }

  static Future<Map?> registerToLibrary(String seq, String id, String pw, String ck) async {
    String uuid = await getUuid();

    String result = await request(
        KISHApi.LIBRARY_REGISTER,
        Method.post,
        {"uuid": uuid, "seq": seq, "id": id, "pwd": pw, "ck": ck},
        doCache: false,
        timeout: 10);
    return json.decode(result);
  }

  static Future<Map?> isLibraryMember(String seq, String name) async {
    String result = await request(
        KISHApi.IS_LIBRARY_Member,
        Method.post,
        {"seq": seq, "name": name},
        doCache: false,
        timeout: 10);
    return json.decode(result);
  }

  static Future<List?> getBambooPosts(int page) async {
    // page는 0이 시작
    String response = await request(
        KISHApi.BAMBOO_GET_POSTS,
        Method.get,
        {"page": page.toString()}
    );
    return json.decode(response);
  }

  static Future<Map> getMyBambooPosts(int page) async {
    // page는 0이 시작
    String response = await request(
        KISHApi.BAMBOO_GET_MY_POSTS,
        Method.get,
        {'seq': LoginView.seq, 'fcm': NotificationManager.FcmToken, "page": page.toString()},
      doCache: false
    );
    return json.decode(response);
  }

  static Future<Map> getMyBambooComments(int page) async {
    // page는 0이 시작
    String response = await request(
        KISHApi.BAMBOO_GET_MY_COMMENTS,
        Method.get,
        {'seq': LoginView.seq, 'fcm': NotificationManager.FcmToken, "page": page.toString()},
      doCache: false
    );
    return json.decode(response);
  }

  static Future<Map> writeBambooPost(String seq, String title, String content, bool facebook) async {
    String response = await request(
        KISHApi.BAMBOO_WRITE_POST,
        Method.post,
        {'seq': seq, 'fcm': NotificationManager.FcmToken,
        'title': title, 'content': content, 'fb': facebook.toString()},
      doCache: false
    );
    return json.decode(response);
  }

  static Future<Map> deleteBambooPost(String seq, var postId) async {
    String response = await request(
        KISHApi.BAMBOO_DELETE_POST,
        Method.post,
        {'seq': seq, 'postId': postId.toString(), 'fcm': NotificationManager.FcmToken},
      doCache: false
    );
    return json.decode(response);
  }

  static Future<Map> deleteBambooComment(String seq, var commentId) async {
    String response = await request(
        KISHApi.BAMBOO_DELETE_COMMENT,
        Method.post,
        {'seq': seq, 'commentId': commentId.toString(), 'fcm': NotificationManager.FcmToken},
      doCache: false
    );
    return json.decode(response);
  }

  static Future<Map> getBambooPost(String seq, var postId) async {
    String response = await request(
        KISHApi.BAMBOO_GET_POST,
        Method.get,
        {'seq': seq, 'postId': postId.toString()},
      doCache: false
    );
    return json.decode(response);
  }

  static Future<Map?> getBambooReplies(String seq, var commentId) async {
    String response = await request(
        KISHApi.BAMBOO_GET_REPLIES,
        Method.get,
        {'seq': seq, 'commentId': commentId.toString(),
          'fcm': NotificationManager.FcmToken},
      doCache: false
    );
    return json.decode(response);
  }

  static Future<Map?> writeBambooComment(String seq, var postId, String content) async {
    String response = await request(
        KISHApi.BAMBOO_WRITE_COMMENT,
        Method.post,
        {'seq': seq, 'postId': postId.toString(), 'content': content, 'fcm': NotificationManager.FcmToken},
      doCache: false
    );
    return json.decode(response);
  }

  static Future<Map?> replyBambooComment(String seq, var postId, var parentId, String content) async {
    String response = await request(
        KISHApi.BAMBOO_REPLY,
        Method.post,
        {'seq': seq, 'postId': postId.toString(), 'parentId': parentId.toString(), 'content': content,
          'fcm': NotificationManager.FcmToken},
      doCache: false
    );
    return json.decode(response);
  }

  static Future<Map?> likeBambooPost(String seq, var postId) async {
    String response = await request(
        KISHApi.BAMBOO_LIKE_POST,
        Method.post,
        {'seq': seq, 'fcm': NotificationManager.FcmToken, 'postId': postId.toString()},
      doCache: false
    );
    return json.decode(response);
  }

  static Future<Map?> likeBambooComment(String seq, var commentId) async {
    String response = await request(
        KISHApi.BAMBOO_LIKE_COMMENT,
        Method.post,
        {'seq': seq, 'fcm': NotificationManager.FcmToken, 'commentId': commentId.toString()},
      doCache: false
    );
    return json.decode(response);
  }

  static Future<Map?> unlikeBambooPost(String seq, var postId) async {
    String response = await request(
        KISHApi.BAMBOO_UNLIKE_POST,
        Method.post,
        {'seq': seq, 'fcm': NotificationManager.FcmToken, 'postId': postId.toString()},
      doCache: false
    );
    return json.decode(response);
  }

  static Future<Map?> unlikeBambooComment(String seq, var commentId) async {
    String response = await request(
        KISHApi.BAMBOO_UNLIKE_COMMENT,
        Method.post,
        {'seq': seq, 'fcm': NotificationManager.FcmToken, 'commentId': commentId.toString()},
      doCache: false
    );
    return json.decode(response);
  }

  static Future<void> toggleBambooNotification(bool enable, String seq) async {
    String response = await request(
        KISHApi.BAMBOO_TOGGLE_NOTIFICATION,
        Method.post,
        {'seq': seq, 'fcm': NotificationManager.FcmToken, 'enable': enable.toString()},
      doCache: false
    );
  }

  static Future<Map> getMyBambooNotification(int page, String seq) async {
    String response = await request(
        KISHApi.BAMBOO_MY_NOTIFICATION,
        Method.get,
        {'seq': seq, 'fcm': NotificationManager.FcmToken, 'page': page.toString()},
      doCache: false
    );
    return json.decode(response);
  }
}
