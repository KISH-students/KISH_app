import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kish2019/kish_api.dart';
import 'package:kish2019/page/pdf_page.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:photo_view/photo_view.dart';

class KishMagazinePage extends StatefulWidget {
  KishMagazinePage({Key? key}) : super(key: key);

  @override
  KishMagazinePageState createState() {
    return KishMagazinePageState();
  }
}

class KishMagazinePageState extends State<KishMagazinePage> with AutomaticKeepAliveClientMixin<KishMagazinePage> {
  String? parent;
  String? category;

  Widget body = CupertinoActivityIndicator();
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

  void loadBody() {
    Future<void>.delayed(Duration(seconds: 0), () {
      setState(() {
        this.body = FutureBuilder(
          future: ApiHelper.getMagazineHome(parent: parent, category: category),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                List? items;
                if (snapshot.data != null) {
                  if (!(snapshot.data is List)) {
                    dynamic mapData = snapshot.data;
                    items = mapData.toList();
                  } else {
                    items = snapshot.data as List?;
                  }
                } else {
                  items = [];
                }

                return Expanded(
                    child: ListView.builder(
                        itemCount: items!.length,
                        itemBuilder: (context, index) {
                          Map item = items![index];
                          String? type = item["type"];

                          item["title"] = item["title"] is String
                              ? item["title"].replaceAll("\n", " ")
                              : item["title"];

                          item["summary"] = item["summary"] is String
                              ? "\n" + item["summary"].replaceAll("\n", " ")
                              : item["summary"];

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
                List? items;
                if (!(snapshot.data is List)) {
                  dynamic mapData = snapshot.data;
                  items = mapData.toList();
                } else {
                  items = snapshot.data as List?;
                }
                this.parent = items![0];
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
                List? items;
                if (!(snapshot.data is List)) {
                  dynamic mapData = snapshot.data;
                  items = mapData.toList();
                } else {
                  items = snapshot.data as List?;
                }
                items!.insert(0, "all");
                this.category = items[0];
                Future<void>.delayed(Duration(seconds: 0), () {
                  setState(() {
                    loadBody();
                  });
                });

                return CategoryDropdown(this, items);
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
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
              child: Column(
                  children : [
                    Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: Container(
                            margin: EdgeInsets.only(top: 50, bottom: 10),
                            child: Center(
                              child: Text(
                                "KISH Magazine",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 71, 71, 71),
                                    fontFamily: "Cinzel",
                                    fontSize: 30),
                              ),
                            )
                        )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [parentDropdown, Text(" · "), categoryDropdown],
                    ),
                    Text(Platform.isIOS ? "\nCovid-19 또는 민감한 정보를 다루는 기사를 열람할 수 없습니다\n" : ""),
                  ]),
              elevation: 3
          ),
          body
        ]);
  }

  @override
  bool get wantKeepAlive => true;
}

class TextArticle extends StatelessWidget {
  Map data;
  TextArticle(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
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
            Container(
              margin: EdgeInsets.only(top: 20, bottom: 16),
              height: 1,
              decoration: BoxDecoration(color: Colors.black54),
            ),
          ],
        )
    );
  }
}

class TextArticleWithImg extends StatelessWidget {
  Map data;
  TextArticleWithImg(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
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
            Container(
              margin: EdgeInsets.only(bottom: 28),
              height: 1,
              decoration: BoxDecoration(color: Colors.black54),
            ),
          ],
        )
    );
  }
}

class ImgArticle extends StatelessWidget {
  Map data;
  ImgArticle(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
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
    );
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
  List? data;
  ParentDropdown(this.main, this.data, {Key? key}) : super(key: key);

  @override
  _ParentDropdownState createState() {
    return _ParentDropdownState();
  }
}

class _ParentDropdownState extends State<ParentDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: widget.main.parent,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      style: const TextStyle(color: Colors.black),
      onChanged: (String? v) {
        setState(() {
          widget.main.parent = v;
          widget.main.body = CupertinoActivityIndicator();
        });
        widget.main.loadCategory();
      },
      items: widget.data!.map<DropdownMenuItem<String>>((value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
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
    return DropdownButton<String>(
      value: widget.main.category,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      style: const TextStyle(color: Colors.black),
      onChanged: (String? v) {
        setState(() {
          widget.main.category = v;
        });
        widget.main.loadBody();
      },
      items: widget.data!.map<DropdownMenuItem<String>>((value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}