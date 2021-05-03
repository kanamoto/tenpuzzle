import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:tenpuzzle/model/GameModel.dart';
import 'package:tenpuzzle/model/ModelData.dart';
import 'package:tenpuzzle/model/PanelAnimationModel.dart';
import 'package:tenpuzzle/model/ResourceConst.dart';
import "dart:math" show pi;

import 'package:tenpuzzle/pages/GamePage.dart';
import 'package:tenpuzzle/peripheral/pageNavigate.dart';
import 'package:tenpuzzle/widget/GameCard.dart';

import 'package:tenpuzzle/pages/ManualPage.dart';
import 'package:tenpuzzle/pages/RecordListPage.dart';

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

class _HomeState extends State<Home>  with TickerProviderStateMixin  ,  WidgetsBindingObserver {

  PanelAnimationModel _animationModelPartA;
  PanelAnimationModel _animationModelPartB;
  Animation<Color> _color;

  static const int _ANIMATION_A_PART = 0;
  static const int _ANIMATION_B_PART = 1;
  static const int _ANIMATION_C_PART = 2;
  static const int _ANIMATION_END = 3;

  int _animationPart = _ANIMATION_A_PART;

  double _screenWidth;
  double _screenHeight;

  GameModel _gameModel;

  _HomeState(this._gameModel);

  AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

  @override
  void initState(){
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

    playOpeningSound();
  }

  void playOpeningSound() async {
    _assetsAudioPlayer.open(
      Audio("assets/sound/madness1.mp3"),
        autoStart: true,
        showNotification: false,
        respectSilentMode: true
    );
  }

  void initAnimation() {
    print("initAnimation start _animationPart:$_animationPart");

    _animationModelPartA = PanelAnimationModel(this , durationSeconds:5 , onAnimate:(){
      setState(() {});
    }, onCompleted: () {
      if (_animationPart == _ANIMATION_END ){
        print("_animationPart:$_animationPart");
        _animationModelPartB.stop();
        setState(() {});
        return;
      }
      _animationPart = _ANIMATION_B_PART;
      print("_animationModelPartA::onCompleted _animationPart:$_animationPart");
      _animationModelPartB.forward();
      setState(() {});
    });

    _animationModelPartB = PanelAnimationModel(this , durationSeconds:3 , onAnimate:(){
      setState(() {});
    }, onCompleted: () {
      print("_animationModelPartB::onCompleted _animationPart:$_animationPart");
      if ( _animationPart == _ANIMATION_B_PART){
        _animationPart = _ANIMATION_C_PART;
        _animationModelPartB.reverse();
      }else{
        _animationPart = _ANIMATION_END;
        _animationModelPartB.stop();
        print("_animationPart:$_animationPart");
      }

      setState(() {});
    });

    _color = ColorTween(
      begin: Colors.transparent,
      end: Colors.black,
    ).animate(_animationModelPartB.controller);

    // アニメーション開始
    _animationModelPartA.forward();

    // _animationController =
    // AnimationController( duration: const Duration(seconds: 5), vsync: this)..addListener(() {
    //   setState(() {});
    // })..addStatusListener((status) {
    //   // print('$status');
    // });
    // _animation = Tween(begin: 0.0, end: 100.0).animate(_animationController);
    // _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
  }


  @override
  void dispose() {
    print("${this.runtimeType}  dispose");
    _animationModelPartA.dispose();
    _animationModelPartB.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('${this.runtimeType} didChangeAppLifecycleState state = $state');
    if ( state == AppLifecycleState.paused ){
      _animationModelPartA.fling();
//      _animationModelPartB.fling();// 最大値にセットする(結果としてメニュータイトル表示から続ける)
      _animationModelPartB.fling(velocity:-1); // 初期値に戻す(三角表記のみとなる)
      _assetsAudioPlayer.stop().then((_){
        print("assetsAudioPlayer Stop");
      });
    }
  }

