import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kish2019/kish_api.dart';
import 'package:kish2019/page/pdf_page.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:awesome_dropdown/awesome_dropdown.dart';

class KishMagazinePage extends StatefulWidget {
  KishMagazinePage({Key? key}) : super(key: key);

  @override
  KishMagazinePageState createState() {
    return KishMagazinePageState();
  }
}

class KishMagazinePageState extends State<KishMagazinePage> with AutomaticKeepAliveClientMixin<KishMagazinePage> {
  String parent = "";
  String category = "";

  Widget articleListBuilder = CupertinoActivityIndicator();
  Widget parentDropdown = CupertinoActivityIndicator();
  Widget categoryDropdown = CupertinoActivityIndicator();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      initWidgets();
    });
  }

  Future<void> initWidgets() async {
    if (!this.mounted) {
      await Future<void>.delayed(Duration(milliseconds: 10), () {
        initWidgets();
      });
    } else {
      loadParent();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadArticles() {
    Future<void>.delayed(Duration(seconds: 0), () {
      setState(() {
        this.articleListBuilder = FutureBuilder(
          future: ApiHelper.getMagazineHome(parent: parent, category: category),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                List? items;
                if (snapshot.data != null) {
                  dynamic mapData = snapshot.data;
                  items = mapData.toList();
                } else {
                  items = [];
                }

                return Expanded(
                    child: ListView.builder(
                        itemCount: items!.length,
                        itemBuilder: (context, index) {
                          Map item = items![index];
                          String? type = item["type"];

                          if (item["title"] is String) {
                            item["title"]= item["title"].replaceAll("\n", " ");
                          }

                          if (item["summary"] is String) {
                            item["summary"] = "\n" + item["summary"].replaceAll("\n", " ");
                          }

                          if (type == "TextArticleWithImg") return TextArticleWithImg(item);
                          else if (type == "ImgArticle") return ImgArticle(item);
                          else return TextArticle(item);
                        }
                    )
                );
              } else {
                return Text("로드 실패");
              }
            } else {
              return CupertinoActivityIndicator();
            }
          },
        );
      });
    });
  }

  void loadParent() {
    Future<void>.delayed(Duration(seconds: 0), () {
      setState(() {
        this.parentDropdown = FutureBuilder(
          future: ApiHelper.getMagazineParentList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                List<String> items = [];
                dynamic mapData = snapshot.data;
                items = new List<String>.from(mapData.toList());

                this.parent = items[0];
                Future<void>.delayed(Duration(seconds: 0), () {
                  setState(() {
                    loadCategory();
                  });
                });

                return ParentDropdown(this, items);
              } else {
                return Text("로드 실패");
              }
            } else {
              return CupertinoActivityIndicator();
            }
          },
        );
      });
    });
  }

  void loadCategory() {
    Future<void>.delayed(Duration(seconds: 0), () {
      setState(() {
        this.categoryDropdown = FutureBuilder(
          future: ApiHelper.getMagazineCategoryList(parent: parent),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                dynamic mapData = snapshot.data;
                List categoryList;
                categoryList = new List<String>.from(mapData.toList());
                categoryList.insert(0, "all");

                this.category = categoryList[0];
                Future<void>.delayed(Duration(seconds: 0), () {
                  setState(() {
                    loadArticles();
                  });
                });

                return CategoryDropdown(this, categoryList);
              } else {
                return Text("로드 실패");
              }
            } else {
              return CupertinoActivityIndicator();
            }
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                  children : [
                    Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: Container(
                            margin: EdgeInsets.only(top: 5, bottom: 2),
                            child: Center(
                              child: Text(
                                "KISH Magazine",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 71, 71, 71),
                                    fontFamily: "Cinzel",
                                    fontSize: 24),
                              ),
                            )
                        )
                    ),
                    Divider(height: 0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [parentDropdown, categoryDropdown],
                    ),
                    Text(Platform.isIOS ? "\nCovid-19 또는 민감한 정보를 다루는 기사를 열람할 수 없습니다\n" : ""),
                  ]),
              articleListBuilder
            ])
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TextArticle extends StatelessWidget {
  Map data;
  TextArticle(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          FlatButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PdfPage(
                            KISHApi.HOST + data["url"],
                            title: data["title"])
                    )
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data["title"], style: TextStyle(fontFamily: "Oswald-SemiBold", fontSize: 17)),
                  Text(data["summary"],
                      style: TextStyle(
                          fontSize: 13, color: Color.fromARGB(255, 28, 28, 28),
                          fontFamily: "NanumSquareR", fontWeight: FontWeight.w300)),
                ],
              )
          ),
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 16),
            height: 1,
            decoration: BoxDecoration(color: Colors.black54),
          ),
        ]);
  }
}

class TextArticleWithImg extends StatelessWidget {
  Map data;
  TextArticleWithImg(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          FlatButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PdfPage(
                            KISHApi.HOST + data["url"],
                            title: data["title"])
                    )
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data["title"], style: TextStyle(fontFamily: "Oswald-SemiBold", fontSize: 24)),
                  Text(data["summary"], style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 28, 28, 28), fontFamily: "NanumSquareR")),
                  Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 10, bottom: 15),
                      child: Center(
                          child: Image.network(
                            KISHApi.HOST + data["img"],
                            width: MediaQuery.of(context).size.width / 2,
                            loadingBuilder: (context, child, progress) {
                              return progress == null
                                  ? child
                                  : CupertinoActivityIndicator();
                            },
                          )
                      )
                  ),
                ],
              )
          ),
          Container(
            margin: EdgeInsets.only(bottom: 28),
            height: 1,
            decoration: BoxDecoration(color: Colors.black54),
          ),
        ]);
  }
}

