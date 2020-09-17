import 'package:flutter/material.dart';

import 'package:flutter/services.dart'; // landscape レイアウト指定

//import 'dart:math' as math;

import 'package:tenpuzzle/AnswerLine.dart';
import 'package:tenpuzzle/GameModel.dart';

import 'package:tenpuzzle/strEval.dart';

void main() {

    // 文字列evalテストコード
    double r = calcString("1*2*3*4*5*6*7*8*9");
    print("r:$r");

    runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    // landscape layout
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {

  //var _random = new math.Random();

  GameModel _gameModel = GameModel();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    print("screen $screenWidth x $screenHeight");

    _gameModel.initialize(screenWidth, screenHeight);
  }


  _MyHomePageState();

  void _dragStartProc(Offset offset){
    if ( _gameModel.isDragging ){return;}
    setState(() {
      _gameModel.dragStartAction(offset);
    });
  }

  void _draggingProc(Offset offset){
    setState(() {
      _gameModel.dragAction(offset);
    });
  }

  void _dragEndProc(Offset offset)
  {
    setState(() {
      _gameModel.dragEndAction(offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Stack(
        children: <Widget>[

          GestureDetector(
              // onHorizontalDragStart:(/* DragStartDetails */ details) {
              //   print("onHorizontalDragStart local dx:${details.localPosition.dx} dy:${details.localPosition.dy} global dx:${details.globalPosition.dx} dy:${details.globalPosition.dy}");
              //   _dragStartProc(details.localPosition);
              // },
              // onVerticalDragStart:(/* DragStartDetails */ details) {
              //   print("onVerticalDragStart local dx:${details.localPosition.dx} dy:${details.localPosition.dy} global dx:${details.globalPosition.dx} dy:${details.globalPosition.dy}");
              //   _dragStartProc(details.localPosition);
              // },
              // onVerticalDragUpdate:(DragUpdateDetails details){
              //   //print("onVerticalDragUpdate local dx:${details.localPosition.dx} dy:${details.localPosition.dy} global dx:${details.globalPosition.dx} dy:${details.globalPosition.dy}");
              //   _draggingProc(details.localPosition);
              // },
              // onVerticalDragEnd:(/* DragStartDetails */ details) {
              //   print("onVerticalDragEnd");
              //   _dragging = false;
              // },
              // onHorizontalDragEnd: (/* DragStartDetails */ details) {
              //   print("onHorizontalDragEnd");
              //   _dragging = false;
              // },
              behavior: HitTestBehavior.opaque, // 子Widget以外もタッチイベント対象にする
              onTap: () {
                print("onTap");
              },
              onLongPressStart:(details){
                print("onLongPressStart:${details.globalPosition} ${details.localPosition}}");
                //final GestureLongPressStartCallback
                _dragStartProc(details.localPosition);
              },
              onLongPressMoveUpdate : (details){
                //final GestureLongPressMoveUpdateCallback
                print("onLongPressMoveUpdate:${details.globalPosition} ${details.localPosition}}");
                _draggingProc(details.localPosition);
              },

              onLongPressUp : (){
                //final GestureLongPressUpCallback
                print("onLongPressUp");
              },

              onLongPressEnd : (details) {
                //final GestureLongPressEndCallback
                print("onLongPressEnd:${details.globalPosition} ${details.localPosition}}");
                _dragEndProc(details.localPosition);
              },


                child : Stack(
                  children: [
                    _movePanel(_gameModel.panelPosList , "Draggable"),
                    Visibility(child: AnswerLineWidget(_gameModel.answerStart,_gameModel.answerEnd),
                      visible: _gameModel.visibleAnswerLine),//_visibleAnswerLine),
  

                  ],
              )
          ),

          // Positioned(
          //   top: 10.0,
          //   left: 10.0,
          //   width: 100.0,
          //   height: 100.0,
          //   child: panel('FIX'),
          // ),
          // Positioned(
          //   top: _random.nextDouble() * 300,
          //   left: _random.nextDouble() * 100,
          //   width: 100,
          //   height: 100,
          //   child: panel('RANDOM'),
          // ),


        ]
      ),
    );
  }

  Widget _movePanel( List<PanelData> panelList , String labelText) {
    return Stack(
      children: <Widget>
        [for (var panelData in panelList)
            Positioned(
              left: panelData.rect.left,
              top: panelData.rect.top,
              width: panelData.rect.width,
              height: panelData.rect.height,
              child: Container(color: panelData.selected == true ? Colors.redAccent : Colors.indigo,
                  child:Card(
                    color: panelData.selected == true ? Colors.pink[200] : Colors.blue,
                    child: Center(
                      child: Text(panelData.title),
                    ),
                  )),
            )
        ],
    );
  }

  Widget panel(String labelText) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 1.0,
            blurRadius: 10.0,
            offset: Offset(10, 10),
          ),
        ],
      ),
      width: 200.0,
      height: 100.0,
      child: Card(
        color: Colors.blue,
        child: Center(
          child: Text(labelText),
        ),
      ),
    );
  }

}
