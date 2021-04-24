import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kish2019/kish_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Method { get, post }

class ApiHelper {
  static Future<String> request(
      String api, Method method, Map<String, dynamic> params) async {
    String url = api;
    var response;

    if (method == Method.get) {
      url += "?";

      params.forEach((key, value) {
        url += key + "=" + value + "&";
      });
    }
    url = Uri.encodeFull(url);

    try {
      if (method == Method.get) {
        response = await http.get(url);
      } else {
        response = await http.post(url, body: params);
      }

      saveResult(getCacheKey(api, params), response.body);
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

  static Future<List> getArticleList({String path: ""}) async {
    String resultJson =
    await request(KISHApi.GET_MAGAZINE_ARTICLE, Method.get, {"path": path});
    return json.decode(resultJson);
  }
}
