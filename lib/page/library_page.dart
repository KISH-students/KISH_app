import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/DetailedCard.dart';
import 'package:kish2019/widget/login_view.dart';
import 'package:kish2019/widget/title_text.dart';

class LibraryPage extends StatefulWidget {
  LibraryPage({Key? key}) : super(key: key);

  @override
  _LibraryPageState createState() {
    return _LibraryPageState();
  }
}

class _LibraryPageState extends State<LibraryPage> with AutomaticKeepAliveClientMixin<LibraryPage>{
  final FlutterSecureStorage storage = new FlutterSecureStorage();

  late Widget body;

  @override
  void initState() {
    super.initState();

    setDefaultBody();
    initWidgets();
  }

  Future<void> initWidgets() async {
    if (!this.mounted) {
      await Future<void>.delayed(Duration(milliseconds: 10), () {
        initWidgets();
      });
    } else {
      loadBodyWidget();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return body;
  }

  Future<void> loadBodyWidget() async {
    String? id = await storage.read(key: "id");
    String? pw = await storage.read(key: "pw");

    if(id == null || pw == null) {
      Map? result = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => LoginView()));

      processLoginResult(result);
    } else {
      if (LoginView.isLoggined) {
        setState(() {
          setBodyToLoggedInBody();
        });
      } else {
        Map result = await LoginView.login();
        if (result["result"] == LoginView.SUCCESS) {
          setBodyToLoggedInBody();
        } else if (result["result"] == LoginView.IN_PROGRESS) {
          Future.delayed(Duration(seconds: 1), (){
            loadBodyWidget();
          });
        } else if (result["result"] == LoginView.FAIL) {
          Map? result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => LoginView()));

          processLoginResult(result);
        } else {
          throw Exception("잘못된 result 값");
        }
      }
    }
  }

  void processLoginResult(Map? resultMap) {
    if (resultMap != null && resultMap["result"] == "success") {
      setBodyToLoggedInBody();
    }
  }

  void setDefaultBody() {
    body = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoButton.filled(
              onPressed: (){
                loadBodyWidget();
              }, child: Text("다시 시도"))
        ]
    );
  }

  void setBodyToLoggedInBody() {
    setState(() {
      body = SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.only(top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  getMyInfoCard(),
                  Container(
                      margin: EdgeInsets.all(10),
                      child: DetailedCard(
                          title: "더 추가됩니다",
                          content: "추후 내가 대출한 도서, 신규 도서 등의 정보를 확인할 수 있어요.",
                          bottomTitle: "시간이 없어서...")
                  ),
                ],
              )
          )
      );
    });
  }

  Widget getMyInfoCard() {
    return FutureBuilder(
        future: ApiHelper.getLibraryMyInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            if (snapshot.hasData) {
              Map data = snapshot.data as Map;

              dynamic resultCode = data["result"];
              if (data["result"] != "0") {
                Fluttertoast.showToast(msg: data["message"]);

                if (resultCode == "2") {
                  this.initWidgets();
                  return Container();
                }
              }

              return Container(
                  width: double.infinity,
                  child: Container(
                    //color: Color.fromARGB(255, 87, 113, 255),
                    color: Color.fromARGB(255, 11, 15, 33),
                    margin: EdgeInsets.symmetric(vertical: 50),
                    width: 300,
                    child: Container(
                        width: double.infinity,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Text(
                                  "이름 : ${data["name"]}\n"
                                      "대출가능권수 : ${data["numberLoanableBooks"]}\n"
                                      "대출제한일 : ${data["loanRestrictionDate"]}\n"
                                      "대출권수 : ${data["numberLoanBooks"]}\n"
                                      "연체권수 : ${data["numberOverdueBooks"]}\n"
                                      "예약권수 : ${data["numberReservedBooks"]}",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.95),
                                      fontSize: 15,
                                      fontFamily: "CRB"),
                                ),
                              ),
                              Container(
                                  child: Center(
                                      child: FlatButton(
                                          onPressed: () async {
                                            await storage.delete(key: "id");
                                            await storage.delete(key: "pw");
                                            LoginView.isLoggined = false;
                                            LoginView.isAdmin = false;
                                            LoginView.seq = "";
                                            this.initWidgets();
                                          },
                                          color: Color.fromARGB(255, 75, 0, 19),
                                          child: Text("로그아웃", style: TextStyle(fontFamily: "CRB", color: Colors.white))
                                      )
                                  )
                              )
                            ]
                        )
                    ),
                  )
              );
            } else {
              return Container(
                  width: double.infinity,
                  child: Card(
                      color: Colors.orangeAccent,
                      child: TitleText("불러오지 못했습니다")
                  )
              );
            }
          }
          return YoutubeShimmer();
        });
  }

  @override
  bool get wantKeepAlive => true;
}