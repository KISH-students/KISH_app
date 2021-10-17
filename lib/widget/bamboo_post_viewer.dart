import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/login_view.dart';
import 'package:like_button/like_button.dart';

class BambooPostViewer extends StatefulWidget {
  final int id;
  final int commentIdToView;  // 확인 할 댓글
  BambooPostViewer(this.id, {this.commentIdToView: -1, Key? key}) : super(key: key);

  @override
  _BambooPostViewerState createState() {
    return _BambooPostViewerState();
  }
}

class _BambooPostViewerState extends State<BambooPostViewer> with AutomaticKeepAliveClientMixin<BambooPostViewer>{
  String title = "";
  String date = "";
  String content = "불러오는 중 입니다";
  int likes = 0;
  bool liked = false;
  bool sendingComment = false;
  bool iAmAuthor = false;
  int commentCount = 0;
  List<Widget> comments = [CupertinoActivityIndicator()];
  TextEditingController commentController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async{
    Map post = await ApiHelper.getBambooPost(LoginView.seq, widget.id);
    if (post['comment'] == null) {
      Fluttertoast.showToast(msg: "존재하지 않는 게시물입니다.");
      Navigator.pop(context);
      return;
    }

    /* 댓글 처리 */
    List<Widget> temp = [];
    List comments = post['comment'];

    comments.forEach((parentComment) {
      List<Widget> replyComments = [];
      List replies = parentComment['replies'];

      replies.forEach((element2) {
        _Comment reply = new _Comment(
          name: element2['comment_author_displayname'],
          content: element2['comment_content'],
          likes: element2['likes'],
          liked: element2['liked'],
          isReply: true,
          inReplyScreen: true,
          iAmAuthor: element2['IAmAuthor'],
          id: element2['comment_id'],
          parentId: parentComment['comment_id'],
          postId: widget.id,
        );

        replyComments.add(reply);
      });

      _Comment comment = new _Comment(
        name: parentComment['comment_author_displayname'],
        content: parentComment['comment_content'],
        likes: parentComment['likes'],
        liked: parentComment['liked'],
        isReply: false,
        iAmAuthor: parentComment['IAmAuthor'],
        id: parentComment['comment_id'],
        postId: widget.id,
        replies: replyComments,
      );

      // 답글도 없으면 삭제된 댓글 표시 안 함
      if (!(comment.removed && comment.replies.length == 0)) {
        temp.add(comment);

        if (widget.commentIdToView == comment.id) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return Scaffold(
                body: CommentReplyScreen(tempComment: comment, postId: comment.postId)
            );
          }));
        }
      }
    });

    // 댓글 개수 처리. 대댓글도 포함합니다.
    int tempCount;
    tempCount = temp.length;   //댓글 개수
    temp.forEach((element) {
      _Comment comment = element as _Comment;
      tempCount += comment.replies.length;
    });

    setState(() {
      this.title = post['post']['bamboo_title'];
      this.content = post['post']['bamboo_content'];  //본문
      this.liked = post['post']['liked'];   //공감 여부
      this.likes = post['post']['likeCount'];   //좋아요 개수
      this.iAmAuthor = post['post']['IAmAuthor'];
      this.commentCount = tempCount;  //댓글 개수 (대댓글 포함)
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
                        icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
                        iconSize: 22,
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                      Text("$title",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              fontFamily: "NanumSquareR"
                          )),
                    ],
                  ),
                  Column(
                      children: [
                        IconButton(onPressed: () async {
                          if (!LoginView.isLoggined) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => LoginView()));
                            return;
                          }

                          if (this.iAmAuthor || LoginView.isAdmin) {
                            showDialog<void>(
                                context: context,
                                barrierDismissible: false, // user must tap button!
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(content: Text("글을 정말 제거할까요?"),
                                    actions: [
                                      TextButton(onPressed: () async {
                                        Navigator.of(dialogContext).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("게시물을 지우고 있습니다 ..."))
                                        );
                                        Map response =
                                        await ApiHelper.deleteBambooPost(LoginView.seq, this.widget.id);

                                        if (response['success'] == true) {
                                          Navigator.pop(context);
                                        }
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(response['message']))
                                        );
                                      }, child: Text("네")),

                                      TextButton(onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                      }, child: Text("아니요")),
                                    ],
                                  );
                                }
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("권한이 없습니다."))
                            );
                          }
                        }, icon: Icon(CupertinoIcons.trash, color: Colors.grey)),
                        Text(this.date,
                            style: TextStyle(color: Colors.grey.shade600)),
                      ]),
                ]
            ),
          ),
          Divider(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async { await load(); },
              child: ListView(
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(30, 10, 30, 20),
                    child: Row(
                      children: [
                        Expanded(
                            child: SelectableText(content,
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
                            likeCount: likes,
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
                            onTap: (isLiked) async {
                              if (!LoginView.isLoggined) {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => LoginView()));
                                return null;
                              }

                              Map? response;

                              if (!isLiked) {
                                response = await ApiHelper.likeBambooPost(LoginView.seq, widget.id);
                              } else {
                                response = await ApiHelper.unlikeBambooPost(LoginView.seq, widget.id);
                              }
                              if (response == null) {
                                Fluttertoast.showToast(msg: "인터넷 상태를 확인해주세요.");
                                return null;
                              }

                              String? msg = response['message'];
                              if (msg != null) {  // 등록 실패
                                Fluttertoast.showToast(msg: msg);
                                return null;
                              }

                              this.setState(() {
                                if (response == null) return;   // null일 수 없습니다.
                                this.liked = !isLiked;
                                this.likes = response['count'];
                              });
                              return true;
                            },
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
                                              if (!LoginView.isLoggined) {
                                                Navigator.push(context,
                                                    MaterialPageRoute(builder: (context) => LoginView()));
                                                return;
                                              }

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
    try {
      this.sendingComment = true; // 댓글 중복 등록 방지

      String content = this.commentController.text;
      Map? response = await ApiHelper.writeBambooComment(
          LoginView.seq, widget.id, content);

      if (response == null) {
        Fluttertoast.showToast(msg: "인터넷 상태를 확인해주세요.");
        sendingComment = false;
        return;
      }

      bool success = response['success'];
      String msg = response['message'];

      if (success) { // 등록 성공
        Fluttertoast.showToast(msg: msg);
      } else { // 등록 실패
        Fluttertoast.showToast(msg: msg);
      }
      this.commentController.text = ""; // 댓글 초기화
      this.sendingComment = false; // 댓글 등록 상태 x

      //TODO: 댓글 새로고침 개선
      load(); // 본문을 새로고칩니다 ......
    } catch(e) {
      print(e);
      Fluttertoast.showToast(msg: "처리하지 못했습니다.");
      sendingComment = false;
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class _Comment extends StatefulWidget {
  final int id;
  final int parentId;
  final int postId;
  final String name;
  final bool inReplyScreen;
  final bool isReply;
  final bool iAmAuthor;
  bool removed = false;
  String content;
  int likes;
  bool liked;
  List<Widget> replies;

  _Comment({this.name: "", this.content: "", this.likes: 0, this.isReply: false,
    this.liked: false, this.id: -1, this.postId: -1, this.parentId: -1, this.inReplyScreen: false,
    this.iAmAuthor: false, this.replies: const [], Key? key}) : super(key: key)
  {
    if(this.content.isEmpty) {
      this.content = "삭제된 댓글입니다";
      this.removed = true;
    }
  }

  @override
  _CommentState createState() {
    return _CommentState();
  }
}

class _CommentState extends State<_Comment> {

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(widget.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: "NanumSquareL",
                                fontSize: 15,
                              )),
                        ),
                        IconButton(onPressed: () async {
                          if (!widget.iAmAuthor && !LoginView.isAdmin) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("삭제 중 ..."))
                          );
                          Map response =
                          await ApiHelper.deleteBambooComment(LoginView.seq, this.widget.id);

                          if (response['success'] == true) {
                            setState(() {
                              widget.content = "삭제된 댓글입니다.";
                              widget.removed = true;
                            });
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response['message']))
                          );
                        }, icon: Icon(CupertinoIcons.trash,
                          color: Colors.grey,
                          size: (widget.iAmAuthor || LoginView.isAdmin) ? 20 : 0,)),
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
                              child: SelectableText(widget.content,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontStyle: widget.removed ? FontStyle.italic : FontStyle.normal
                                  )),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 5, 20, 3),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  MaterialButton(onPressed: () async {
                                    if (widget.inReplyScreen) return;
                                    await Navigator.push(context, MaterialPageRoute(builder: (context) {
                                      return CommentReplyScreen(tempComment: this.widget, postId: widget.parentId,);
                                    }));

                                    this.setState(() {
                                      //  답글 개수 갱신
                                    });
                                  },
                                      child: Text(
                                          widget.inReplyScreen
                                              ? ''
                                              : "답글 ${widget.replies.length}개")
                                  ),
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
                                    onTap: (bool? isLiked) async{
                                      if (!LoginView.isLoggined) {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => LoginView()));
                                        return null;
                                      }

                                      Map? response;
                                      if (isLiked == null) return null;

                                      if (!isLiked) {
                                        response = await ApiHelper.likeBambooComment(LoginView.seq, widget.id);
                                      } else {
                                        response = await ApiHelper.unlikeBambooComment(LoginView.seq, widget.id);
                                      }
                                      if (response == null) {
                                        Fluttertoast.showToast(msg: "인터넷 상태를 확인해주세요.");
                                        return null;
                                      }

                                      String? msg = response['message'];
                                      if (msg != null) {  // 등록 실패
                                        Fluttertoast.showToast(msg: msg);
                                        return null;
                                      }

                                      this.setState(() {
                                        if (response == null) return;   // null일 수 없습니다.
                                        widget.liked = !isLiked;
                                        widget.likes = response['count'];
                                      });
                                      return true;
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
          ...(widget.inReplyScreen? widget.replies : [])
        ]
    );
  }
}

