import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kish2019/noti_manager.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/bamboo_post_viewer.dart';
import 'package:kish2019/widget/login_view.dart';

class BambooPage extends StatefulWidget {
  BambooPage({Key? key}) : super(key: key);

  @override
  _BambooPageState createState() {
    return _BambooPageState();
  }
}

class _BambooPageState extends State<BambooPage> with AutomaticKeepAliveClientMixin<BambooPage>{
  final FlutterSecureStorage storage = new FlutterSecureStorage();
  PagingController<int, _PostPreview> pagingController = new PagingController(firstPageKey: 0);
  List<_PostPreview> previewList = [];
  late Widget newBambooPostNotiIcon;
  late Widget bambooNotiIcon;

  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener((pageKey) {
      updatePage(pageKey);
    });
    NotificationManager manager = NotificationManager.getInstance();

    newBambooPostNotiIcon = FutureBuilder(
        future: manager.newBambooPostNoti.isEnabled(),
        initialData: "loading",
        builder: (context, snapshot) {
          if(snapshot.data == "loading") return Icon(Icons.sync);
          if(snapshot.data == true) return Icon(Icons.notifications_active);
          return Icon(Icons.notifications_active_outlined);
        });

    bambooNotiIcon = FutureBuilder(
        future: manager.bambooNoti.isEnabled(),
        initialData: "loading",
        builder: (context, snapshot) {
          if(snapshot.data == "loading") return Icon(Icons.sync);
          if(!LoginView.isLoggined) return Icon(Icons.notifications_active_outlined);
          if(snapshot.data == true) return Icon(Icons.notifications_active);
          return Icon(Icons.notifications_active_outlined);
        });
  }

  @override
  void dispose() {
    super.dispose();
    pagingController.dispose();
  }

  void refreshPage() {
    previewList = [];
    pagingController.refresh();
  }

  void updatePage(int key) async{
    List? list = await ApiHelper.getBambooPosts(key);
    List<_PostPreview> newPosts = [];

    if (list != null) {
      if (list.length == 0) {
        pagingController.appendLastPage([]);
        return;
      }

      list.forEach((element) {
        _PostPreview preview = new _PostPreview(
          id: element['bamboo_id'],
          title: element['bamboo_title'],
          content: element['bamboo_content'],
          likes: element['like_count'],
          comments: element['comment_count'],
        );
        newPosts.add(preview);
      });

      this.previewList.addAll(newPosts);
      pagingController.appendPage(newPosts, key + 1);
    } else {
      pagingController.appendPage([], key);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color loginButtonColor;
    String loginButtonText;
    if (LoginView.isLoggined) {
      loginButtonColor = Colors.redAccent;
      loginButtonText = "로그아웃 하기";
    } else {
      loginButtonColor = Colors.green;
      loginButtonText = "로그인 하기";
    }

    return SafeArea(
      child: Container(
          child: Column(
            key: UniqueKey(),
            children: [
              SizedBox(height: 8),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      child: Text("익명으로 글 쓰기"),
                      onPressed: () async {
                        String? id = await storage.read(key: "id");
                        String? pw = await storage.read(key: "pw");

                        if(id == null || pw == null) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => LoginView()));
                        } else {
                          if (LoginView.isLoggined) {
                            await Navigator.pushNamed(context, "writing");
                            refreshPage();
                          } else {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => LoginView()));
                          }
                        }
                      },
                      color: Colors.black87,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    Container(width: 5),
                    CupertinoButton(
                      child: Text(loginButtonText),
                      color: loginButtonColor, onPressed: () async {
                      if (LoginView.isLoggined) {
                        try {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("로그아웃 중 ...")));
                          await LoginView.logout();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("로그아웃 성공")));
                        } catch (e) {
                          print(e);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("로그아웃에 실패하였습니다. 인터넷을 확인해주세요.")));
                        }
                      } else {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (context) => LoginView()));
                      }
                      setState(() {});
                    },
                      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                    ),
                  ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        alignment: Alignment.center,
                        child: FlatButton.icon(
                            onPressed: NotificationManager.isFcmSupported
                                ? updateNewPostNoti
                                : () {Fluttertoast.showToast(msg: "이 기기에서 지원되지 않습니다.");},
                            icon: this.newBambooPostNotiIcon,
                            label: const Text("새 글 알림")
                        )
                    ),
                    Container(
                        alignment: Alignment.center,
                        child: FlatButton.icon(
                            onPressed: NotificationManager.isFcmSupported
                                ? updateBambooNoti
                                : () {Fluttertoast.showToast(msg: "이 기기에서 지원되지 않습니다.");},
                            icon: this.bambooNotiIcon,
                            label: const Text("댓글 알림")
                        )
                    ),
                  ]),
              SizedBox(height: 10,),
              Expanded(
                child: RefreshIndicator(
                    onRefresh: () async { refreshPage(); },
                    child: PagedListView<int, _PostPreview>(
                      pagingController: pagingController,
                      builderDelegate: PagedChildBuilderDelegate<_PostPreview>(
                          itemBuilder: (context, item, index) {
                            return this.previewList[index];
                          }
                      ),
                    )
                ),
              )
            ],
          )
      ),
    );
  }

  Future<void> updateNewPostNoti() async{
    if(Platform.isIOS) {
      bool perm = await NotificationManager.checkIosNotificationPermission();
      if (!perm) {
        NotificationManager.requestIosNotificationPermission();
        return;
      }
    }

    NotificationManager manager = NotificationManager.getInstance();
    bool result = await manager.newBambooPostNoti.toggleStatus();

    setState(() {
      newBambooPostNotiIcon = Icon(result ? Icons.notifications_active : Icons.notifications_active_outlined);
    });
  }

  Future<void> updateBambooNoti() async{
    if(Platform.isIOS) {
      bool perm = await NotificationManager.checkIosNotificationPermission();
      if (!perm) {
        NotificationManager.requestIosNotificationPermission();
        return;
      }
    }

    if(!LoginView.isLoggined) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => LoginView()));
      return;
    }

    NotificationManager manager = NotificationManager.getInstance();
    bool result = await manager.bambooNoti.toggleStatus();

    setState(() {
      bambooNotiIcon = Icon(result ? Icons.notifications_active : Icons.notifications_active_outlined);
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class _PostPreview extends StatelessWidget {
  final String content;
  final int id;
  final int likes;
  final int comments;
  final String title;

  _PostPreview({this.title: "", this.content: "", this.id: -1, this.likes: -1, this.comments: -1});

  @override
  Widget build(BuildContext context) {

    return Container(
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Column(
          children: [
            MaterialButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return BambooPostViewer(id);
                  }));
                },
                highlightColor: Colors.white.withOpacity(1),
                splashColor: Colors.white.withOpacity(1),
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        color: Colors.grey.shade50
                    ),
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("$title",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  )),
                              //Container(height: 10),
                              Divider(),
                              Row(
                                  children: [
                                    Expanded(
                                      child: Text(content, style: TextStyle(fontSize: 15), maxLines: 11,),
                                    ),
                                  ])
                            ])
                    )
                )
            ),
            //  Divider(),
            Container(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.message, color: Colors.blueGrey.shade200, size: 18),
                        SizedBox(width: 1,),
                        Text("$comments ", style: TextStyle(color: Colors.black87), textAlign: TextAlign.left),
                        SizedBox(width: 5,),
                        Icon(CupertinoIcons.heart_fill, color: Colors.pink.shade300, size: 18),
                        SizedBox(width: 1,),
                        Text("$likes ", style: TextStyle(color: Colors.black87), textAlign: TextAlign.left)
                      ],
                    )
                  ],
                )
            )
          ],
        )
    );
  }
}