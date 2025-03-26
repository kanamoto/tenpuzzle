import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // landscape レイアウト指定 , ステータスバー消去
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:tenpuzzle/model/GameModel.dart';

import 'package:tenpuzzle/pages/TitlePage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

const kDemoMode = false;

void main() async {

    // // 文字列evalテストコード
    // double r = calcString("1*2*3*4*5*6*7*8*9");
    // print("r:$r");
    //
    // String questionData = QuestionData.getDataAtRandom();
    // print("questionData:$questionData");

  // Flutterの非同期APIを実行する前に必要な初期化
  WidgetsFlutterBinding.ensureInitialized();

  unawaited(MobileAds.instance.initialize());

  // 静音モードの設定を待機
  await _configure_for_silent_mode();

  runApp(TenPuzzleApp());
}

// 修正just_audio packageで静音モードで音が出ないようにするための対策コード
Future<void> _configure_for_silent_mode() async
{
  // 静音モードに対応するためにAudioSessionをspeechモードにする
  await AudioSession.instance.then((audioSession){
    audioSession.configure(AudioSessionConfiguration.speech());
  });
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

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
              print("--- Missing Key: $key, languageCode: ${locale?.languageCode}");
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
          child: Text('- Wait... Can you reach 10? -')
      ),
    );
  }
}
