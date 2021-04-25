import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/dday_card.dart';
import 'package:kish2019/widget/title_text.dart';
import 'package:kish2019/widget/post_webview.dart';

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
  final PagingController<int, Widget> _pagingController =
  PagingController(firstPageKey: 0);
  String currentKeyword;
  List<PostInfo> postList = [];
  int searchIndex = 1;

  Widget loading = Container();
  Widget body = Container();

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      search(currentKeyword, pageKey);
    });
    setBody2Normal();
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  void setBody2PagedListView() {
    setState(() {
      this.body = Expanded(
        child: PagedListView<int, Widget>(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Widget>(
              itemBuilder: (context, item, index) => postList[index]
          ),
        ),);
    });
  }

  void setBody2Normal() {
    setState(() {
      body = Expanded(
          child: SingleChildScrollView(
              child: FutureBuilder(
                  future: ApiHelper.getLastUpdatedMenuList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        List data = snapshot.data;
                        List<Widget> widgets = [];
                        Widget resultWidget = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widgets,
                        );

                        data.forEach((element) {
                          widgets.add(_PostList(menu: element["id"], menuTitle: element["name"],));
                        });

                        return resultWidget;
                      } else {
                        return DDayCard(description: "불러오지 못했습니다", content: "불러오지 못했습니다", color: Colors.redAccent,);
                      }
                    }

                    return YoutubeShimmer();
                  }
              )
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20, left: 30, right: 30),
                child:
                TextFormField(
                    cursorColor: Colors.black38,
                    decoration: InputDecoration(
                      icon: Icon(CupertinoIcons.search),
                      fillColor: Colors.grey,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(30.0))),
                      labelText: "검색어를 입력하세요",
                    ),
                    onChanged: (text){
                      search(text, 1);
                    }
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(color: Colors.black12),
                height: 2,
              ),
              loading,
              Row(
                  children: [
                    Icon(CupertinoIcons.lab_flask, color: Colors.black,),
                    Text("이 페이지는 아직 실험적으로 작동됩니다.", style: TextStyle(color: Colors.redAccent)),
                  ]),
              body,
            ])
    );
  }

  Future<void> search(String keyword, int pageIndex) async{
    keyword = keyword.trim();
    setState(() {
      loading = LinearProgressIndicator(backgroundColor: Colors.orangeAccent);
    });

    if (currentKeyword != keyword) {
      currentKeyword = keyword;
      searchIndex = -1;
      pageIndex = 0;
      _pagingController.itemList = [];
    }
    if (keyword == null || keyword.isEmpty) {
      _pagingController.appendLastPage([]);
      setBody2Normal();
      return;
    } else {
      setBody2PagedListView();
    }

    searchIndex ++;
    print (searchIndex.toString() + "??");

    await Future<void>.delayed(Duration(milliseconds: 200), (){});
    if (currentKeyword != keyword) return;

    try {
      List result = await ApiHelper.searchPost(keyword, searchIndex);

      if (currentKeyword != keyword) return;
      List<PostInfo> newPostList = [];

      result.forEach((element) {
        newPostList.add(PostInfo(
            title: element["title"],
            author: element["author"],
            date: element["postDate"],
            menu: element["menu"],
            id: element["id"]));
      });

      if (newPostList.length == 0 || newPostList.length < 10) {
        _pagingController.appendLastPage(newPostList);
      } else {
        _pagingController.appendPage(
            newPostList, pageIndex - 1 + newPostList.length);
      }

      setState(() {
        if (searchIndex == 1) {
          this.postList = newPostList;
        } else {
          this.postList.addAll(newPostList);
        }
      });
    } finally {
      loading = Container(height: 2);
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class PostInfo extends StatelessWidget {
  String title;
  String author;
  String date;
  int menu;
  int id;
  PostInfo({this.title, this.author, this.date, this.menu, this.id, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.zero,
      child : Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text("작성자 : " + author),
              Text("작성일 : " + date),
              Container(
                margin: EdgeInsets.only(top: 10),
                height: 2,
                color: Colors.black38,
              )
            ]),
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

class _PostList extends StatefulWidget {
  String menuTitle;
  int menu;

  _PostList({this.menuTitle, this.menu});

  @override
  _PostListState createState() {
    return _PostListState();
  }
}

class _PostListState extends State<_PostList> {
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
    return Container(
      margin: EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleText(widget.menuTitle, top: 10,),
          Container(
            color: Colors.black38,
            height: 2,
          ),
          FutureBuilder(
              future: ApiHelper.getPostsByMenu(widget.menu.toString(), 0.toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    List result = snapshot.data;
                    List<Widget> widgets = [];

                    int index = 0;
                    result.forEach((element) {
                      if (index == 5) return;
                      widgets.add(
                          FlatButton(
                              padding: EdgeInsets.zero,
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
                                margin: EdgeInsets.only(top: 1),
                                child: Text(element["title"]),
                              ))
                      );
                      index ++;
                    });

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widgets,
                    );
                  } else {
                    return DDayCard(description: "불러오지 못했습니다", content: "불러오지 못했습니다", color: Colors.redAccent,);
                  }
                } else {
                  return YoutubeShimmer();
                }
              }
          )
        ],
      ),
    );
  }
}