import 'package:flutter/material.dart';

import 'package:flutter/services.dart'; // landscape レイアウト指定

import 'dart:math' as math;

import 'package:tenpuzzle/AnswerLine.dart';

void main() {
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


class ModelData {

  int selectedIdx = -1;
  PanelData selectedPanel;

  List<PanelData>  panelPosList = [];

  void initialize(double width , double height)
  {
    for ( int i = 0 ; i < 10 ; i++ ){
//      panelPosList.add(Rect.fromCenter(center: Offset(_random.nextDouble() * 200 , _random.nextDouble() * 400), width: 100 , height:100));
      PanelData panelData = PanelData();
      // panelData.rect = Rect.fromCenter(center: Offset(i.toDouble() * 100 % 300 , i.toDouble() * 100 % 300), width: 100 , height:100);
      panelData.rect = Rect.fromLTWH((i.toDouble() * 100) % 300, (i ~/ 3).toDouble() * 100 , 100, 100);
      panelData.title = "$i";
      panelPosList.add(panelData);
    }

    panelPosList.asMap().forEach((key, target) {
      print("idx:$key target:${target.title} ${target.rect}");
    });

  }

}


class PanelData {
  Rect rect;
  String title = "";
  bool selected = false;
}

class _MyHomePageState extends State<MyHomePage> {

  var _random = new math.Random();

  double _posX = 100;
  double _posY = 100;

  double _dx = 0;
  double _dy = 0;

  ModelData _modelData = ModelData();


  bool _visibleAnswerLine = false;
  Offset answerStart = new Offset(100 , 100);
  Offset answerEnd = new Offset(200 , 300);


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    print("screen $screenWidth x $screenHeight");

    _modelData.initialize(screenWidth, screenHeight);

  }

  void dragStartAction(Offset position)
  {
    print("dragStartAction");
    _modelData.selectedIdx = -1;
    int selectedIdx = -1;
    PanelData selectedRect;
    for ( int idx = 0 ; idx < _modelData.panelPosList.length ; idx++ ){
      PanelData target = _modelData.panelPosList[idx];

      if ( target.rect.contains(position) ){
        selectedRect = target;
        selectedIdx = idx;
        print("[selected] idx:$idx target:${target.title} ${target.rect} position:$position");
        break;
      }else {
        print("           idx:$idx target:${target.title} ${target.rect} position:$position");
      }
    }

    if ( selectedIdx == -1) {
      /* どのパネルでもない */
      print("Long tap empty area.");

      _visibleAnswerLine = true;
      answerStart = new Offset(position.dx , position.dy);
      answerEnd = new Offset(position.dx , position.dy);
    }else{
      // panelPosList.removeAt(selectedIdx);//  . remove(selectedRect);
      if ( _modelData.panelPosList.remove(selectedRect) == true){
        _modelData.panelPosList.add(selectedRect);
      }else{
        print("can't  remove");
      }

      _modelData.selectedIdx = selectedIdx;
      _modelData.selectedPanel = selectedRect;
      _modelData.selectedPanel.selected = true;
    }
  }

  void dragAction(Offset position)
  {
    print("dragAction _selectedIdx:${_modelData.selectedIdx} position:$position");
    if (_modelData.selectedIdx == -1){
      _visibleAnswerLine = true;
      answerEnd = new Offset(position.dx , position.dy);
      return;
    }
    if ( _modelData.panelPosList.length == 0 ){
      return;
    }

    PanelData target = _modelData.panelPosList[_modelData.panelPosList.length - 1];

    double newDx = target.rect.center.dx + (position.dx - _dx);
    double newDy = target.rect.center.dy + (position.dy - _dy);

    target.rect = Rect.fromCenter(center: Offset(newDx , newDy) , width: target.rect.width , height:target.rect.height);

//    panelPosList.[0] = target;
//     panelPosList.remove(target);
//     panelPosList.add(target);
  }

  void dragEndAction(Offset offset) {
    print("dragEndAction");
    _dragging = false;
    if (_modelData.selectedIdx == -1){
      _visibleAnswerLine = false;
      answerEnd = new Offset(offset.dx , offset.dy);
      /* TODO:判定処理 */
    }else{
      _modelData.selectedIdx = -1;
      _modelData.selectedPanel.selected = false;
      _modelData.selectedPanel = null;
    }
  }

  _MyHomePageState(){}


  bool _dragging = false;

  void _dragStartProc(Offset offset){
    if ( _dragging ){return;}
    _dragging = true;
    _dx = offset.dx;
    _dy = offset.dy;
    setState(() {
      dragStartAction(offset);
    });
  }

  void _draggingProc(Offset offset){
    setState(() {
      dragAction(offset);
    });
    _dx = offset.dx;
    _dy = offset.dy;
  }

  void _dragEndProc(Offset offset)
  {
    setState(() {
      dragEndAction(offset);
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
                    _movePanel(_modelData.panelPosList , "Draggable"),
                    Visibility(child: AnswerLineWidget(answerStart,answerEnd),
                      visible: _visibleAnswerLine),//_visibleAnswerLine),
  

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
