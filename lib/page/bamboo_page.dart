import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kish2019/widget/bamboo_post_viewer.dart';

class BambooPage extends StatefulWidget {
  BambooPage({Key? key}) : super(key: key);

  @override
  _BambooPageState createState() {
    return _BambooPageState();
  }
}

class _BambooPageState extends State<BambooPage> {
  final FlutterSecureStorage storage = new FlutterSecureStorage();
  PagingController<int, _PostPreview> pagingController = new PagingController(firstPageKey: 0);

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

  void updatePage(int key) {
    List<Map> newPosts = [];
    bool lastPage = false;

    List<_PostPreview> newWidgets = [];

    if (lastPage) {
      pagingController.appendLastPage(newWidgets);
    } else {
      pagingController.appendPage(newWidgets, key + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: [
            CupertinoButton(
              child: Text("익명으로 글 쓰기"),
              onPressed: () {
                Navigator.pushNamed(context, "writing");
              },
              color: Colors.redAccent,

            ),
            _PostPreview(),
            _PostPreview(),
            _PostPreview(),
            _PostPreview(),
            /*PagedListView<int, _PostPreview>(
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<_PostPreview>(
            itemBuilder: (context, item, index) => _PostPreview(
              content: "와우 " + index.toString() + "번째 아이템!",
            ),
          ),
        )*/
          ],
        )
    );
  }
}

class _PostPreview extends StatelessWidget {
  final String content;

  _PostPreview({this.content = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Column(
          children: [
            MaterialButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return BambooPostViewer(Map());
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
                        child: Row(
                            children: [
                              Expanded(
                                child: Text("내용 미리보기 ...", style: TextStyle(fontSize: 18),),
                              ),
                            ]
                        )
                    )
                )
            ),
            //  Divider(),
            Container(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "#1958번째 외침",
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.left
                    ),
                    Row(
                      children: [
                        Icon(Icons.message, color: Colors.orange.shade200, size: 18),
                        Text("192" + " ", style: TextStyle(color: Colors.black87), textAlign: TextAlign.left),
                        Icon(CupertinoIcons.heart_fill, color: Colors.redAccent, size: 18),
                        Text("192" + " ", style: TextStyle(color: Colors.black87), textAlign: TextAlign.left)
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

class BambooPost extends StatelessWidget {
  BambooPost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.filled(child: Text("누르셔"), onPressed: () => Navigator.pushNamed(context, "post_list"));
  }
}
