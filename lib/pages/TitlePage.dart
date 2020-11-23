import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:tenpuzzle/model/GameModel.dart';
import "dart:math" show pi;

import 'package:tenpuzzle/pages/GamePage.dart';

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

    // AudioCache audioCache = AudioCache();
    // if (Platform.isIOS) {
    //   if (audioCache.fixedPlayer != null) {
    //     audioCache.fixedPlayer.startHeadlessService();
    //   }
    // }
//    playLocal( "assets/sound/madness1.mp3" );

  }

  void initAnimation() {
    _animationController =
    AnimationController( duration: const Duration(seconds: 5), vsync: this)..addListener(() {
      setState(() {});
    })..addStatusListener((status) {
      print('$status');
      // if (status == AnimationStatus.completed) {
      //   _animationController.reverse();
      // } else if (status == AnimationStatus.dismissed) {
      //   _animationController.forward();
      // }
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
    print("dispose");
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('didChangeAppLifecycleState state = $state');
    // if ( state == AppLifecycleState.resumed){
    //   _animationController.forward();
    // }
    if ( state == AppLifecycleState.paused ){
      _animationController.fling();
      _assetsAudioPlayer.stop();
    }
    // if ( state == AppLifecycleState.paused){
    //   _animationController.reverse();
    // }
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
    return new Scaffold(
      // appBar: AppBar(
      //   title: Text('Line animation'),
      //   leading: new Icon(Icons.insert_emoticon),
      // ),
      //backgroundColor: Colors.white,
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


              // Navigator.of(context).pushReplacement(MaterialPageRoute(
              //   builder: (context) {
              //     return GamePage(_gameModel, title: 'TenPuzzle' , loadGame:false);
              //   },
              // ));

            },
            child:
              Stack(children: <Widget>[
                SizedBox.expand( // https://stackoverflow.com/questions/50518373/flutter-getting-touch-input-on-custompainters
                  child: CustomPaint(painter: _TitlePainter(_screenWidth , _screenHeight , _animation.value),),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 100, 10),
                  child:
                     Row(
                       children: <Widget>[
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget> [
                              Spacer(),
                              OutlineButton(
                                child: const Text('New Game'),
                                onPressed: () {
                                  decrescendo(2.0);
                                  print('New Game');
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                                    builder: (context) {
                                      return GamePage(_gameModel, title: 'TenPuzzle' , loadGame:false);
                                    },
                                  ));
                                },
                              ),
                              Spacer(),
                              Visibility(
                                visible: _gameModel.initialized,
                                child:
                                OutlineButton(
                                  child: const Text('Continue'),
                                  onPressed: () {
                                    decrescendo(2.0);
                                    print('Continue Button');
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                                      builder: (context) {
                                        return GamePage(_gameModel, title: 'TenPuzzle' , loadGame:_gameModel.initialized);
                                      },
                                    ));
                                  },
                                ),
                              ),
                              Spacer(),
                          ]),
                     ]),
                ),
              ],)
          )
    );
  }
}


class _TitlePainter extends CustomPainter {
  double radius;
  double _screenWidth;
  double _screenHeight;

  _TitlePainter(this._screenWidth , this._screenHeight, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    //print("$size");
    var paint = Paint()
      ..isAntiAlias = true
      ..color = Colors.grey
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    Offset screenCenter = Offset(_screenWidth / 2 , _screenHeight /2 );
    Offset screenLeftSideCenter = Offset(_screenWidth *  0.25 , _screenHeight /2 );
//    Offset screenRightSideCenter = Offset(_screenWidth *  0.75 , _screenHeight /2 );

    var logoUnitSize = _screenHeight * 0.25;


    Offset oneTopPosition   = screenLeftSideCenter - Offset(0 , logoUnitSize * (radius / 100));
    Offset oneBottomPosition = screenLeftSideCenter + Offset(0 , logoUnitSize * (radius / 100));

    canvas.drawLine(oneTopPosition, oneBottomPosition, paint);


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
