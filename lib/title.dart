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

    super.initState();

    WidgetsBinding.instance.addObserver(this);
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

    Offset oneTopPosition   = screenLeftSideCenter - Offset(0 , (_screenHeight * 0.25) * (radius / 100));
    Offset oneBottomPosition = screenLeftSideCenter + Offset(0 , (_screenHeight * 0.25) * (radius / 100));

    canvas.drawLine(oneTopPosition, oneBottomPosition, paint);


    var rect = Rect.fromCenter(center: screenCenter , width:200 , height:200);

//    var degToRad = (deg) => deg * pi / 180;

    canvas.drawArc (rect,0 , -pi * (radius / 100) , false , paint);
    canvas.drawArc (rect, pi - pi * (radius / 100) ,pi * (radius / 100) , false , paint);

    // canvas.drawCircle(
    //   screenCenter,
    //   100 * (radius / 100),
    //   paint,
    // );

//    canvas.drawLine(Offset(200.0, 100.0), Offset(size.width - size.width * radius, size.height - size.height * radius), paint);

    //var rect = Rect.fromLTWH(50,50,300,300);
    // canvas.drawArc (rect,0 , 3.14 , false , paint);
    //
    // paint.color = Colors.red;
    // canvas.drawArc (rect, degToRad(0) , degToRad(90)  , false , paint);
    // paint.color = Colors.blue;
    // canvas.drawArc (rect, degToRad(90) , degToRad(30)  , false , paint);
    // paint.color = Colors.green;
    // canvas.drawArc (rect, degToRad(0) , degToRad(radius * -1)  , false , paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// class Line extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _LineState();
// }
//
// class _LineState extends State<Line> with SingleTickerProviderStateMixin {
//   double _progress = 0.0;
//   Animation<double> animation;
//
//   @override
//   void initState() {
//     super.initState();
//     var controller = AnimationController(duration: Duration(milliseconds: 3000), vsync: this);
//
//     animation = Tween(begin: 1.0, end: 0.0).animate(controller)
//       ..addListener(() {
//         setState(() {
//           _progress = animation.value;
//         });
//       });
//
//     controller.forward();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(painter: LinePainter(_progress));
//   }
// }
//
// class LinePainter extends CustomPainter {
//   Paint _paint;
//   double _progress;
//
//   LinePainter(this._progress) {
//     _paint = Paint()
//       ..color = Colors.green
//       ..strokeWidth = 8.0;
//   }
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     canvas.drawLine(Offset(0.0, 0.0), Offset(size.width - size.width * _progress, size.height - size.height * _progress), _paint);
//   }
//
//   @override
//   bool shouldRepaint(LinePainter oldDelegate) {
//     return oldDelegate._progress != _progress;
//   }
// }
