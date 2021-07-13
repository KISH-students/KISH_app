import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kish2019/kish_api.dart';
import 'package:kish2019/page/pdf_page.dart';
import 'package:kish2019/tool/api_helper.dart';

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

  Widget body = CircularProgressIndicator();
  Widget parentDropdown = CircularProgressIndicator();
  Widget categoryDropdown = CircularProgressIndicator();

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
              return CircularProgressIndicator(backgroundColor: Colors.orangeAccent);
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
              return CircularProgressIndicator(
                  backgroundColor: Colors.orangeAccent);
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
              return CircularProgressIndicator(
                  backgroundColor: Colors.orangeAccent);
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
                    fontFamily: "Times New Roman", fontWeight: FontWeight.w300)),
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
            Text(data["summary"], style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 28, 28, 28), fontFamily: "Times New Roman")),
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
                            : CircularProgressIndicator();
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
                          : CircularProgressIndicator();
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
          widget.main.body = CircularProgressIndicator();
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