import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:realproject/control/content.dart';
import 'package:realproject/model/content.dart';
import 'package:realproject/model/maincontenttilecolor.dart';
import 'package:realproject/model/myword.dart';

import 'package:realproject/model/shared.dart';
import 'package:realproject/page/mobileDash/mobildMainBody.dart';
import 'package:realproject/page/user/mobilelogin.dart';
import 'package:realproject/page/user/profile.dart';
import 'mobileDash/content/mobileWriteContentPage.dart';
import 'mobileDash/mobileMainHead.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:realproject/control/content.dart';
import 'package:realproject/main.dart';
import 'package:realproject/model/content.dart';
import 'package:realproject/model/maincontenttilecolor.dart';

import 'package:realproject/model/shared.dart';
import 'package:realproject/page/dialog/dialog.dart';
import 'package:realproject/page/maindash.dart';
import 'package:realproject/page/mobileDash/content/mobilecommentpage.dart';
import 'package:realproject/page/mobileDash/mobildmainbody.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MainDash extends StatefulWidget {
  const MainDash({Key key}) : super(key: key);

  @override
  MainDashState createState() => MainDashState();
}

class MainDashState extends State<MainDash> {
  MyShared myShared = MyShared();
  Map getTextFiledMap = {MyWord.GET_TEXT_FILED_MAP: MyWord.EMPTY};
  bool firstCheck = true;
  bool reloadCheck = true;
  DateTime currentBackPressTime;
  String userId = 'LogIn';
  List<Widget> widgetList = [];
  List<TextEditingController> textEditingController = [];
  List<bool> favoriteOnHover = [];
  List<bool> badOnHover = [];
  List<int> valueList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  String exString1 = '';
  Map returnMap = Map();
  Map mapEx1 = Map();
  String utf8StringContent = '';


