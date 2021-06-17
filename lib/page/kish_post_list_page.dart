import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/dday_card.dart';
import 'package:kish2019/widget/post_webview.dart';
import 'package:kish2019/noti_manager.dart';

class KishPostListPage extends StatefulWidget {
  static int mode = 0;
  static int menu = 0;

  KishPostListPage({Key key}) : super(key: key);

  @override
  _KishPostListPageState createState() {
    return _KishPostListPageState();
  }
}

class _KishPostListPageState extends State<KishPostListPage> with AutomaticKeepAliveClientMixin<KishPostListPage> {
  static int mode = 1;
  static String menu = "";
  static Widget body = Container();

  PagingController<int, Widget> _pagingController = PagingController(firstPageKey: 0);
  String currentKeyword;
  List<PostInfo> postList = [];
  int searchIndex = 1;

  Widget loading = Container();
  Widget backButtonWidget = Container();
  Icon newKishPostNotiIcon = new Icon(Icons.sync);

  @override
  void initState() {
    super.initState();
    setBody2Normal();
    initWidgets();
  }

  Future<void> initWidgets() async {
    if (!this.mounted) {
      await Future<void>.delayed(Duration(milliseconds: 10), () {
        initWidgets();
      });
    } else {
      await loadNewKishPostNotiIcon();
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  void setBody2PagedListView() {
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener((pageKey) {
      search(currentKeyword, pageKey);
    });

    setState(() {
      backButtonWidget = FlatButton.icon(
          onPressed: (){ setBody2Normal(); },
          icon: const Icon(CupertinoIcons.back),
          label: const Text("뒤로가기"));

      body = Expanded(
        child: PagedListView<int, Widget>(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(
              parent: const AlwaysScrollableScrollPhysics()),
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Widget>(
              itemBuilder: (context, item, index) {
                if (index > postList.length - 1) {    // 왜 자꾸 index를 넘어갈까요?
                  return SizedBox.shrink();
                }
                return postList[index];
              }
          ),
        ),);
    });
  }

  void setBody2Normal() {
    setState(() {
      backButtonWidget = Container();
      _pagingController.itemList = [];
      _pagingController.nextPageKey = 0;
      searchIndex = -1;
      _pagingController.itemList = [];
      postList = [];
      if(_pagingController != null) {
        _pagingController.dispose();
      }

      body = FutureBuilder(
          future: ApiHelper.getPostListHomeSummary(),
          builder: (context, snapshot) {
            List data = null;
            loading = SizedBox.shrink();

            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                data = snapshot.data;
              } else {
                return DDayCard(description: "불러오지 못했습니다", content: "불러오지 못했습니다", color: Colors.redAccent,);
              }
            }

            /*if (data == null) {
                      loading = LinearProgressIndicator(backgroundColor: Colors.grey);

                      if (NotificationManager.instance.preferences != null) {
                        String key = ApiHelper.getCacheKey(
                            KISHApi.GET_POST_LIST_HOME_SUMMARY, {});
                        String jsonData = NotificationManager.instance
                            .preferences.getString(key);

                        if (jsonData != null) {
                          try {
                            data = json.decode(jsonData);
                          } catch (e) {
                            print(e);
                          }
                        }
                      }
                    }*/

            if (data != null) {
              List<Widget> widgets = [];
              data.forEach((element) {
                widgets.add(_PostList(this,
                  menu: element["menu"].toString(), menuTitle: element["title"], postList: element["posts"],));
              });

              Widget resultWidget = Expanded(
                  child: AspectRatio(
                      aspectRatio: 1/1,
                      child: ListView.builder(
                        shrinkWrap: false,
                        itemCount: widgets.length,
                        itemBuilder: (context, index) {return widgets[index];},
                      )));

              return resultWidget;
            }
            return YoutubeShimmer();
          }
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color.fromARGB(255, 252, 252, 252),
        child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, left: 30, right: 30),
                child: TextFormField(
                    cursorColor: Colors.black38,
                    decoration: const InputDecoration(
                      icon: const Icon(CupertinoIcons.search),
                      fillColor: Colors.grey,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                      labelText: "검색어를 입력하세요",
                    ),
                    onChanged: (text){
                      mode = 1;
                      search(text, 1);
                    }
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 5),
                decoration: const BoxDecoration(color: Colors.black12),
                height: 2,
              ),
              Center(
                  child: FlatButton.icon(
                      onPressed: updateNewKishPostNoti,
                      icon: this.newKishPostNotiIcon,
                      label: const Text("새 글 알림")
                  )
              ),
              loading,
              backButtonWidget,
              body,
            ])
    );
  }

  Future<void> loadNewKishPostNotiIcon() async {
    NotificationManager manager = NotificationManager.getInstance();
    newKishPostNotiIcon = Icon(await manager.isNewKishPostEnabled() ? Icons.notifications_active : Icons.notifications_active_outlined);
  }

  Future<void> updateNewKishPostNoti() async{
    NotificationManager manager = NotificationManager.getInstance();

    bool result = await manager.toggleNewKishPost();

    setState(() {
      newKishPostNotiIcon = Icon(result ? Icons.notifications_active : Icons.notifications_active_outlined);
    });
  }

  Future<void> search(String keyword, int pageIndex) async{
    loading = LinearProgressIndicator(backgroundColor: Colors.orangeAccent);

    if(mode == 1) {
      keyword = keyword.trim();

      if (keyword == null || keyword.isEmpty) {
        setBody2Normal();
        loading = Container();
        return;
      } else if(keyword.length == 1) {
        setBody2PagedListView();
      }

      if (currentKeyword != keyword) {
        currentKeyword = keyword;
        searchIndex = -1;
        pageIndex = 0;
        _pagingController.itemList = [];
      }

      await Future<void>.delayed(Duration(milliseconds: 200), (){});
      if (currentKeyword != keyword) return;
    }

    searchIndex ++;
    print (searchIndex.toString() + "??");

    try {
      List result;
      List<PostInfo> newWidgetList = [];

      if (mode == 1) {
        result = await ApiHelper.searchPost(keyword, searchIndex);
      } else if (mode == 2) {
        result = await ApiHelper.getPostsByMenu(menu, searchIndex.toString());
      }

      if (currentKeyword != keyword) return;

      result.forEach((element) {
        newWidgetList.add(PostInfo(
            title: element["title"],
            author: element["author"],
            date: element["postDate"],
            menu: element["menu"],
            id: element["id"]));
      });
      if (searchIndex == 0) {
        this.postList = newWidgetList;
      } else {
        this.postList.addAll(newWidgetList);
      }

      if (newWidgetList.length == 0 || newWidgetList.length < 10) {
        _pagingController.appendLastPage(newWidgetList);
      } else {
        _pagingController.appendPage(
            newWidgetList, pageIndex + (newWidgetList.length - 1));
      }

    } finally {
      loading = Container(height: 2);
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class PostInfo extends StatelessWidget {
  final String title;
  final String author;
  final String date;
  final int menu;
  final int id;

  const PostInfo({this.title, this.author, this.date, this.menu, this.id, Key key});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.zero,
      child : Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 10,
          shadowColor: Colors.black38,
          child: Container(
              padding: const EdgeInsets.only(left: 12, right: 8, top: 10, bottom: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Text(title, style: TextStyle(fontFamily: "NanumSquareR", fontSize: 16)),
                    ),
                    Row(
                        children: [
                          const Icon(CupertinoIcons.person, color: Colors.grey),
                          Text(author, style: TextStyle(color: Colors.grey)),
                        ]),
                    Container(
                      width: double.infinity,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Icon(CupertinoIcons.clock, color: Colors.grey),
                            Text(date, style: TextStyle(color: Colors.grey)),
                          ]),
                    ),
                  ])
          ),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostWebView(menu: menu.toString(), id: id.toString(),)),
        );
      },
    );
  }
}