  Future<void>  decrescendo(double second)
  {
    double volumeValue = _assetsAudioPlayer.volume.valueWrapper.value;
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
        color: Colors.black.withOpacity( _animationModelPartA.animationValue / 100.0),
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
              if (_animationPart != _ANIMATION_END) {
                // タップ一度目はタイトルを出す。二度目はゲームに遷移する
                _animationPart = _ANIMATION_END;
                _animationModelPartA.fling();
                _animationModelPartB.fling();
                return;
              }
            },
            child:
              Stack(children: <Widget>[
                SizedBox.expand( // https://stackoverflow.com/questions/50518373/flutter-getting-touch-input-on-custompainters
                  child: CustomPaint(painter: _TitlePainter(_screenWidth , _screenHeight , titleSize,  _animationModelPartA.animationValue),),
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
                                  _goNewGame(context);
                                },
                              ),
                              Visibility(
                                  visible: _gameModel.initialized && _gameModel.hadSavePlayData,
                                  child:Spacer(),
                              ),
                              Visibility(
                                visible: _gameModel.initialized && _gameModel.hadSavePlayData,
                                child:
                                ElevatedButton(
                                  child: const Text('Continue'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).accentColor, // Colors.teal,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.grey,
                                  ),
                                  onPressed: () {
                                    _goContinueGame(context);
                                  },
                                ),
                              ),
                              Spacer(),
                          ]),
                     ]),
                ),
                _titleCard(_screenWidth , _screenHeight, _animationModelPartA.animationValue),
                Visibility(
                    visible: _animationPart > _ANIMATION_A_PART,
                    child:_buildGoAcknowledgmentsPageButton(context)
                ),
                Visibility(
                  visible: _animationPart > _ANIMATION_A_PART,
                  child:_buildGoRecordListPageButton(context)
                  ),


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
        panelData.showStr = character;
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

  void _goContinueGame(BuildContext context) {
    decrescendo(2.0);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return GamePage(_gameModel, title: 'TenPuzzle' , loadGame:_gameModel.hadSavePlayData);
      },
    ));
  }

  void _goNewGame(BuildContext context) {

    _gameModel.clearData();

    decrescendo(2.0);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return GamePage(_gameModel, title: 'TenPuzzle' , loadGame:false);
      },
    ));
  }

  void _showRecord()
  {
    Navigator.of(context).push(PageNavigate.createRoute(PageNavigate.RIGHT_TO_LEFT, RecordListPage(_gameModel)));
  }

  void _showAcknowledgments()
  {
    Navigator.of(context).push(PageNavigate.createRoute(PageNavigate.LEFT_TO_RIGHT, ManualPage(ResourceConst.MANUAL_HTML)));
  }

  Widget _buildGoAcknowledgmentsPageButton(BuildContext context) {
//    print("_animationPart:$_animationPart value:${(2.55 * _animationModelPartB.animationValue).toInt()} color:${_color.value}");
    return
      Column(mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(30, 20, 0, 20),
                    child:
                    TextButton(
                      child: Row(children: [
                        Text('◀' , style:TextStyle(color: (_animationPart >= _ANIMATION_C_PART ? Colors.black : _color.value))),
                        Text('Manual' , style:TextStyle(color: _color.value))],), // 	Black Left-Pointing Triangle U+25C0
                      onPressed: () {
                        _showAcknowledgments();
                      },
                    ),
                  ),
                  Spacer()
                ])
          ]);
  }

  Widget _buildGoRecordListPageButton(BuildContext context) {
    return
        Column(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 30, 20),
                    child:
                    TextButton(
                      style:ButtonStyle(),
                      child: Row(children: [
                        Text('Record' , style:TextStyle(color: _color.value)),
                        Text('▶' , textAlign:TextAlign.right ,style:TextStyle(color: (_animationPart >= _ANIMATION_C_PART ? Colors.black : _color.value)))]), // 	Black Right-Pointing Triangle U+25B6
                      onPressed: () {
                          _showRecord();
                      },
                    ),
                ),
              ])
        ]);
  }

  // Widget _buildSidePageButton(BuildContext context, bool rightSide , String arrowStr , String labelStr , void onPressedFunc()) {
  //   Row buttonRow = Row(children: [
  //     Text('◀' , style:TextStyle(color: (_animationPart <= 1 ? _color.value : Colors.black))),
  //     Visibility(child: Text('Manual' , style:TextStyle(color: _color.value)), visible:_animationCompleted == false)],); // 	Black Left-Pointing Triangle U+25C0
  //
  //   print("_animationCompleted:$_animationCompleted value:${(2.55 * _animationModelPartB.animationValue).toInt()} color:${_color.value}");
  //   return
  //     Column(mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           Row(mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: <Widget>[
  //                 Padding(
  //                   padding: EdgeInsets.fromLTRB(20, 20, 0, 20),
  //                   child:
  //                   TextButton(
  //                     child: Row(children: [
  //                       Text('◀' , style:TextStyle(color: (_animationPart <= 1 ? _color.value : Colors.black))),
  //                       Visibility(child: Text('Manual' , style:TextStyle(color: _color.value)), visible:_animationCompleted == false)],), // 	Black Left-Pointing Triangle U+25C0
  //                     onPressed: () {
  //                       _showAcknowledgments();
  //                     },
  //                   ),
  //                 ),
  //                 Spacer()
  //               ])
  //         ]);
  // }



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
