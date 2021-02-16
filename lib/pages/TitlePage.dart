import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:tenpuzzle/model/GameModel.dart';
import 'package:tenpuzzle/model/ModelData.dart';
import "dart:math" show pi;

import 'package:tenpuzzle/pages/GamePage.dart';
import 'package:tenpuzzle/widget/GameCard.dart';

class TitlePage extends StatelessWidget {

  final GameModel _gameModel;

  TitlePage(this._gameModel);

  @override
  Widget build(BuildContext context) {
    return Home(this._gameModel);
  }
}

class Home extends StatefulWidget {

  final GameModel _gameModel;

  Home(this._gameModel);

  @override
  State<StatefulWidget> createState() {
    return _HomeState(this._gameModel);
  }
}

class _HomeState extends State<Home>  with SingleTickerProviderStateMixin  ,  WidgetsBindingObserver {

  Animation<double> _animation;
  AnimationController _animationController;

  double _screenWidth;
  double _screenHeight;

  GameModel _gameModel;

  _HomeState(this._gameModel);

  AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

  @override
  void initState() {
    print("TitlePage initState");

    super.initState();
    WidgetsBinding.instance.addObserver(this);

    /* モデルの初期化処理をここで行う。
       ロード可能なデータの有無確認を省力化するため、タイトル画面で実施する。
       (モデル側で自律的にロードして、通知する形が取るのが正しい)
       初期化済みの場合は状態をとっておいて、初期化処理を行わない */
    if ( _gameModel.initialized == false ){
      print("MyApp constructor start");
      _gameModel.initialize((GameModel gameModel){
        if (mounted){
          setState(() {});
        }
      });
      print("MyApp constructor end");
    }

    initAnimation();

    _assetsAudioPlayer.open(
      Audio("assets/sound/madness1.mp3"),
      autoStart: true,
      showNotification: false,
    );

  }

