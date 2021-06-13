import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // landscape レイアウト指定 , ステータスバー消去
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:tenpuzzle/model/GameModel.dart';

import 'package:tenpuzzle/pages/TitlePage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {

    // // 文字列evalテストコード
    // double r = calcString("1*2*3*4*5*6*7*8*9");
    // print("r:$r");
    //
    // String questionData = QuestionData.getDataAtRandom();
    // print("questionData:$questionData");

    runApp(TenPuzzleApp());
}

class TenPuzzleApp extends StatelessWidget {

  final GameModel _gameModel = GameModel();

  TenPuzzleApp()
  {
    _gameModel.initialize();
  }

  @override
  Widget build(BuildContext context) {

    // landscape layout
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // hidden status bar
    SystemChrome.setEnabledSystemUIOverlays([]);

    return FutureBuilder(
      // Replace the 3 second delay with your initialization code:
      future: Future.delayed(Duration(seconds: 3)),
      builder: (context, AsyncSnapshot snapshot) {
        // Show splash screen while waiting for app resources to load:
        if (snapshot.connectionState == ConnectionState.waiting) {
//          return MaterialApp(home: Splash(), debugShowCheckedModeBanner: false);
          return runMaterialApp(Splash());
        } else {
          // Loading is done, return the app:
          return runMaterialApp(TitlePage(_gameModel));
        }
      },
    );
  }


  MaterialApp runMaterialApp(Widget homePage) {
    return MaterialApp(
        title: 'Ten Puzzle',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal , //Colors.grey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home:homePage,
        // GamePage(title: 'Flutter Demo Home Page'),
        localizationsDelegates: [
          FlutterI18nDelegate(
            translationLoader: FileTranslationLoader(),
            missingTranslationHandler: (key, locale) {
              print("--- Missing Key: $key, languageCode: ${locale.languageCode}");
            },
          ),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [
          const Locale('en'), // <- 対応している言語を登録
          const Locale('ja'), // <- 対応している言語を登録
        ],
        builder: FlutterI18n.rootAppBuilder()
    );
  }

}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
          child: Text('- to pass your time -')
      ),
    );
  }
}
