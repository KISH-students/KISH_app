import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:kish2019/kish_api.dart';
import 'package:kish2019/page/maintenance_page.dart';
import 'package:kish2019/page/pdf_page.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/dday_card.dart';

class KishMagazinePage extends StatefulWidget {
  KishMagazinePage({Key key}) : super(key: key);

  @override
  _KishMagazinePageState createState() {
    return _KishMagazinePageState();
  }
}

class _KishMagazinePageState extends State<KishMagazinePage> with AutomaticKeepAliveClientMixin<KishMagazinePage> {
  Widget yearSelectorWidget = ListTileShimmer();
  Widget articleListWidget = Text("");
  List<Widget> yearButtons = [];
  List<Widget> articleList = [];
  String nowPath = "";
  String rootPath = "";

  @override
  void initState() {
    //loadButtons();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadYearButtons();
    });
  }


  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadYearButtons() async {
    List resultList;
    yearButtons = [];

    try {
      resultList = await ApiHelper.getArticleList();
    } catch (e) {
      if (this.mounted) {
        setState(() {
          this.yearSelectorWidget = DDayCard(
            color: Colors.redAccent,
            content: "불러올 수 없어요",
          );
        });
      }
    }

    if (resultList.length > 0) {
      nowPath = resultList[0]["path"];

      resultList.forEach((map) {
        yearButtons.add(_CustomYearButton(map["name"], () {
          this.nowPath = map["path"];
          this.rootPath = this.nowPath;
          reloadArticleList();
        },
            textColor: Colors.white,
            backgroundColor: Color.fromARGB(255, 48, 48, 48),
            borderColor: Color.fromARGB(255, 48, 48, 48),
            borderSize: 0));
      });
    }

    rebuildYearSelector();
    reloadArticleList();
  }

  void rebuildYearSelector() {
    if (this.mounted) {
      setState(() {
        this.yearSelectorWidget = Container(
            height: 80,
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 30, 10, 0),
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: yearButtons.length,
                  itemBuilder: (context, index) => yearButtons[index],
                ),
              ),
            ));
      });
    }
  }

  void addHomeButton() {
    if (this.yearButtons.length > 0) {
      _CustomYearButton button = this.yearButtons[0];

      if (button.content != "처음으로") {
        setState(() {
          this.yearButtons.insert(
              0,
              _CustomYearButton(
                "처음으로",
                () {
                  this.nowPath = this.rootPath;
                  this.yearButtons.removeAt(0);
                  this.rebuildYearSelector();
                  this.reloadArticleList();
                },
                borderColor: Colors.blueAccent,
                textColor: Colors.indigo,
                borderSize: 1.5,
              ));
          this.rebuildYearSelector();
        });
      }
    }
  }

  Future<void> reloadArticleList() async {
    if (this.mounted) {
      setState(() {
        this.articleListWidget = ListTileShimmer(
          isPurplishMode: true,
        );
      });
    }
    List articleList = (await ApiHelper.getArticleList(path: nowPath));
    List<Widget> resultArticleList = [];
    List<Widget> resultFolderList = [];
    List<Widget> resultWidgetList = [];

    Color backgroundColor = ArticleFolder.BACKGROUND_COLORS[
        Random.secure().nextInt(ArticleFolder.BACKGROUND_COLORS.length)];

    if (articleList.length > 0) {
      articleList.forEach((element) {
        if (element["type"] == "file") {
          resultArticleList.add(
            Article(element["name"], element["author"], () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PdfPage(
                              KISHApi.HOST + element["url"],
                              title: element["name"])));
            }, backgroundColor),
          );
        } else if (element["type"] == "dir") {
          String desc;
          if (element["custom_desc"] != null)
            desc = element["custom_desc"];
          else
            desc =
                "기사" + (element["subfileName"] as List).length.toString() + "개";

          resultFolderList.add(ArticleFolder(element["name"], desc, () {
            this.nowPath = element["path"];
            addHomeButton();
            this.reloadArticleList();
          }, backgroundColor));
        }
      });

      resultWidgetList.addAll(resultFolderList);
      resultWidgetList.addAll(resultArticleList);

      if (this.mounted) {
        setState(() {
          this.articleListWidget = this.articleListWidget = Container(
              child: Card(
                //color: Colors.white70,
                //borderOnForeground: true,
                margin: EdgeInsets.all(4),
                elevation: 0,
                child: GridView.count(
                  crossAxisCount: min(
                      max((MediaQuery
                          .of(context)
                          .size
                          .width / 400), 2).round(), 5),
                  mainAxisSpacing: 1.0,
                  crossAxisSpacing: 1.0,
                  childAspectRatio: 564 / 348,
                  children: resultWidgetList,
                ),
              ));
        });
      } else {
        if (this.mounted) {
          setState(() {
            this.articleListWidget =
                MaintenancePage(title: "Empty :(", description: "기사를 찾을 수 없어요");
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      //TitleText("KISH\nMAGAZINE", top: 60.0),
      //DescriptionText("KISH Magazine에 오셨습니다"),
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
              ))),
      Container(
          decoration: BoxDecoration(color: Colors.black54),
          child: Row(
            children: [Container(margin: EdgeInsets.only(top: 3))],
          )),
      Container(child: yearSelectorWidget),
      Expanded(flex: 2, child: articleListWidget),
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}

