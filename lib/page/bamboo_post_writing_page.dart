import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BambooPostWritingPage extends StatefulWidget {
  BambooPostWritingPage({Key? key}) : super(key: key);

  @override
  _BambooPostWritingPageState createState() {
    return _BambooPostWritingPageState();
  }
}

class _BambooPostWritingPageState extends State<BambooPostWritingPage> {
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
                    builder: (BuildContext context1) {
                      return AlertDialog(
                        title: const Text('정말 글 쓰기를 취소할까요?'),
                        content: SingleChildScrollView(
                          child: const Text('글 쓰기를 취소하면 작성 중이던 내용이 사라져요.'),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('아니요'),
                            onPressed: () {
                            },
                          ),
                          TextButton(
                            child: const Text('네'),
                            onPressed: () {
                              Navigator.of(context1).pop();
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
                onPressed: (){}
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
                  keyboardType: TextInputType.multiline,
                  minLines: null,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                      hintText: "질문/썰/고민 등을 공유해보세요!\n완벽하게 익명이 보장됩니다.\n단, 혐오 조장과 같은 부적절한 글을 게시할 경우 불이익을 받으실 수 있습니다.",
                      border: InputBorder.none
                  ),
                )
            )
        )
      ],
    );
  }
}