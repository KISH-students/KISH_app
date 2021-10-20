import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/login_view.dart';
import 'package:toasta/toasta.dart';

class BambooPostWritingPage extends StatefulWidget {
  BambooPostWritingPage({Key? key}) : super(key: key);

  @override
  _BambooPostWritingPageState createState() {
    return _BambooPostWritingPageState();
  }
}

class _BambooPostWritingPageState extends State<BambooPostWritingPage> with AutomaticKeepAliveClientMixin<BambooPostWritingPage>{
  bool sending = false;
  TextEditingController contentEditingController = new TextEditingController();
  TextEditingController titleEditingController = new TextEditingController();

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
                  readyToWrite(context);
                }
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextFormField(
              controller: titleEditingController,
              decoration: InputDecoration(
                  hintText: "제목을 입력해주세요",
                  hintStyle: TextStyle(overflow: TextOverflow.clip),
                  border: InputBorder.none
              )),
        ),
        Divider(),
        Expanded(
            child: Container(
                margin: EdgeInsets.all(10),
                width: double.infinity,
                height: double.infinity,
                child: TextFormField(
                  scrollPhysics: BouncingScrollPhysics(),
                  controller: contentEditingController,
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

  Future<void> readyToWrite(BuildContext context) async {
    String title = titleEditingController.text;
    String content = contentEditingController.text;

    if (title.trim().isEmpty) {
      Toasta(context).toast(Toast(subtitle: "제목을 입력해주세요"));
      return;
    }
    if (content.trim().length < 5) {
      Toasta(context).toast(Toast(subtitle: "글이 너무 짧습니다"));
      return;
    }
    showCheckingDialog();
  }

  void showCheckingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return CheckDialog(this);
      },
    );
  }

  Future<void> writePost(bool facebook) async{
    if (sending) {
      Toasta(context).toast(Toast(subtitle: "이미 처리 중 입니다"));
      return;
    }

    Toasta(context).toast(Toast(subtitle: "게시물 등록 중..."));

    sending = true;
    String title = titleEditingController.text;
    String content = contentEditingController.text;

    try {
      Map response = await ApiHelper.writeBambooPost(
          LoginView.seq, title, content, facebook);
      bool success = response['success'];
      String msg = response['message'];

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$msg"))
      );
      if (success) {
        Navigator.pop(context);
      }
    } catch(e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("처리하지 못했습니다.\n인터넷 상태를 확인해주세요."))
      );
    } finally {
      sending = false;
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class CheckDialog extends StatefulWidget {
  final _BambooPostWritingPageState pageState;
  const CheckDialog(this.pageState, {Key? key}) : super(key: key);

  @override
  _CheckDialogState createState() => _CheckDialogState();
}

class _CheckDialogState extends State<CheckDialog> {
  bool? facebook = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('글 등록'),
      content: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('글을 등록할까요?'),
                Container(height: 10,),
                Row(
                    children: [
                      Checkbox(value: facebook, onChanged: (v){
                        setState(() {
                          facebook = v!;
                        });
                      }),
                      Expanded(
                        child: Text("페이스북 KISH 대나무숲에 익명으로 게시",
                        overflow: TextOverflow.clip),
                      )
                    ]
                )
              ])
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('아니요'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('네'),
          onPressed: () {
            Navigator.of(context).pop();
            widget.pageState.writePost(facebook as bool);
          },
        ),
      ],
    );
  }
}
