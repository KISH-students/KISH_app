import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/DetailedCard.dart';
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
  List<Widget?> fieldList = [];

  TextFormField? idField;
  TextFormField? pwField;
  TextEditingController? idController;
  TextEditingController? pwController;
  TextEditingController? ckController;
  TextEditingController? nameController;
  TextEditingController? seqController;

  bool isResistering = false;
  bool isLogining = false;

  @override
  void initState() {
    super.initState();

    body = Container();
    initWidgets();
  }

  Future<void> initWidgets() async {
    if (!this.mounted) {
      await Future<void>.delayed(Duration(milliseconds: 10), () {
        initWidgets();
      });
    } else {
      body = SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LinearProgressIndicator(),
              ]
          )
      );

      loadBodyWidget();
    }
  }

  void initFields() {
    idController = TextEditingController();
    pwController = TextEditingController();
    seqController = TextEditingController();
    ckController = TextEditingController();
    nameController = TextEditingController();

    idField = TextFormField(
        key: UniqueKey(),
        controller: idController,
        decoration: InputDecoration(
            icon: const Icon(CupertinoIcons.person),
            fillColor: Colors.grey,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
            labelText: "아이디"));

    pwField = TextFormField(
        key: UniqueKey(),
        controller: pwController,
        enableSuggestions: false,
        autocorrect: false,
        obscureText: true,
        obscuringCharacter: "*",
        decoration: InputDecoration(
            icon: const Icon(CupertinoIcons.lock),
            fillColor: Colors.grey,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
            labelText: "비밀번호"));

    fieldList = [idField, pwField];
  }

  @override
  void dispose() {
    super.dispose();

    if (idController != null) {
      idController!.dispose();
      pwController!.dispose();
      seqController!.dispose();
      ckController!.dispose();
      nameController!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return body;
  }

  Future<void> loadBodyWidget() async {
    String? id = await storage.read(key: "id");
    String? pw = await storage.read(key: "pw");

    if(id == null || pw == null) {
      setState(() {
        initFields();
        body = getLoginForm();
      });
    } else {
      login();
    }
  }

  void login() async {
    if (isLogining) {
      Fluttertoast.showToast(msg: "이미 로그인 중입니다");
      return;
    }
    isLogining = true;

    String? id = await storage.read(key: "id");
    String? pw = await storage.read(key: "pw");

    Map? result = await ApiHelper.loginToLibrary(id, pw);

    setState(() {
      if (result!["result"] != "0") {
        Fluttertoast.showToast(msg: result["message"]);
        initFields();
        body = getLoginForm();
      } else {
        Fluttertoast.showToast(msg: "로그인에 성공하였습니다.");
        body = getLoggedInBody();
      }
    });

    isLogining = false;
  }

  Widget getLoggedInBody() {
    return SingleChildScrollView(
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

  Widget getLoginForm() {
    return Center(
      child: Container(
          margin: EdgeInsets.only(left: 50, right: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListView.builder(
                key: UniqueKey(),
                shrinkWrap: true,
                itemCount: fieldList.length,
                itemBuilder: (context, index) {
                  return fieldList[index]!;
                },
              ),

              RaisedButton(
                  onPressed: () async {
                    await storage.write(key: "id", value: idController!.text.trim());
                    await storage.write(key: "pw", value: pwController!.text.trim());

                    login();
                  },
                  child: Text("로그인", style: TextStyle(fontFamily: "NanumSquareR", color: Colors.white70)),
                  color: Colors.blueAccent.withAlpha(100),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                  )
              ),
              RaisedButton(
                  onPressed: () async {
                    if (fieldList.length < 3) {
                      List<Widget?> newFields = [...fieldList];

                      setState(() {
                        newFields.add(TextFormField(
                            key: UniqueKey(),
                            controller: ckController,
                            enableSuggestions: false,
                            autocorrect: false,
                            obscureText: true,
                            obscuringCharacter: "*",
                            decoration: InputDecoration(
                                icon: const Icon(CupertinoIcons.lock_rotation_open),
                                fillColor: Colors.redAccent,
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                                labelText: "비밀번호 확인")));

                        newFields.add(TextFormField(
                            key: UniqueKey(),
                            controller: seqController,
                            decoration: InputDecoration(
                                icon: const Icon(CupertinoIcons.heart_solid),
                                fillColor: Colors.redAccent,
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                                labelText: "학생증 ID")));

                        newFields.add(TextFormField(
                            key: UniqueKey(),
                            controller: nameController,
                            decoration: InputDecoration(
                                icon: const Icon(CupertinoIcons.info),
                                fillColor: Colors.blueAccent,
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                                labelText: "이름")));
                        fieldList = newFields;
                        body = getLoginForm();
                      });

                      Fluttertoast.showToast(msg: "빈 칸을 채워주세요");
                    } else {
                      if (isResistering) {
                        Fluttertoast.showToast(msg: "이미 회원가입 중입니다.");
                        return;
                      }
                      isResistering = true;

                      idController!.text = idController!.text.trim();
                      seqController!.text = seqController!.text.trim();
                      ckController!.text = ckController!.text.trim();
                      pwController!.text = pwController!.text.trim();
                      nameController!.text = nameController!.text.trim();
                      if (ckController!.text != pwController!.text) {
                        Fluttertoast.showToast(msg: "확인 비밀번호가 다릅니다");
                        isResistering = false;
                        return;
                      }

                      Fluttertoast.showToast(msg: "회원 확인 중...");
                      Map isMemberData = await (ApiHelper.isLibraryMember(
                          seqController!.text, nameController!.text)) as Map<dynamic, dynamic>;

                      if (isMemberData["result"] != "0") {
                        if (isMemberData["result"] == "1") {
                          Fluttertoast.showToast(
                              msg: "회원을 찾을 수 없습니다.\n"
                                  "성명과 학생증 ID 확인해주세요.", toastLength: Toast.LENGTH_LONG);
                        } else {
                          Fluttertoast.showToast(msg: isMemberData["message"]);
                        }
                        isResistering = false;
                        return;
                      }

                      Fluttertoast.showToast(msg: "회원가입 중...");
                      Map registerData = await (ApiHelper.registerToLibrary(
                          seqController!.text,
                          idController!.text,
                          pwController!.text,
                          ckController!.text)) as Map<dynamic, dynamic>;

                      if (registerData["result"] != "0") {
                        Fluttertoast.showToast(msg: registerData["message"], toastLength: Toast.LENGTH_LONG);
                      } else {
                        await storage.write(key: "id", value: idController!.text.trim());
                        await storage.write(key: "pw", value: pwController!.text.trim());

                        login();
                      }

                      isResistering = false;
                    }
                  },
                  child: Text("회원가입", style: TextStyle(fontFamily: "NanumSquareR", color: Colors.white70)),
                  color: Color.fromARGB(100, 114, 67, 29),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                  )
              ),
            ],
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}