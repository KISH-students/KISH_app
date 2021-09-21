import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/login_view.dart';
import 'package:like_button/like_button.dart';

class BambooPostViewer extends StatefulWidget {
  final int id;
  BambooPostViewer(this.id, {Key? key}) : super(key: key);

  @override
  _BambooPostViewerState createState() {
    return _BambooPostViewerState();
  }
}

class _BambooPostViewerState extends State<BambooPostViewer> {
  String date = "";
  String content = "불러오는 중 입니다";
  int likes = 0;
  bool liked = false;
  bool sendingComment = false;
  int commentCount = 0;
  List<Widget> comments = [CircularProgressIndicator()];
  TextEditingController commentController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async{
    Map post = await ApiHelper.getBambooPost(LoginView.seq, widget.id);

    /* 댓글 처리 */
    List<Widget> temp = [];
    List comments = post['comment'];

    comments.forEach((element) {
      List<Widget> replyComments = [];
      List replies = element['replies'];

      replies.forEach((element2) {
        _Comment reply = new _Comment(
          name: element2['comment_author_displayname'],
          content: element2['comment_content'],
          likes: element2['likes'],
          liked: element2['liked'],
          isReply: true,
          id: element['comment_id'],
        );

        replyComments.add(reply);
      });

      _Comment comment = new _Comment(
        name: element['comment_author_displayname'],
        content: element['comment_content'],
        likes: element['likes'],
        liked: element['liked'],
        isReply: false,
        id: element['comment_id'],
        replies: replyComments,
      );
      temp.add(comment);
    });

    setState(() {
      this.content = post['post']['bamboo_content'];  //본문
      this.liked = post['post']['liked'];   //공감 여부
      this.commentCount = post['comment'].length;   //댓글 개수
      this.likes = post['post']['likeCount'];   //좋아요 개수
      this.comments = temp;   //댓글
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(30, 30, 40, 0),
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
                        Text("#${widget.id}번째 외침",
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 20,
                                //fontWeight: FontWeight.bold,
                                fontFamily: "NanumSquareR"
                            )
                        ),
                      ]
                  ),
                  Text(this.date,
                      style: TextStyle(color: Colors.grey.shade600)),
                ]
            ),
          ),
          Divider(),
          Expanded(
            child: ListView(
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(content,
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
                          isLiked: liked,
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
                          likeCount: likes,
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
                      Text(" $commentCount",
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
                  children: [...comments, Container(height: size.height * 0.07)],
                )
              ],
            ),
          ),
          Column(
              children: [
                Container(
                  //height: size.height * 0.07,
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
                                        controller: this.commentController,
                                        keyboardType: TextInputType.multiline,
                                        minLines: 1,
                                        maxLines: 5,
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
                                            onPressed: () {
                                              Fluttertoast.showToast(msg: "댓글을 등록하는 중...");

                                              if (sendingComment) {
                                                return;
                                              }
                                              sendComment();
                                            }
                                        ))
                                  ]
                              )
                          )
                        ]
                    )
                ),
              ]
          )
        ]
    );
  }

  Future<void> sendComment() async {
    this.sendingComment = true;   // 댓글 중복 등록 방지

    String content = this.commentController.text;
    Map? response = await ApiHelper.writeBambooComment(LoginView.seq, widget.id, content);

    if (response == null) {
      Fluttertoast.showToast(msg: "인터넷 상태를 확인해주세요.");
      return;
    }

    bool success = response['success'];
    String msg = response['message'];

    if (success) { // 등록 성공
      Fluttertoast.showToast(msg: msg);
    } else { // 등록 실패
      Fluttertoast.showToast(msg: msg);
    }
    this.commentController.text = "";   // 댓글 초기화
    this.sendingComment = false;    // 댓글 등록 상태 x

    //TODO: 댓글 새로고침 개선
    load();   // 본문을 새로고칩니다 ......
  }
}

class _Comment extends StatefulWidget {
  final String name;
  final String content;
  final int likes;
  final bool liked;
  final bool isReply;
  final int id; //만약 답글일경우 부모 댓글의 id가 됩니다.

  final List<Widget> replies;
  _Comment({this.name: "", this.content: "", this.likes: 0, this.isReply: false,
    this.liked: false, this.id: -1, this.replies: const [], Key? key}) : super(key: key);

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
    return Column(
        children: [
          Container(
              margin: EdgeInsets.fromLTRB(
                  widget.isReply? 35 : 22,
                  widget.isReply? 4 : 18,
                  22,
                  widget.isReply? 4 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      children: [
                        Container(width: 8),
                        Text(widget.name,
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
                              child: Text(widget.content,
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
                                    isLiked: widget.liked,
                                    likeCount: widget.likes,
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
          ),
          ...(widget.replies)
        ]
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