class _CustomYearButton extends StatelessWidget {
  String content;
  VoidCallback onPressed;
  Color borderColor;
  Color textColor;
  Color backgroundColor;
  double borderSize;

  _CustomYearButton(this.content, this.onPressed,
      {this.borderColor = Colors.redAccent,
      this.textColor = Colors.red,
      this.backgroundColor = Colors.white,
      this.borderSize = 0.8})
      : super(key: UniqueKey());

  @override
  Widget build(BuildContext context) {
    return Container(
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(
          content,
          style: TextStyle(fontFamily: "CRB", fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          primary: textColor,
          side: BorderSide(width: borderSize, color: borderColor),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
      margin: EdgeInsets.only(right: 5, top: 5, bottom: 5),
    );
    return null;
  }
}

class ArticleFolder extends StatelessWidget {
  /*static const List<List<Color>> BACKGROUND_COLORS = [
    [Color.fromARGB(255, 42, 8, 69), Color.fromARGB(255, 100, 65, 165)],
    // 보라
    [Color.fromARGB(255, 24, 90, 157), Color.fromARGB(255, 67, 206, 162)],
    // 블루오션
    [Color.fromARGB(255, 72, 85, 99), Color.fromARGB(255, 41, 50, 60)],
    // 회색
    [Color.fromARGB(255, 96, 108, 136), Color.fromARGB(255, 63, 76, 107)],
    // ASH
  ];*/

  static const List<Color> BACKGROUND_COLORS = [
    Color.fromARGB(255, 41, 41, 41),
  ];

  String title = "";
  String description = "";
  VoidCallback onPressed;
  Color backgroundColor;

  ArticleFolder(
      this.title, this.description, this.onPressed, this.backgroundColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        onPressed: onPressed,
        child: Card(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 0,
          child: SizedBox.expand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    margin: EdgeInsets.only(top: 30),
                    decoration: BoxDecoration(color: backgroundColor),
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          title,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "CRB",
                              fontSize: max(
                                  (MediaQuery.of(context).size.width / 96),
                                  13)),
                          textAlign: TextAlign.start,
                        )
                        //),
                        )),
                Container(
                  margin: EdgeInsets.only(top: 9, left: 10, bottom: 9),
                  child: Text(
                    description,
                    style: TextStyle(
                        color: Colors.grey,
                        fontFamily: "CRB",
                        fontSize:
                            max((MediaQuery.of(context).size.width / 96), 15) -
                                3.0),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Article extends StatelessWidget {
  String articleName;
  String author;
  VoidCallback onPressed;
  Color backgroundColor;

  Article(this.articleName, this.author, this.onPressed, this.backgroundColor);

  @override
  Widget build(BuildContext context) {
    return ArticleFolder(
        articleName, this.author, this.onPressed, backgroundColor);
  }
}
