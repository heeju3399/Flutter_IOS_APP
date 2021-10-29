import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realproject/page/mainDash.dart';

import 'model/myword.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    //SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
       statusBarColor: Colors.white, // 투명색
     ));
    //SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return const MaterialApp(
      title: MyWord.TEST_SITE,
      home: MainDash(),
    );
  }
}
