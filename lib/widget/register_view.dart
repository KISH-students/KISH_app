import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/login_background.dart';
import 'package:toasta/toasta.dart';

import 'custom_text_form_field.dart';

class RegisterView extends StatefulWidget {
  RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() {
    return _RegisterViewState();
  }
}

class _RegisterViewState extends State<RegisterView> {
  final FlutterSecureStorage storage = new FlutterSecureStorage();

  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  TextEditingController ckController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController seqController = TextEditingController();
  Key idKey = GlobalKey();
  Key pwKey = GlobalKey();
  Key ckKey = GlobalKey();
  Key nameKey = GlobalKey();
  Key seqKey = GlobalKey();

  bool isRegistering = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    idController.dispose();
    pwController.dispose();
    seqController.dispose();
    ckController.dispose();
    nameController.dispose();
  }


  void resetControllers() {
    idController = TextEditingController();
    pwController = TextEditingController();
    seqController = TextEditingController();
    ckController = TextEditingController();
    nameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          LoginBackground(),
          Center(
            key: UniqueKey(),
            child: Container(
                margin: EdgeInsets.only(left: 50, right: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ListView(
                      key: UniqueKey(),
                      shrinkWrap: true,
                      children: [
                        CustomTextFromField(idController,
                            key: idKey,
                            labelText: "아이디",
                            icon: CupertinoIcons.person),
                        CustomTextFromField(pwController,
                            key: pwKey,
                            labelText: "비밀번호",
                            icon: CupertinoIcons.lock,
                            isPassword: true),
                        CustomTextFromField(ckController,
                            key: ckKey,
                            labelText: "비밀번호 확인",
                            icon: CupertinoIcons.lock_rotation,
                            isPassword: true),
                        CustomTextFromField(seqController,
                            key: seqKey,
                            labelText: "학생증 ID",
                            icon: CupertinoIcons.creditcard
                        ),
                        CustomTextFromField(nameController,
                            labelText: "이름",
                            icon: CupertinoIcons.at)
                      ],
                    ),

                    RaisedButton(
                        onPressed: () async {
                          if (isRegistering) {
                            Toasta(context).toast(Toast(subtitle: "이미 회원가입 중입니다"));
                            return;
                          }
                          isRegistering = true;

                          idController.text = idController.text.trim();
                          seqController.text = seqController.text.trim();
                          ckController.text = ckController.text.trim();
                          pwController.text = pwController.text.trim();
                          nameController.text = nameController.text.trim();
                          if (ckController.text != pwController.text) {
                            Toasta(context).toast(Toast(subtitle: "확인 비밀번호가 다릅니다"));
                            isRegistering = false;
                            return;
                          }

                          Toasta(context).toast(Toast(subtitle: "회원 확인 중..."));
                          Map isMemberData = await (ApiHelper.isLibraryMember(
                              seqController.text, nameController.text)) as Map<dynamic, dynamic>;

                          if (isMemberData["result"] != "0") {
                            if (isMemberData["result"] == "1") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("회원을 찾을 수 없습니다.\n"
                              "성명과 학생증 ID 확인해주세요."))
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("${isMemberData["message"]}"))
                              );
                            }
                            isRegistering = false;
                            return;
                          }

                          Toasta(context).toast(Toast(subtitle: "회원가입 중..."));
                          Map registerData = await (ApiHelper.registerToLibrary(
                              seqController.text,
                              idController.text,
                              pwController.text,
                              ckController.text)) as Map<dynamic, dynamic>;

                          if (registerData["result"] != "0") {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("${registerData["message"]}"))
                            );
                          } else {
                            await storage.write(key: "id", value: idController.text.trim());
                            await storage.write(key: "pw", value: pwController.text.trim());

                            Map data = new Map();
                            data["result"] = "success";
                            Navigator.pop(context, data);
                          }

                          isRegistering = false;
                        },
                        child: Text("회원가입", style: TextStyle(fontFamily: "NanumSquareR", color: Colors.white70)),
                        color: Colors.white38,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                        )
                    ),
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
                  ],
                )),
          )
        ]);
  }
}