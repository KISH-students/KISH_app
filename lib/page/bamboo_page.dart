import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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

  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener((pageKey) {
      updatePage(pageKey);
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
    return SafeArea(
      child: Container(
          child: Column(
            key: UniqueKey(),
            children: [
              SizedBox(height: 8,),
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
                color: Colors.blueGrey.shade200,
              ),
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