  void reload() async {
    setState(() {
      reloadCheck = false;
    });
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      reloadCheck = true;
    });
  }

  void mobileWriteContent(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MobileWriteContentMain(
              userId: myShared.userId,
            )));
    reload();
  }

  @override
  void dispose() {
    myShared.setUserId(MyWord.LOGIN);
    print('main dispose pass');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    myShared.getUserId();
  }

  @override
  Widget build(BuildContext context) {
    String userId = myShared.userId.toString();
    print('main Dash call userid : $userId');
    return WillPopScope(onWillPop: onWillPop, child: isMobileScaffold(context, userId));
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: '?????? ???????????? ????????? ??????????????????');
      return Future.value(false);
    }
    return Future.value(true);
  }
  onRefresh2 () => reload();
  Widget isMobileScaffold(BuildContext context, String userId) {
    bool checkLogin = false;
    print('???? : $userId');
    if (userId == MyWord.LOGIN) {
      checkLogin = true;
    }
    print('?? : $checkLogin');
    return Scaffold(
        appBar: AppBar(title: Text(MyWord.TEST_SITE), backgroundColor: Colors.black, actions: [
          if (userId == MyWord.LOGIN)
            IconButton(
                icon: Icon(Icons.login),
                onPressed: () {
                  callNavigator(0, userId);
                  //Navigator.of(context).push(MaterialPageRoute(builder: (context) => MobileLogin(userId: userId)));
                }),
          if (userId != MyWord.LOGIN)
            TextButton(
                onPressed: () {
                  callNavigator(1, userId);
                  //Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProFile(userId: userId)));
                },
                child: Text(userId))
        ]),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: RefreshIndicator(
            color: Colors.white12,
            backgroundColor: Colors.white12,
            onRefresh: () => onRefresh2(),
            child: SingleChildScrollView(
                child: Container(
                    child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children: [
              MobileMainHead(),
              Divider(height: 5, color: Colors.white12, indent: 0),
              reloadCheck
                  ?
              //MobileMainBody(userId: userId)
              Center(
                  child: Container(
                      child: reloadCheck
                          ? FutureBuilder(
                          future: MainContentControl.getContent2(),
                          builder: (context, snap) {
                            List<MainContentDataModel> data = snap.data as List<MainContentDataModel>;
                            if (!snap.hasData) {
                              return const Center(child: Padding(padding: EdgeInsets.all(18.0), child: CircularProgressIndicator()));
                            } else {
                              return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  MainContentDataModel item = data[index];
                                  return _mainBuild(item, index, context, userId);
                                },
                                itemCount: data.length,
                                shrinkWrap: true,
                              );
                            }
                          })
                          : LinearProgressIndicator()))
                  //Container()
                  :
              Padding(padding: const EdgeInsets.only(top: 200), child: Center(child: CircularProgressIndicator()))
            ]))),
          ),
        ),
        floatingActionButton: checkLogin
            ? null
            : FloatingActionButton(
                onPressed: () {
                  mobileWriteContent(context);
                },
                child: Icon(Icons.add)));
  }

  void callNavigator(int flag, String userId) async {
    if (flag == 0) {
      await Navigator.of(context).push(MaterialPageRoute(builder: (context) => MobileLogin(userId: userId)));
    } else if (flag == 1) {
      await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProFile(userId: userId)));
    }else{

    }
    myShared.getUserId();
    userId = myShared.userId;
    reload();
    setState(() {});
  }


  Widget _mainBuild(MainContentDataModel item, int index, BuildContext context, String userId) {
    List<dynamic> utf8List = jsonDecode(item.content);
    List<int> intList = [];
    utf8List.forEach((element) {
      intList.add(element);
    });
    utf8StringContent = utf8.decode(intList).toString();
    textEditingController.add(TextEditingController());
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: ExpansionTile(
          collapsedBackgroundColor: MainContentWidgetModel.backgroundColor,
          backgroundColor: Colors.black12,
          trailing: Icon(Icons.comment, size: 15, color: MainContentWidgetModel.iconColor),
          title: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                    child: Text('$utf8StringContent',
                        maxLines: 5, overflow: TextOverflow.clip, style: TextStyle(color: MainContentWidgetModel.textColor, fontSize: 15)))
              ])),
          subtitle: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Icon(Icons.favorite, size: 15, color: MainContentWidgetModel.iconColor),
                  Text('  ( ${item.likeCount} )', style: TextStyle(color: MainContentWidgetModel.textColor, fontSize: 12)),
                  Padding(padding: const EdgeInsets.only(left: 5), child: Icon(Icons.mood_bad, size: 15, color: MainContentWidgetModel.iconColor)),
                  Text('  ( ${item.badCount} )', style: TextStyle(color: MainContentWidgetModel.textColor, fontSize: 12)),
                  Padding(padding: const EdgeInsets.only(left: 5), child: Icon(Icons.comment, size: 15, color: MainContentWidgetModel.iconColor)),
                  Text('  ( ${item.children.length} )', style: TextStyle(color: MainContentWidgetModel.textColor, fontSize: 12)),
                  Padding(padding: const EdgeInsets.only(left: 5), child: likeAndBadIcon(0, item, index,context)),
                  Padding(padding: const EdgeInsets.only(left: 5), child: likeAndBadIcon(1, item, index,context))
                ]),
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Divider(),
                      Padding(padding: const EdgeInsets.only(left: 15), child: Text(item.userId, style: TextStyle(color: Colors.white))),
                      Padding(padding: const EdgeInsets.only(left: 15), child: MainContentWidgetModel.myText(item.createTime))
                    ]))
              ])),
          onExpansionChanged: (v) {
            if (v) {
              int id = item.contentId;
              String sId = id.toString();
              Map sortToMap = {sId: 1};
              for (int i = 0; i < sortToMap.length; i++) {
                exString1 = sortToMap.keys.elementAt(i);
                valueList[index] = sortToMap.values.elementAt(i) + valueList[index];
                mapEx1 = {exString1: valueList[index]};
                returnMap.addAll(mapEx1);
              }
              setState(() {});
            }
          },
          children: tenComment(item, index, context, userId)),
    );
  }

  Widget likeAndBadIcon(int flag, MainContentDataModel item, int index, BuildContext context) {
    favoriteOnHover.add(false);
    badOnHover.add(false);
    int contentId = item.contentId;
    return InkWell(
        onTap: () {
          MainContentControl.setLikeAndBad(contentId: contentId, flag: flag);
          //////////////////////////////////////////////
          setState(() {

          });
          /////////////////////////////////////////////
        },
        onHover: (v) {
          if (flag == 0 && v) {
            setState(() {
              favoriteOnHover[index] = true;
            });
          } else if (flag == 1 && v) {
            print('1 pass $v');
            setState(() {
              badOnHover[index] = true;
            });
          } else {
            setState(() {
              favoriteOnHover[index] = false;
              badOnHover[index] = false;
            });
          }
        },
        child: Container(
          width: 40,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            if (flag == 0) Icon(Icons.favorite, size: 20, color: favoriteOnHover[index] ? Colors.red : MainContentWidgetModel.iconColor),
            if (flag == 1) Icon(Icons.mood_bad, size: 20, color: badOnHover[index] ? Colors.blue : MainContentWidgetModel.iconColor),
          ]),
        ));
  }

  List<Widget> tenComment(MainContentDataModel item, int index, BuildContext context, String userId) {
    int itemChildrenLength = item.children.length;
    widgetList = [inputComment(item, index, context, userId)];
    for (int i = 0; i < 10; i++) {
      if (i < itemChildrenLength) {
        try {
          MainCommentDataModel mainCommentDataModel = MainCommentDataModel.fromJson(item.children[i]);
          widgetList.add(commentList(mainCommentDataModel, item, i, userId));
        } catch (e) {}
      }
    }
    if (10 < itemChildrenLength) {
      widgetList.add(lastClickPage(index, item, context));
    }
    widgetList.add(Divider(color: Colors.white, height: 50));
    return widgetList;
  }

  Widget lastClickPage(int index, MainContentDataModel item, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            width: 300,
            height: 30,
            child: ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blueGrey)),
                child: Text('?????? ????????????'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MobileCommentPage(content: item)));
                })));
  }

  Widget inputComment(MainContentDataModel item, int index, BuildContext context, String userId) {
    //print('input comment pass');
    return Container(
        width: 400,
        child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
                controller: textEditingController[index],
                autofocus: true,
                onSubmitted: (v) {
                  if (v != '' && v.isNotEmpty) {
                    if (userId != MyWord.LOGIN) {
                      MainContentControl.setComment(index: index, item: item, value: v, userId: userId, context: context);
                      //MainDash.of(context).setBool = false;
setState(() {

});
                      textEditingController[index].clear();
                    } else {
                      textEditingController[index].clear();
                      MyDialog.setContentDialog(title: '????????????', message: '????????? ???????????????', context: context);
                    }
                  }
                },
                style: TextStyle(fontSize: 15, color: Colors.white),
                decoration: const InputDecoration(
                    labelText: '??? ???',
                    hintText: '?????? ??? ??????',
                    hintStyle: TextStyle(fontSize: 10, color: Colors.white),
                    labelStyle: TextStyle(fontSize: 10, color: Colors.white),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(1.0)), borderSide: BorderSide(width: 1, color: Colors.white)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(1.0)), borderSide: BorderSide(width: 1, color: Colors.white)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(1.0)))))));
  }

  Widget commentList(MainCommentDataModel comment, MainContentDataModel item, int order, String userId) {
    List<dynamic> utf8List = jsonDecode(comment.comment);
    List<int> intList = [];
    utf8List.forEach((element) {
      intList.add(element);
    });
    String decodeComment = utf8.decode(intList).toString();
    bool myIdCheck = false;
    if (comment.userId == userId) {
      myIdCheck = true;
    }
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: ListTile(
            hoverColor: Colors.black12,
            selectedTileColor: MainContentWidgetModel.tileColor,
            tileColor: MainContentWidgetModel.tileColor,
            title: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(
                    child: Text(decodeComment,
                        style: TextStyle(color: MainContentWidgetModel.textColor, fontSize: 15),
                        maxLines: 5, overflow: TextOverflow.clip),
                  ),
                  myIdCheck
                      ? IconButton(
                      icon: Icon(Icons.delete_forever, color: MainContentWidgetModel.iconColor, size: 15),
                      onPressed: () {
                        MainContentControl.deleteComment(contentId: item.contentId, userId: userId, order: order);
                        //MainDash.of(context).setBool = false;
setState(() {

});
                      })
                      : Container(child: Text(comment.userId, style: TextStyle(color: Colors.white, fontSize: 15)))
                ]))));
  }
}

