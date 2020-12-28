import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // landscape レイアウト指定 , ステータスバー消去
import 'package:tenpuzzle/model/GameModel.dart';

import 'package:tenpuzzle/pages/TitlePage.dart';

void main() {

    // // 文字列evalテストコード
    // double r = calcString("1*2*3*4*5*6*7*8*9");
    // print("r:$r");
    //
    // String questionData = QuestionData.getDataAtRandom();
    // print("questionData:$questionData");

    runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final GameModel _gameModel = GameModel();

  MyApp()
  {
    // print("MyApp constructor start");
    // _gameModel.initialize();
    // print("MyApp constructor end");
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    // landscape layout
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // hidden status bar
    SystemChrome.setEnabledSystemUIOverlays([]);
//    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    return MaterialApp(
      title: 'Ten Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:
      TitlePage(_gameModel),
      // GamePage(title: 'Flutter Demo Home Page'),
    );
  }
}
