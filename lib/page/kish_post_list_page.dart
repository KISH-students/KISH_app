import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/dday_card.dart';
import 'package:kish2019/widget/post_webview.dart';
import 'package:kish2019/noti_manager.dart';
import 'package:toasta/toasta.dart';

class KishPostListPage extends StatefulWidget {
  static int mode = 0;
  static int menu = 0;

  KishPostListPage({Key? key}) : super(key: key);

  @override
  _KishPostListPageState createState() {
    return _KishPostListPageState();
  }
}

class _KishPostListPageState extends State<KishPostListPage> with AutomaticKeepAliveClientMixin<KishPostListPage> {
  static int mode = 1;
  static String menu = "";
  static Widget body = Container();

  TextEditingController searchBarController = new TextEditingController();
  PagingController<int, Widget> _pagingController = new PagingController(firstPageKey: 0);
  String? currentKeyword;
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
      backButtonWidget = TextButton.icon(
          onPressed: (){ setBody2Normal(); },
          icon: const Icon(CupertinoIcons.back),
          label: const Text("뒤로가기"));

      body = Expanded(
        child: RefreshIndicator(
          onRefresh: () async { _pagingController.refresh(); },
          child: PagedListView<int, Widget>(
              physics: AlwaysScrollableScrollPhysics(),
              shrinkWrap: false,
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<Widget>(
                  itemBuilder: (context, item, index) {
                    if (index > postList.length - 1) {    // 왜 자꾸 index를 넘어갈까요?
                      return SizedBox.shrink();
                    }
                    return postList[index];
                  }
              )),
        ),
      );
    });
  }

  Future<void> checkConnectionForNormalBody() async {
    try {
      await ApiHelper.getPostListHomeSummary();
    } catch (e) {
      print(e);
      Future.delayed(Duration(seconds: 1), (){checkConnectionForNormalBody();});
      return;
    }

    this.setBody2Normal();
  }

  void setBody2Normal() {
    setState(() {
      backButtonWidget = Container();
      this.searchBarController.text = "";
      _pagingController.itemList = [];
      _pagingController.nextPageKey = 0;
      _pagingController.itemList = [];
      searchIndex = -1;
      postList = [];

      body = FutureBuilder(
          future: ApiHelper.getPostListHomeSummary(),
          builder: (context, snapshot) {
            List? data;
            loading = SizedBox.shrink();

            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                data = snapshot.data as List;
              } else {
                checkConnectionForNormalBody();
                return DDayCard(description: "불러오지 못했습니다", content: "불러오지 못했습니다", color: Colors.redAccent,);
              }
            }

            if (data != null) {
              List<Widget> widgets = [];
              data.forEach((element) {
                widgets.add(_PostList(this,
                  menu: element["menu"].toString(), menuTitle: element["title"], postList: element["posts"],));
              });

              Widget resultWidget = Expanded(
                  child: RefreshIndicator(
                      onRefresh: () async { setBody2Normal(); },
                      child: ListView.builder(
                        shrinkWrap: false,
                        itemCount: widgets.length,
                        itemBuilder: (context, index) {return widgets[index];},
                      )
                  )
              );
              return resultWidget;
            }
            return YoutubeShimmer();
          }
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          color: Color.fromARGB(255, 252, 252, 252),
          child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 30, right: 30),
                  child: TextFormField(
                      controller: searchBarController,
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
                Container(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                        onPressed: NotificationManager.isFcmSupported
                            ? updateNewKishPostNoti
                            : () {Toasta(context).toast(Toast(subtitle: "이 기기에서 지원되지 않습니다"));},
                        icon: this.newKishPostNotiIcon,
                        label: const Text("새 글 알림")
                    )
                ),
                loading,
                backButtonWidget,
                body,
              ])
      ),
    );
  }

  Future<void> loadNewKishPostNotiIcon() async {
    NotificationManager manager = NotificationManager.getInstance();
    newKishPostNotiIcon = Icon(await manager.newKishPostNoti.isEnabled() ? Icons.notifications_active : Icons.notifications_active_outlined);
  }

  Future<void> updateNewKishPostNoti() async{
    NotificationManager manager = NotificationManager.getInstance();

    bool result = await manager.newKishPostNoti.toggleStatus();

    setState(() {
      newKishPostNotiIcon = Icon(result ? Icons.notifications_active : Icons.notifications_active_outlined);
    });
  }

  void resetLoadingBar() {
    setState(() {
      loading = Container();
    });
  }

  Future<void> search(String? keyword, int pageIndex) async{
    loading = LinearProgressIndicator(backgroundColor: Colors.orangeAccent);

    if(mode == 1) {
      keyword = keyword!.trim();

      if (keyword == null || keyword.isEmpty) {
        setBody2Normal();
        resetLoadingBar();
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

    try {
      List? result;
      List<PostInfo> newWidgetList = [];

      try {
        if (mode == 1) {
          result = await ApiHelper.searchPost(keyword, searchIndex);
        } else if (mode == 2) {
          result = await ApiHelper.getPostsByMenu(menu, searchIndex.toString());
        }
      } catch(e) {
        print(e);
        _pagingController.appendPage([], pageIndex);
        resetLoadingBar();
        return;
      }

      if (currentKeyword != keyword) return;

      result!.forEach((element) {
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
      resetLoadingBar();
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class PostInfo extends StatelessWidget {
  final String? title;
  final String? author;
  final String? date;
  final int? menu;
  final int? id;

  const PostInfo({this.title, this.author, this.date, this.menu, this.id, Key? key});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Divider(),
          ListTile(
            title: Text("$title"),
            subtitle: Text("$author | $date"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostWebView(menu: menu.toString(), id: id.toString(),)),
              );
            },
          ),
        ]);
  }
}


class _PostList extends StatelessWidget {
  final _KishPostListPageState listPageState;
  final String? menuTitle;
  final String? menu;
  final List? postList;

  _PostList(this.listPageState, {this.menuTitle, this.menu, this.postList}) {
    this.postList!.length = min(5, this.postList!.length);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(width: 1, color: Colors.black.withOpacity(0.1))
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10, left: 16, bottom: 10),
                  child: Center(
                      child: Text(menuTitle!, style: TextStyle(fontFamily: "NanumSquareR", fontSize: 22.5, color: Colors.black87),)
                  )
              ),
              Container(
                  margin: const EdgeInsets.only(bottom: 5, top: 1),
                  width: double.infinity,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: postList!.length,
                    itemBuilder: (context, index) {
                      if (index > 2) return SizedBox.shrink();
                      Map element = postList![index];

                      return ButtonTheme(
                        padding: EdgeInsets.zero,
                        minWidth: double.infinity,
                        child:  TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  PostWebView(
                                      menu: element["menu"].toString(),
                                      id: element["id"].toString()
                                  )),
                            );
                          },


                          child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 8, right: 8),
                              child: Text(element["title"], style: TextStyle(fontWeight: FontWeight.bold),)
                          ),
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
                      ElevatedButton(
                          onPressed: (){
                            _KishPostListPageState.mode = 2;
                            _KishPostListPageState.menu = menu.toString();
                            listPageState.setBody2PagedListView();
                          },
                          style: ElevatedButton.styleFrom(primary: Colors.black),
                          child: const Text("더 보기", style: TextStyle(fontWeight: FontWeight.bold),)
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