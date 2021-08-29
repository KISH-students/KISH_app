import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class BambooPostViewer extends StatefulWidget {
  Map data;
  BambooPostViewer(this.data, {Key? key}) : super(key: key);

  @override
  _BambooPostViewerState createState() {
    return _BambooPostViewerState();
  }
}

class _BambooPostViewerState extends State<BambooPostViewer> {
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
    Size size = MediaQuery.of(context).size;
    return Stack(
        children: [
          Expanded(
            child: ListView(
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.fromLTRB(30, 20, 40, 0),
                    width: double.infinity,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_back_ios),
                                  iconSize: 22,
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                ),
                                Text("#91번째 외침",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 20,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: "NanumSquareR"
                                    )
                                ),
                              ]
                          ),
                          Text("2021/08/29",
                              style: TextStyle(color: Colors.grey.shade600)),
                        ]
                    )
                ),
                Divider(),
                Container(
                  margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text("본문",
                            style: TextStyle(fontSize: 16, height: 1.8, fontWeight: FontWeight.w500),)
                      ),
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        LikeButton(
                          size: 17,
                          circleColor:
                          CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
                          bubblesColor: BubblesColor(
                            dotPrimaryColor: Color(0xff33b5e5),
                            dotSecondaryColor: Color(0xff0099cc),
                          ),
                          likeBuilder: (bool isLiked) {
                            return Icon(
                              CupertinoIcons.heart_fill,
                              color: isLiked ? Colors.red : Colors.grey,
                              size: 17,
                            );
                          },
                          likeCount: 0,
                          countBuilder: (int? count, bool isLiked, String text) {
                            var color = isLiked ? Colors.red : Colors.grey;
                            Widget result;
                            if (count == 0) {
                              result = Text(
                                "0",
                                style: TextStyle(color: color),
                              );
                            } else
                              result = Text(
                                text,
                                style: TextStyle(color: color),
                              );
                            return result;
                          },
                        )
                      ],
                    )
                ),
                Divider(),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("댓글",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25
                          )
                      ),
                      Text(" 15",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Colors.grey.shade500
                          )
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    _Comment(),
                    _Comment(),
                    _Comment(),
                    _Comment(),
                    _Comment(),
                    Container(height: size.height * 0.07)
                  ],
                )
              ],
            ),
          ),
          Positioned(
              bottom: 0,
              child: Column(
                  children: [
                    Container(
                        height: size.height * 0.07,
                        width: size.width,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 248, 248, 248)
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 7),
                                  width: double.infinity,
                                  child: Row(
                                      children: [
                                        Expanded(
                                          flex: 9,
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                fillColor: Colors.blueGrey,
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                hintText: "댓글을 달아주세요 :D",
                                                hintStyle: TextStyle(fontFamily: "NanumSquareL")
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: CupertinoButton(
                                                child: Icon(CupertinoIcons.paperplane),
                                                onPressed: (){}
                                            )
                                        )
                                      ]
                                  )
                              )
                            ]
                        )
                    ),
                  ]
              )
          )
        ]
    );
  }
}

class _Comment extends StatefulWidget {
  _Comment({Key? key}) : super(key: key);

  @override
  _CommentState createState() {
    return _CommentState();
  }
}

class _CommentState extends State<_Comment> {
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
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                children: [
                  Container(width: 8),
                  Text("작성자",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "NanumSquareL",
                          fontSize: 15
                      )
                  ),
                ]
            ),
            Container(
                margin: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Text("댓글 내용",
                            style: TextStyle(
                                fontSize: 15
                            )),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 20, 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            MaterialButton(onPressed: (){}, child: Text("답글 달기")),
                            LikeButton(
                              size: 15,
                              circleColor:
                              CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
                              bubblesColor: BubblesColor(
                                dotPrimaryColor: Color(0xff33b5e5),
                                dotSecondaryColor: Color(0xff0099cc),
                              ),
                              likeBuilder: (bool isLiked) {
                                return Icon(
                                  CupertinoIcons.heart_fill,
                                  color: isLiked ? Colors.red : Colors.grey,
                                  size: 15,
                                );
                              },
                              likeCount: 0,
                              countBuilder: (int? count, bool isLiked, String text) {
                                var color = isLiked ? Colors.red : Colors.grey;
                                Widget result;
                                if (count == 0) {
                                  result = Text(
                                    "0",
                                    style: TextStyle(color: color),
                                  );
                                } else
                                  result = Text(
                                    text,
                                    style: TextStyle(color: color),
                                  );
                                return result;
                              },
                            ),
                          ],
                        ),
                      )
                    ]
                )
            ),
          ],
        )
    );
  }
}

class _Reply extends StatelessWidget {
  _Reply({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container();
  }
}
