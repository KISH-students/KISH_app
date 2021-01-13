import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kish2019/kish_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Method{ get, post }

class ApiHelper{
  static Future<String> request(String api, Method method, Map<String, dynamic> params) async{
    String url;
    var response;

    if(method == Method.get){
      api += "?";

      params.forEach((key, value) {
        api += key + "=" + value + "&";
      });
    }
    url = Uri.encodeFull(api);

    try {
      if (method == Method.get) {
        response = await http.get(url);
      } else {
        response = await http.post(url, body: params);
      }
    }catch(e){
      Fluttertoast.showToast(
          msg: "정보를 불러오지 못했어요",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    return response.body;
  }

  static void saveResult(String key, String json) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("cache_" + key, json);
  }

  static Future<String> getResult(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getString("cache_" + key);
  }

  static Future<List> getLunch({date:""}) async {
    String ym;
    String ymd;

    if(date == ""){
      DateFormat formatter = new DateFormat('yyyy-MM-dd');
      DateTime now = DateTime.now();

      ymd = formatter.format(now);
      formatter = new DateFormat('yyyy-MM');
      ym = formatter.format(now);

      date = ymd;
    }

    String rsJson = await request(KISHApi.GET_LUNCH, Method.get, {"date": date});
    List menuList = json.decode(rsJson);
    return menuList;
  }

  static Future<Map> getExamDDay() async{
    String resultJson = await request(KISHApi.GET_EXAM_DATES, Method.get, {});
    List examDates = json.decode(resultJson);

    DateTime tmpDate = DateTime.now();
    DateTime today = DateTime(tmpDate.year, tmpDate.month, tmpDate.day);
    int timestamp = (today.millisecondsSinceEpoch / 1000).round();

    Map rs;

    examDates.forEach((element) {
      Map data = element;
      if(timestamp <= data["timestamp"]){
        rs = data;
        return;
      }
    });

    if(rs == null){
      rs = {"invalid" : true};
    }

    return rs;
  }

  static Future<List> getArticleList({String path: ""}) async {
    String resultJson = await request(KISHApi.GET_MAGAZINE_ARTICLE, Method.get, {"path": path});
    return json.decode(resultJson);
  }

}