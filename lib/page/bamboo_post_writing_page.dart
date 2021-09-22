import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/login_view.dart';

class BambooPostWritingPage extends StatefulWidget {
  BambooPostWritingPage({Key? key}) : super(key: key);

  @override
  _BambooPostWritingPageState createState() {
    return _BambooPostWritingPageState();
  }
}

class _BambooPostWritingPageState extends State<BambooPostWritingPage> with AutomaticKeepAliveClientMixin<BambooPostWritingPage>{
  bool sending = false;
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                icon: Icon(CupertinoIcons.xmark),
                color: Colors.redAccent,
                onPressed: (){
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('정말 글 쓰기를 취소할까요?'),
                        content: SingleChildScrollView(
                          child: const Text('글 쓰기를 취소하면 작성 중이던 내용이 사라져요.'),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('아니요'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('네'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
            ),
            Text("익명 글 작성", style: TextStyle(fontSize: 18)),
            IconButton(
                icon: Icon(CupertinoIcons.paperplane_fill),
                color: Colors.blueGrey,
                onPressed: (){
                  if (sending) {
                    Fluttertoast.showToast(msg: "이미 작성 중 입니다.");
                    return;
                  }

                  sending = true;
                  writePost();
                }
            )
          ],
        ),
        Divider(),
        Expanded(
            child: Container(
                margin: EdgeInsets.all(10),
                width: double.infinity,
                height: double.infinity,
                child: TextFormField(
                  scrollPhysics: BouncingScrollPhysics(),
                  controller: controller,
                  keyboardType: TextInputType.multiline,
                  minLines: null,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                      hintText: "질문/썰/고민 등을 완전 익명으로 공유해보세요.\n"
                          "단, 악성 글을 게시할 경우 서비스 제제를 받을 수 있으며,\n"
                          "학교 폭력과 같은 이유로 학교측이 정보를 요구할 경우,\n"
                          "정보가 제공될 수 있습니다.",
                      hintStyle: TextStyle(overflow: TextOverflow.clip),
                      border: InputBorder.none
                  ),
                )
            )
        )
      ],
    );
  }

  Future<void> writePost() async {
    String text = controller.text;
    if (text.length < 5) {
      Fluttertoast.showToast(msg: "글이 너무 짧습니다.");
      sending = false;
      return;
    }

    Map response = await ApiHelper.writeBambooPost(LoginView.seq, text);
    bool success = response['success'];
    String msg = response['message'];

    Fluttertoast.showToast(msg: msg);
    if (success) {
      Navigator.pop(context);
    }
    sending = false;
  }

  @override
  bool get wantKeepAlive => true;
}