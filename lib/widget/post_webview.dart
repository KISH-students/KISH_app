import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kish2019/kish_api.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share/share.dart';

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
  bool isExpanded = false;
  Widget loadingWidget = Container();
  late Future<List?> _attachmentFuture;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    _attachmentFuture = ApiHelper.getPostAttachments(widget.menu, widget.id);
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: Icon(CupertinoIcons.chevron_back), label: Text("돌아가기"),
                          onPressed: () {Navigator.pop(
                              context);
                          },),
                        IconButton(
                          icon: Icon(CupertinoIcons.arrowshape_turn_up_right),
                          onPressed: (){
                            String url = "http://hanoischool.net/?menu_no=${widget.menu}&board_mode=view&bno=${widget.id}";
                            Share.share(url);
                          },
                        )
                      ]),
                  Card(
                      elevation: 5,
                      child: Container(
                          width: double.infinity,
                          child: FutureBuilder(
                            future: _attachmentFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                if (snapshot.hasData) {
                                  List data = snapshot.data as List;
                                  List<Widget> widgets = [];

                                  data.forEach((element) {
                                    widgets.add(
                                      ButtonTheme(
                                        minWidth: double.infinity,
                                        child: TextButton(
                                            onPressed: (){
                                              launch(
                                                  element["url"],
                                                  forceSafariVC: false
                                              );
                                            },
                                            child: Row(
                                                children: [
                                                  Icon(CupertinoIcons.archivebox, color: Colors.redAccent),
                                                  Text("  " + element["name"])
                                                ])
                                        ),
                                      ),
                                    );
                                  });

                                  return ExpansionPanelList(
                                      expansionCallback: (panelIndex, isExpanded) {
                                        setState(() {
                                          this.isExpanded = !isExpanded;
                                        });
                                      },
                                      children: [
                                        ExpansionPanel(
                                          headerBuilder: (BuildContext context, bool isExpanded) {
                                            return Container(
                                                margin: EdgeInsets.only(left: 2, top: 10),
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text("첨부파일을 보려면 화살표를 누르세요 (${widgets.length})",
                                                        style: TextStyle(
                                                            fontFamily: "IBM",
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold),),
                                                    ])
                                            );
                                          },
                                          isExpanded: this.isExpanded,
                                          body: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: widgets,
                                          ),
                                        )
                                      ]);
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
                        javascriptMode: JavascriptMode.unrestricted,
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