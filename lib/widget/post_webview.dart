import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kish2019/kish_api.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PostWebView extends StatefulWidget {
  String? menu;
  String? id;
  PostWebView({this.menu, this.id});

  @override
  _PostWebViewState createState() {
    return _PostWebViewState();
  }
}

class _PostWebViewState extends State<PostWebView> {
  Widget loadingWidget = Container();
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,

        body: Container(
            margin: EdgeInsets.only(top: 15, left: 15, right: 15),
            child: Column(
                children: [
                  FlatButton.icon(
                    icon: Icon(CupertinoIcons.chevron_back), label: Text("돌아가기"),
                    onPressed: () {Navigator.pop(
                        context);
                    },),
                  Card(
                      elevation: 5,
                      child: Container(
                          width: double.infinity,
                          child: FutureBuilder(
                            future: ApiHelper.getPostAttachments(widget.menu, widget.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                if (snapshot.hasData) {
                                  List data = snapshot.data as List;
                                  List<Widget> widgets = [];

                                  data.forEach((element) {
                                    widgets.add(
                                      FlatButton(
                                          minWidth: double.infinity,
                                          onPressed: (){launch(element["url"]);},
                                          child: Row(
                                              children: [
                                                Icon(CupertinoIcons.archivebox, color: Colors.redAccent),
                                                Text("  " + element["name"])
                                              ])
                                      ),
                                    );
                                  });

                                  return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: widgets
                                  );
                                } else {
                                  return Text("첨부파일을 불러오지 못했습니다.");
                                }
                              } else {
                                return LinearProgressIndicator();
                              }
                            },
                          )
                      )
                  ),
                  loadingWidget,
                  Expanded(
                      child: WebView(
                        initialUrl: KISHApi.GET_POST_CONTENT_HTML + "?menu=" + widget.menu! + "&id=" + widget.id!,
                        onWebViewCreated: (url){
                          setState(() {
                            loadingWidget = LinearProgressIndicator(backgroundColor: Colors.grey);
                          });},
                        onPageFinished: (url){
                          setState(() {
                            loadingWidget = Container(height: 2,);
                          });},
                      )),
                ])
        ));
  }
}