class ImgArticle extends StatelessWidget {
  Map data;
  ImgArticle(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          FlatButton(
              onPressed: () {
                Navigator.push(context, PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                    return _ImageArticleViewer(
                      imgSrc: KISHApi.HOST + data["img"],
                      title: data["title"] as String,
                      desc: data["author"] as String,
                    );
                  },));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data["title"], style: TextStyle(fontFamily: "Oswald-SemiBold", fontSize: 24)),
                  Text(data["author"], style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 28, 28, 28))),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 10, bottom: 15),
                    child: Center(
                        child: Image.network(
                          KISHApi.HOST + data["img"],
                          width: MediaQuery.of(context).size.width / 2,
                          loadingBuilder: (context, child, progress) {
                            return progress == null
                                ? child
                                : CupertinoActivityIndicator();
                          },
                        )
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 13, bottom: 28),
                    height: 1,
                    decoration: BoxDecoration(color: Colors.black54),
                  ),
                ],
              )
          )
        ]);
  }
}

class _ImageArticleViewer extends StatefulWidget {
  final String imgSrc;
  final String title;
  final String desc;
  const _ImageArticleViewer({
    required this.imgSrc,
    required this.title,
    required this.desc,
    Key? key
  }) : super(key: key);

  @override
  _ImageArticleViewerState createState() => _ImageArticleViewerState();
}

class _ImageArticleViewerState extends State<_ImageArticleViewer> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        direction: DismissDirection.down,
        key: const Key('static_key_00001'),
        onDismissed: (v) => Navigator.of(context).pop(),
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _visible = !_visible;
              });
            },
            child: Scaffold(
                body: Stack(
                    children: [
                      Container(
                          child: PhotoView.customChild(
                            child: Image.network(
                              widget.imgSrc,
                              width: MediaQuery.of(context).size.width / 2,
                              loadingBuilder: (context, child, progress) {
                                return progress == null
                                    ? child
                                    : CupertinoActivityIndicator();
                              },
                            ),
                          )
                      ),
                      Positioned.fill(
                          bottom: 0,
                          child: AnimatedOpacity(
                              opacity: _visible ? 1 : 0,
                              duration: const Duration(milliseconds: 500),
                              child:
                              Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.7),
                                            Colors.black.withOpacity(0.3),
                                            Colors.black.withOpacity(0.2),
                                            Colors.black.withOpacity(0.08),
                                            Colors.black.withOpacity(0.05),
                                            Colors.black.withOpacity(0),
                                            Colors.black.withOpacity(0),
                                            Colors.black.withOpacity(0),
                                            Colors.black.withOpacity(0),
                                          ]
                                      )
                                  ),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 20,
                                              bottom: 100
                                          ),
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(widget.title,
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      color: Colors.white,
                                                      fontFamily: "NanumSquareR"),),
                                                Text(widget.desc,
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white70),)
                                              ]),
                                        )
                                      ])
                              )
                          )
                      ),
                      AnimatedOpacity(
                          opacity: _visible ? 1 : 0,
                          duration: const Duration(milliseconds: 500),
                          child: SafeArea(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(onPressed: (){
                                      Navigator.pop(context);
                                    }, icon: Icon(CupertinoIcons.xmark, color: Colors.white70,)
                                    )
                                  ])
                          )
                      ),
                    ])
            )
        )
    );
  }
}

class ParentDropdown extends StatefulWidget {
  KishMagazinePageState main;
  List<String>? data;
  ParentDropdown(this.main, this.data, {Key? key}) : super(key: key);

  @override
  _ParentDropdownState createState() {
    return _ParentDropdownState();
  }
}

class _ParentDropdownState extends State<ParentDropdown> {

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: AwesomeDropDown(
          elevation: 1,
          dropDownList: widget.data as List<String>,
          dropDownIcon: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 23,),
          selectedItem: widget.main.parent,
          onDropDownItemClick: (selectedItem) {
            setState(() {
              widget.main.parent = selectedItem;
              widget.main.articleListBuilder = CupertinoActivityIndicator();
            });
            widget.main.loadCategory();
          },
        )
    );
  }
}

class CategoryDropdown extends StatefulWidget {
  KishMagazinePageState main;
  List? data;
  CategoryDropdown(this.main, this.data, {Key? key}) : super(key: key);

  @override
  _CategoryDropdownState createState() {
    return _CategoryDropdownState();
  }
}

class _CategoryDropdownState extends State<CategoryDropdown> {

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: AwesomeDropDown(
          elevation: 1,
          dropDownList: widget.data as List<String>,
          dropDownIcon: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 23,),
          selectedItem: widget.main.category,
          numOfListItemToShow: 7,
          onDropDownItemClick: (selectedItem) {
            setState(() {
              widget.main.category = selectedItem;
            });
            widget.main.loadArticles();
          },
        )
    );
  }
}