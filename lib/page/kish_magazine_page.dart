import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:kish2019/kish_api.dart';
import 'package:kish2019/page/maintenance_page.dart';
import 'package:kish2019/page/pdf_page.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/description_text.dart';
import 'package:kish2019/widget/exam_card.dart';
import 'package:kish2019/widget/title_text.dart';

class KishMagazinePage extends StatefulWidget {
  KishMagazinePage({Key key}) : super(key: key);

  @override
  _KishMagazinePageState createState() {
    return _KishMagazinePageState();
  }
}

class _KishMagazinePageState extends State<KishMagazinePage> {
  Widget yearSelectorWidget = ListTileShimmer();
  Widget articleListWidget = Text("");
  List<Widget> articleList = [];
  String nowPath = "";

  @override
  void initState() {
    //loadButtons();
    super.initState();

    loadYearButtons();
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.cubeGrid;
    EasyLoading.instance.loadingStyle = EasyLoadingStyle.dark;
    EasyLoading.instance.maskType = EasyLoadingMaskType.black;
    //EasyLoading.show(status: '불러오는 중');
    setState(() {

    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadYearButtons() async{
    List resultList;
    List<Widget> yearButtons = [];

    try {
       resultList = await ApiHelper.getArticleList();
    }catch(e){
      setState(() {
        this.yearSelectorWidget = ExamCard(
          false, color: Colors.redAccent, content: "불러올 수 없어요",);
      });
    }

    if(resultList.length > 0) {
      nowPath = resultList[0]["path"];

      resultList.forEach((map) {
        yearButtons.add(_CustomYearButton(map["name"], (){
          this.nowPath = nowPath = map["path"];
          reloadArticleList();
        }));
      });
    }

    setState(() {
      this.yearSelectorWidget = SingleChildScrollView(
        child: Container(
          height: 70,
          child : Container(
            margin: EdgeInsets.fromLTRB(10, 30, 10, 0),
            child : Card(
              elevation: 2.8,
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: ListView(
                scrollDirection: Axis.horizontal,
                children: yearButtons,
              ),
            ),
            ),
          ),
        ),
      );
    });

    reloadArticleList();
  }

  void reloadArticleList() async{
    setState(() {
      this.articleListWidget = ListTileShimmer(isPurplishMode: true,);
    });
    List articleList = (await ApiHelper.getArticleList(path: nowPath));
    List<Widget> resultArticleList = [];
    List<Widget> resultFolderList = [];
    List<Widget> resultWidgetList = [];

    if(articleList.length > 0) {
      articleList.forEach((element) {
        if (element["type"] == "file"){
          resultArticleList.add(Article(element["name"], () {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => PdfPage(KISHApi.HOST + element["url"],
                    title: element["name"])
                )
            );
          }));
        }else if(element["type"] == "dir"){
          String desc;
          if(element["custom_desc"] != null) desc = element["custom_desc"];
          else desc =
              "기사" + (element["subfileName"] as List).length.toString() + "개";
          resultFolderList.add(ArticleFolder(element["name"], desc, (){
            this.nowPath = element["path"];
            this.reloadArticleList();
          }));
        }
      });

      resultWidgetList.addAll(resultFolderList);
      resultWidgetList.addAll(resultArticleList);

      setState(() {
        this.articleListWidget = this.articleListWidget = Container(
            height: 200,
            child: Card(
              color: Colors.white70,
              borderOnForeground: true,
              margin: EdgeInsets.all(10),
              elevation: 5,
              child: GridView.count(
                crossAxisCount: 2,
                children: resultWidgetList,
              ),
            )
        );
      });
    }else{
      setState(() {
        this.articleListWidget = MaintenancePage(
            title: "Empty :(",
            description: "기사를 찾을 수 없어요");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children : [
          TitleText("KISH\nMAGAZINE", top: 60.0),
          DescriptionText("KISH의 기사를 읽어보세요"),

          yearSelectorWidget,

          Expanded(
              flex: 2,
              child: articleListWidget
          ),
        ]
    );
  }
}

class _CustomYearButton extends StatelessWidget {
  String content;
  VoidCallback onPressed;

  _CustomYearButton(this.content, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Container(
      child : OutlinedButton(
        onPressed: this.onPressed,
        child: Text(this.content),
        style: OutlinedButton.styleFrom(
          primary: Colors.red,
          side: BorderSide(width: 0.8, color: Colors.redAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11.0),
          ),
        ),
      ),
      margin: EdgeInsets.only(right: 5, top: 5, bottom: 5),
    );
    return null;
  }
}

class ArticleFolder extends StatelessWidget {
  static const List<List<Color>> BACKGROUND_COLORS = [
    [Color.fromARGB(255, 42, 8, 69), Color.fromARGB(255, 100, 65, 165)], // 보라
    [Color.fromARGB(255, 24, 90, 157), Color.fromARGB(255, 67, 206, 162)], // 블루오션
    [Color.fromARGB(255, 72, 85, 99), Color.fromARGB(255, 41, 50, 60)], // 회색
    [Color.fromARGB(255, 96, 108, 136), Color.fromARGB(255, 63, 76, 107)], // ASH
  ];

  String title = "";
  String description = "";
  VoidCallback onPressed;
  List<Color> backgroundColor;

  ArticleFolder(this.title, this.description, this.onPressed){
    this.backgroundColor
    = BACKGROUND_COLORS[Random.secure().nextInt(BACKGROUND_COLORS.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: FlatButton(
        onPressed: onPressed,
        child: Card(
          shape:  RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11.0),
          ),
          elevation: 10,
          child: Column(
            children: [
              Flexible(
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: backgroundColor
                        )
                    ),
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: Center(
                      child : /*FittedBox(
                          fit:BoxFit.fitHeight,
                          child: */Text(title,
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )
                      //),
                    )
                ),
                flex: 8,),
              Flexible(child: Container(child: Center( child: Text(description)),), flex: 2,)
            ],
          ),
        ),
      ),
    );
  }
}

class Article extends StatelessWidget {
  String articleName;
  VoidCallback onPressed;
  
  Article(this.articleName, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return ArticleFolder(articleName, "📖", this.onPressed);
  }
}

