import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kish2019/kish_api.dart';
import 'package:kish2019/noti_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Method { get, post }

class ApiHelper {
  static Future<String> request(
      String api, Method method, Map<String, dynamic> params, {doCache: true, int timeout = 999999}) async {
    String url = api;
    http.Response response;

    if (method == Method.get) {
      url += "?";

      params.forEach((key, value) {
        assert (value != null);
        url += key + "=" + value + "&";
      });
    }
    url = Uri.encodeFull(url);

    try {
      if (method == Method.get) {
        response = await http.get(url).timeout(Duration(seconds: timeout));
      } else {
        response = await http.post(url, body: params).timeout(Duration(seconds: timeout));
      }

      if (doCache) {
        saveResult(getCacheKey(api, params), response.body);
      }
    } catch (e) {
      /* Fluttertoast.showToast(
          msg: "정보를 불러오지 못했습니다.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);*/
      String cache = await getCachedResult(getCacheKey(api, params));
      if(cache != null) return cache;
    }
    return response.body;
  }

  static void saveResult(String key, String json) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json);
  }

  static Future<String> getCachedResult(String key) async {
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
      uuid = iosDeviceInfo.identifierForVendor;
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      uuid = androidDeviceInfo.androidId;
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

  static Future<List> getLunch({date: ""}) async {
    if (date == "") {
      date = getTodayDateForLunch();
    }

    String rsJson =
    await request(KISHApi.GET_LUNCH, Method.get, {"date": date});
    List menuList = json.decode(rsJson);
    return menuList;
  }

  static Future<Map> getExamDDay() async {
    String resultJson = await request(KISHApi.GET_EXAM_DATES, Method.get, {});
    List examDates = json.decode(resultJson);
    Map resultMap = examDates.length > 0 ? examDates[0] : null;

    if (resultMap == null) {
      resultMap = {"invalid": true};
    }

    return resultMap;
  }

  @Deprecated("더이상 사용되지 않는 API입니다.")
  static Future<List> getArticleList({String path: ""}) async {
    String resultJson =
    await request(KISHApi.GET_MAGAZINE_ARTICLE, Method.get, {"path": path});
    return json.decode(resultJson);
  }

  static Future<List> getLibraryHome({String parent, String category}) async {
    String resultJson =
    await request(KISHApi.GET_MAGAZINE_HOME, Method.get, {"parent": parent, "category": category});
    print({"parent": parent, "category": category});
    return json.decode(resultJson);
  }

  static Future<List> getLibraryParentList() async {
    String resultJson =
    await request(KISHApi.GET_MAGAZINE_PARENT_LIST, Method.get, {});
    return json.decode(resultJson);
  }

  static Future<List> getLibraryCategoryList({String parent}) async {
    String resultJson =
    await request(KISHApi.GET_MAGAZINE_CATEGORY_LIST, Method.get, {"parent": parent});
    return json.decode(resultJson);
  }

  static Future<List> searchPost(String keyword, int index) async {
    String result = await request(KISHApi.SEARCH_POST, Method.get, {"keyword": keyword, "index": index.toString()}, doCache: false);
    return json.decode(result);
  }

  static Future<List> getPostsByMenu(String menu, String index) async {
    String result = await request(KISHApi.GET_POSTS_BY_MENU, Method.get, {"menu": menu, "page": index}, doCache: false);
    return json.decode(result);
  }

  static Future<List> getLastUpdatedMenuList() async {
    String result = await request(KISHApi.GET_LAST_UPDATED_MENU_LIST, Method.get, {}, doCache: false);
    return json.decode(result);
  }

  static Future<List> getPostAttachments(String menu, String id) async {
    String result = await request(KISHApi.GET_POST_ATTACHMENTS, Method.get, {"menu": menu, "id": id}, doCache: false);
    return json.decode(result);
  }

  static Future<List> getPostListHomeSummary() async {
    String result = await request(KISHApi.GET_POST_LIST_HOME_SUMMARY, Method.get, {});
    return json.decode(result);
  }

  static Future<Map> loginToLibrary(String id, String pw) async {
    String uuid = await getUuid();

    String result = await request(KISHApi.LIBRARY_LOGIN, Method.post, {"uuid": uuid, "id": id, "pwd": pw}, doCache: false);
    print (result + "??!?" + uuid);
    return json.decode(result);
  }

  static Future<Map> getLibraryMyInfo() async {
    String uuid = await getUuid();

    String result = await request(KISHApi.LIBRARY_MY_INFO, Method.get, {"uuid": uuid}, doCache: false);
    return json.decode(result);
  }

  static Future<Map> registerToLibrary(String seq, String id, String pw, String ck) async {
    String uuid = await getUuid();

    String result = await request(
        KISHApi.LIBRARY_REGISTER,
        Method.post,
        {"uuid": uuid, "seq": seq, "id": id, "pwd": pw, "ck": ck},
        doCache: false,
        timeout: 10);
    return json.decode(result);
  }

  static Future<Map> isLibraryMember(String seq, String name) async {
    String result = await request(
        KISHApi.IS_LIBRARY_Member,
        Method.post,
        {"seq": seq, "name": name},
        doCache: false,
        timeout: 10);
    return json.decode(result);
  }
}