class CommentReplyScreen extends StatefulWidget {
  final _Comment tempComment;
  final int postId;
  const CommentReplyScreen({required this.tempComment, required this.postId,
    Key? key}) : super(key: key);

  @override
  _CommentReplyScreenState createState() => _CommentReplyScreenState();
}

class _CommentReplyScreenState extends State<CommentReplyScreen> {
  late _Comment comment;
  bool sendingComment = false;
  TextEditingController commentController = new TextEditingController();
  ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    loadComment();
    Future.delayed(Duration(seconds: 0), (){
      loadReplies();
    });
  }

  void loadComment() {
    _Comment temp = widget.tempComment;
    this.comment = _Comment(content: temp.content,
      id: temp.id, inReplyScreen: true, isReply: false, liked: temp.liked,
      likes: temp.likes, name: temp.name, parentId: temp.parentId, postId: temp.postId,
      replies: temp.replies, iAmAuthor: temp.iAmAuthor,);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          SizedBox(height: 10,),
          Row(
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: IconButton(icon: Icon(CupertinoIcons.back), onPressed: () {
                      Navigator.pop(context);
                    },)
                ),
                Text("돌아가기"),
              ]),
          Expanded(
            child: SingleChildScrollView(
                controller: this.scrollController,
                child: this.comment
            ),
          ),
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
                        maxLength: 1000,
                        decoration: InputDecoration(
                            fillColor: Colors.blueGrey,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            hintText: "답글을 달아주세요 :D",
                            hintStyle: TextStyle(fontFamily: "NanumSquareL")
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: CupertinoButton(
                            child: Icon(CupertinoIcons.paperplane),
                            onPressed: () {
                              if (!LoginView.isLoggined) {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => LoginView()));
                                return;
                              }

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
        ]);
  }

  Future<void> loadReplies({bool scrollToBottom: false}) async {
    Map? response = await ApiHelper.getBambooReplies(LoginView.seq, comment.id);
    if (response == null) {
      Fluttertoast.showToast(msg: "답글을 새로고치지 못했습니다.");
      return;
    }

    bool success = response['success'];
    if (!success) {
      Fluttertoast.showToast(msg: response['message']);
      return;
    }

    List<Widget> tempList = [];
    List replies = response['replies'];

    replies.forEach((element2) {
      _Comment reply = new _Comment(
        name: element2['comment_author_displayname'],
        content: element2['comment_content'],
        likes: element2['likes'],
        liked: element2['liked'],
        isReply: true,
        inReplyScreen: true,
        iAmAuthor: element2['IAmAuthor'],
        id: element2['comment_id'],
        parentId: comment.id,
        postId: comment.postId,
      );

      tempList.add(reply);
    });

    setState(() {
      widget.tempComment.replies = tempList;
      loadComment();
    });

    if (scrollToBottom) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 100,
        duration: Duration(milliseconds: 500),
        curve: Curves.fastLinearToSlowEaseIn,
      );
    }
  }

  Future<void> sendComment() async {
    try {
      this.sendingComment = true; // 댓글 중복 등록 방지

      String content = this.commentController.text;
      Map? response = await ApiHelper.replyBambooComment(LoginView.seq,
          comment.postId, comment.id, content);

      if (response == null) {
        Fluttertoast.showToast(msg: "인터넷 상태를 확인해주세요.");
        sendingComment = false;
        return;
      }

      bool success = response['success'];
      String msg = response['message'];

      if (success) { // 등록 성공
        Fluttertoast.showToast(msg: msg);
      } else { // 등록 실패
        Fluttertoast.showToast(msg: msg);
      }
      this.commentController.text = ""; // 댓글 초기화
      this.sendingComment = false; // 댓글 등록 상태 x

      loadReplies(scrollToBottom: true);
    } catch(e) {
      print(e);
      Fluttertoast.showToast(msg: "처리하지 못했습니다.");
      sendingComment = false;
    }
  }
}