class _PostList extends StatelessWidget {
  final _KishPostListPageState listPageState;
  final String menuTitle;
  final String menu;
  final List postList;

  _PostList(this.listPageState, {this.menuTitle, this.menu, this.postList}) {
    this.postList.length = min(5, this.postList.length);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30, right: 5, left: 5),
      child: Card(
        color: Color.fromARGB(255, 253, 253, 253),
        elevation: 1,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10, left: 16, bottom: 10),
                  child: Center(
                      child: Text(menuTitle, style: TextStyle(fontFamily: "NanumSquareR", fontSize: 22.5, color: Colors.black87),)
                  )
              ),
              Container(
                  margin: const EdgeInsets.only(bottom: 5, top: 1),
                  width: double.infinity,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: postList.length,
                    itemBuilder: (context, index) {
                      if (index > 5) return SizedBox.shrink();
                      Map element = postList[index];

                      return FlatButton(
                        padding: EdgeInsets.zero,
                        minWidth: double.infinity,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                PostWebView(
                                    menu: element["menu"].toString(),
                                    id: element["id"].toString())),
                          );
                        },
                        child: Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.only(left: 8, right: 8),
                            child: Text(element["title"])
                        ),
                      );
                    },
                  )
              ),

              Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FlatButton(
                          onPressed: (){
                            _KishPostListPageState.mode = 2;
                            _KishPostListPageState.menu = menu.toString();
                            listPageState.setBody2PagedListView();
                          },
                          child: const Text("더 보기", style: TextStyle(color: Colors.blueAccent),)
                      )
                    ],
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}