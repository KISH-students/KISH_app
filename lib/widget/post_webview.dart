import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kish2019/kish_api.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PostWebView extends StatefulWidget {
  String menu;
  String id;
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,

        body: Column(
        children: [
          FlatButton.icon(
            icon: Icon(CupertinoIcons.chevron_back), label: Text("돌아가기"),
            onPressed: () {Navigator.pop(
                context);
            },),
          loadingWidget,
          Expanded(
          child: WebView(
            initialUrl: KISHApi.GET_POST_CONTENT_HTML + "?menu=" + widget.menu + "&id=" + widget.id,
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
    );
  }
}