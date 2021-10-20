import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kish2019/main.dart';
import 'package:kish2019/noti_manager.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/custom_text_form_field.dart';
import 'package:kish2019/widget/register_view.dart';
import 'package:toasta/toasta.dart';

import 'login_background.dart';

class LoginView extends StatefulWidget {
  static final int SUCCESS = 0;
  static final int IN_PROGRESS = 1;
  static final int FAIL = 2;

  static final FlutterSecureStorage storage = new FlutterSecureStorage();
  static bool isLogining = false;
  static bool isLoggined = false;
  static String seq = "";
  static bool isAdmin = false;

  LoginView({Key? key}) : super(key: key);

  static Future<Map> login() async {
    Map resultMap = new Map();

    if (isLogining) {
      BuildContext? mainContext = MyApp.navigatorKey.currentContext;
      if (mainContext != null) {
        Toasta(mainContext).toast(Toast(subtitle: "이미 로그인 중입니다"));
      }

      resultMap["result"] = IN_PROGRESS;
      return resultMap;
    }

    isLogining = true;
    String? id = await storage.read(key: "id");
    String? pw = await storage.read(key: "pw");

    if (id == null || pw == null) {
      resultMap["result"] = FAIL;
      isLogining = false;
      return resultMap;
    }

    Map? result = await ApiHelper.loginToLibrary(id, pw);
    isLogining = false;

    if (result!["result"] != "0") {
      resultMap["result"] = FAIL;
      resultMap["msg"] = result["message"];
    } else {
      resultMap["result"] = SUCCESS;
      seq = result["seq"];
      isAdmin = result['admin'];
      isLoggined = true;

      NotificationManager manager = NotificationManager.getInstance();
      bool bambooNotiEnabled = await manager.bambooNoti.isEnabled();
      ApiHelper.toggleBambooNotification(bambooNotiEnabled, seq);
    }

    return resultMap;
  }

  static Future<void> logout() async {
    await ApiHelper.logoutFromLibrary();

    LoginView.isLoggined = false;
    LoginView.isAdmin = false;
    LoginView.seq = "";
    await storage.delete(key: "id");
    await storage.delete(key: "pw");
  }

  @override
  _LoginViewState createState() {
    return _LoginViewState();
  }
}

class _LoginViewState extends State<LoginView> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  Key _idKey = new GlobalKey();
  Key _pwKey = new GlobalKey();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      autoFill();
    });
  }

  Future<void> autoFill() async {
    String? id = await LoginView.storage.read(key: "id");
    String? pw = await LoginView.storage.read(key: "pw");

    if (id != null && pw != null) {
      setState(() {
        idController.text = id;
        pwController.text = pw;
      });
    }
  }

  Future<void> login() async {
    Map result =  await LoginView.login();
    int resultCode = result["result"];

    if (resultCode == LoginView.FAIL) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${result["msg"]}"))
        );
      });
    } else if (resultCode == LoginView.IN_PROGRESS) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("이미 로그인 중입니다.\n잠시 후 다시 시도하세요"))
      );
    } else if (resultCode == LoginView.SUCCESS) {
      Map data = new Map();
      data["result"] = "success";
      Navigator.pop(context, data);
      Toasta(context).toast(Toast(subtitle: "로그인에 성공하였습니다"));
    }
  }

  @override
  void dispose() {
    super.dispose();

    idController.dispose();
    pwController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          LoginBackground(),
          Center(
            child: Container(
                margin: EdgeInsets.only(left: 50, right: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("KISHA", style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                    ),
                        textAlign: TextAlign.center),
                    const Text("KISH학생임을 인증하세요", style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w100
                    ),
                        textAlign: TextAlign.center),
                    Column(
                      children: [
                        CustomTextFromField(idController,
                            key: _idKey,
                            labelText: "아이디",
                            icon: CupertinoIcons.person),
                        CustomTextFromField(pwController,
                            key: _pwKey,
                            labelText: "비밀번호",
                            icon: CupertinoIcons.lock,
                            isPassword: true)
                      ],
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton(
                              onPressed: () async {
                                await LoginView.storage.write(key: "id", value: idController.text.trim());
                                await LoginView.storage.write(key: "pw", value: pwController.text.trim());

                                login();
                              },
                              child: Text("로그인", style: TextStyle(fontFamily: "NanumSquareR", color: Colors.white70)),
                              color: Colors.blueGrey.shade600,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)
                              )
                          ),
                          SizedBox(width: 5,),
                          RaisedButton(
                              onPressed: () async {
                                Map? data = await Navigator.push(context, new MaterialPageRoute(
                                    builder: (context) => RegisterView()));

                                if (data != null && data["result"] == "success") {
                                  this.login();
                                }
                              },
                              child: Text("회원가입", style: TextStyle(fontFamily: "NanumSquareR", color: Colors.white70)),
                              color: Colors.white38,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)
                              )
                          ),
                          SizedBox(width: 5,),
                          RaisedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                              child: Text("나가기", style: TextStyle(fontFamily: "NanumSquareR", color: Colors.white70)),
                              color: Colors.red.shade600.withOpacity(0.8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)
                              )
                          ),
                        ]),
                  ],
                )),
          )
        ]);
  }
}