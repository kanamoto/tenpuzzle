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
        primarySwatch: Colors.teal , //Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:
      TitlePage(_gameModel),
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

// class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations>
// {
//   const AppLocalizationsDelegate();
//
//   @override
//   bool isSupported(Locale locale) => ['en', 'ja'].contains(locale.languageCode);
//
//   @override
//   Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);
//
//   @override
//   bool shouldReload(AppLocalizationsDelegate old) => false;
// }
