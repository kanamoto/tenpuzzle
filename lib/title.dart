import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import "dart:math" show pi;

import 'package:tenpuzzle/game.dart';

class TitlePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Home();
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home>  with SingleTickerProviderStateMixin  ,  WidgetsBindingObserver {

  Animation<double> _animation;
  AnimationController _animationController;

  double _screenWidth;
  double _screenHeight;

  @override
  void initState() {
    print("initState");

    super.initState();
    WidgetsBinding.instance.addObserver(this);

    initAnimation();

    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/sound/madness1.mp3"),
      autoStart: true,
      showNotification: true,
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
    if ( state == AppLifecycleState.resumed){
      _animationController.forward();
    }
    // if ( state == AppLifecycleState.paused){
    //   _animationController.reverse();
    // }
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
            behavior: HitTestBehavior.opaque, // 子Widget以外もタッチイベント対象にする
            onPointerUp: (PointerEvent details) {
              print("onPointerDown");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GamePage(title: 'Flutter Demo Home Page')),
              );
            },
            child: SizedBox.expand( // https://stackoverflow.com/questions/50518373/flutter-getting-touch-input-on-custompainters
                 child: CustomPaint(painter: _TitlePainter(_screenWidth , _screenHeight , _animation.value),),
              )
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