  void initAnimation() {
    _animationController =
    AnimationController( duration: const Duration(seconds: 5), vsync: this)..addListener(() {
      setState(() {});
    })..addStatusListener((status) {
      // print('$status');
    });
    _animation = Tween(begin: 0.0, end: 100.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
  }


  @override
  void dispose() {
    print("TitlePage dispose");
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('didChangeAppLifecycleState state = $state');
    if ( state == AppLifecycleState.paused ){
      _animationController.fling();
      _assetsAudioPlayer.stop();
    }
  }

  Future<void>  decrescendo(double second)
  {
    double volumeValue = _assetsAudioPlayer.volume.value;
    print("decrescendo. Turn the volume from $volumeValue to 0 in $second seconds.");
    var completer = new Completer<void>(); // Completer<T>を作成する。

    // 何かしら非同期な処理が完了したときに
    // Completer<T>のcomplete(T value)メソッドを呼び出して処理を完了させる。
   Timer.periodic(new Duration(milliseconds: 100), (timer) {
      volumeValue -= 0.1;
      if ( volumeValue > 0 ){
        _assetsAudioPlayer.setVolume(volumeValue);
      }else{
        _assetsAudioPlayer.stop();
        timer.cancel();
        completer.complete();
      }
    });

    return completer.future; // Completerの持つFutureオブジェクトを返す。
  }

  Widget build(BuildContext context) {

    final TextStyle titleTextStyle = TextStyle(
        color: Colors.black.withOpacity(_animation.value / 100.0),
        fontSize: 32,
        fontWeight: FontWeight.bold);

    final String titleText = "TenPuzzle";

    // https://stackoverflow.com/questions/52659759/how-can-i-get-the-size-of-the-text-widget-in-flutter
    final Size titleSize = (TextPainter(
        text: TextSpan(text: titleText, style: titleTextStyle),
        maxLines: 1,
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        textDirection: TextDirection.ltr)
      ..layout())
        .size;

    return new Scaffold(
      body:
        Listener(
            // behavior: HitTestBehavior.opaque, // 子Widget以外もタッチイベント対象にする
            onPointerUp: (PointerEvent details) {
              print("onPointerUp");
              if ( _gameModel.initialized == false ){
                print('running initialize.');
                // まだ初期化されていない。
                return;
              }
              if ( _animationController.status != AnimationStatus.completed) {
                // タップ一度目はタイトルを出す。二度目はゲームに遷移する
                _animationController.fling();
                return;
              }
            },
            child:
              Stack(children: <Widget>[
                SizedBox.expand( // https://stackoverflow.com/questions/50518373/flutter-getting-touch-input-on-custompainters
                  child: CustomPaint(painter: _TitlePainter(_screenWidth , _screenHeight , titleSize,  _animation.value),),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                  child:
                     Column(
                       children: <Widget>[
                          Spacer(),
                          Row(
                            children: <Widget> [
                              Spacer(),
                              ElevatedButton(
                                child: const Text('New Game'),
                                style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).accentColor, // Colors.teal,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.grey,
                                ),
                                onPressed: () {
                                  decrescendo(2.0);
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                                    builder: (context) {
                                      return GamePage(_gameModel, title: 'TenPuzzle' , loadGame:false);
                                    },
                                  ));
                                },
                              ),
                              Visibility(
                                  visible: _gameModel.initialized && _gameModel.hadPlayData,
                                  child:Spacer(),
                              ),
                              Visibility(
                                visible: _gameModel.initialized && _gameModel.hadPlayData,
                                child:
                                ElevatedButton(
                                  child: const Text('Continue'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).accentColor, // Colors.teal,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.grey,
                                  ),
                                  onPressed: () {
                                    decrescendo(2.0);
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                                      builder: (context) {
                                        return GamePage(_gameModel, title: 'TenPuzzle' , loadGame:_gameModel.hadPlayData);
                                      },
                                    ));
                                  },
                                ),
                              ),
                              Spacer(),
                          ]),
                     ]),
                ),
                _titleCard(_screenWidth , _screenHeight, _animation.value),
              ],)
          )
    );
  }

  Widget _titleCard(  double _screenWidth, double _screenHeight, double animationValue)
  {

    double panelWidth = 72;
    double panelHeight = 72;

    Offset screenCenter = Offset(_screenWidth / 2 , _screenHeight /2 );

    String titleString = "ten\npuzzle";

    List<PanelData> panelList = [];

    int titleLineIndex = 0;
    int runesLineLength = titleString.split("\n").length;
    titleString.split("\n").asMap().forEach((key, value) {
      int runeIndex = 0;
      int runesLength = value.runes.length;
      double offsetX = screenCenter.dx - (runesLength * panelWidth) ~/ 2;
      double offsetY = screenCenter.dy - (runesLineLength * panelHeight) ~/ 2;

      value.runes.forEach((rune) {
        var character = new String.fromCharCode(rune);

        PanelData panelData = PanelData();
        panelData.rect = Rect.fromLTWH(runeIndex * panelWidth + offsetX , titleLineIndex * panelHeight + offsetY , panelWidth, panelHeight);
        panelData.title = character;
        panelList.add(panelData);

        runeIndex += 1;
      });

      titleLineIndex += 1;
    });

    return Stack(
      children: <Widget>
      [for (var panelData in panelList)
          GameCard(panelData:panelData , expansionRate:100.0 - animationValue) //1.0)
      ],
    );
  }

}


class _TitlePainter extends CustomPainter {
  double radius;
  double _screenWidth;
  double _screenHeight;
  Size _titleSize;

  _TitlePainter(this._screenWidth , this._screenHeight, this._titleSize , this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    //print("$size");
    var paint = Paint()
      ..isAntiAlias = true
      ..color = Colors.grey
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    Offset screenCenter = Offset(_screenWidth / 2 , _screenHeight /2 );
    var logoUnitSize = _titleSize.width;
    var rect = Rect.fromCenter(center: screenCenter , width:logoUnitSize * 2, height:logoUnitSize * 2);

//    var degToRad = (deg) => deg * pi / 180;

    canvas.drawArc (rect,0 , -pi * (radius / 100) , false , paint);
    canvas.drawArc (rect, pi - pi * (radius / 100) ,pi * (radius / 100) , false , paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
