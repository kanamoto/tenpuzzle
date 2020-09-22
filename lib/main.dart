import 'package:flutter/material.dart';

import 'package:flutter/services.dart'; // landscape レイアウト指定

import 'package:tenpuzzle/AnswerLine.dart';
import 'package:tenpuzzle/GameModel.dart';

import 'package:tenpuzzle/strEval.dart';

import 'package:tenpuzzle/QuestionData.dart';

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
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    // landscape layout
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      title: 'Ten Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {

  GameModel _gameModel = GameModel();

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if ( _isInitialized == true) {
      return;
    }

    _isInitialized = true;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    print("screen $screenWidth x $screenHeight");

    _gameModel.initialize(screenWidth, screenHeight);

    String questionString = QuestionData.getDataAtRandom();
    print("questionString:$questionString");

    _gameModel.addNumericPanelForGame(questionString);

  }


  _MyHomePageState();

  // void _dragStartProc(Offset offset){
  //   if ( _gameModel.isDragging ){return;}
  //   setState(() {
  //     _gameModel.dragStartAction(offset);
  //   });
  // }
  //
  // void _draggingProc(Offset offset){
  //   setState(() {
  //     _gameModel.dragAction(offset);
  //   });
  // }
  //
  // void _dragEndProc(Offset offset)
  // {
  //   setState(() {
  //     _gameModel.dragEndAction(offset);
  //   });
  // }

  void addOperator(Offset offset , String operatorStr)
  {
    setState(() {
      _gameModel.addOperator(offset , operatorStr);
    });
  }

  void _pointerDown(PointerEvent details) {
    print("PointerDown Start");
//    _currentPosition = details.position;
    if ( _gameModel.isDragging ){return;}
    setState(() {
      print("PointerDown segState");
      _gameModel.dragStartAction(details.position);
    });
    print("PointerDown End");
  }

  void _pointerMove(PointerEvent details) {
    print("PointerMove start");
//    _currentPosition = details.position;
    setState(() {
      print("PointerMove setState");
      _gameModel.dragAction(details.position);
    });
    print("PointerMove end");
  }

  void _pointerUp(PointerEvent details) {
    print("PointerUp Start");
//    _currentPosition = details.position;
    setState(() {
      print("PointerUp setState");
      _gameModel.dragEndAction(details.position);
      _gameModel.dragEndAction(details.position);
    });
    print("PointerUp End");

    if (_gameModel.checkAnswer()){

      showDialog(context: context , builder: (_)
      {
        return createClearDialog();
      });
    }
  }

  SimpleDialog createClearDialog() {
    return SimpleDialog(
        title: Text('${_gameModel.capturedString}= ${ calcString(_gameModel.capturedString) } ・・・ OK!'),
        children: <Widget>[
          // コンテンツ領域
          SimpleDialogOption(
            // onPressed: () {
            //   // _gameModel.clearAllPanel();
            //   // String questionString = QuestionData.getDataAtRandom();
            //   // print("questionString:$questionString");
            //   // _gameModel.addNumericPanelForGame(questionString);
            //   // //Navigator.pop(context);
            // },
            child: Text("Try tot next one."),
          ),
          FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.red)),
            color: Colors.white,
            textColor: Colors.red,
            padding: EdgeInsets.all(8.0),
            onPressed: () {
              setState((){
                _gameModel.clearAllPanel();
                String questionString = QuestionData.getDataAtRandom();
                print("questionString:$questionString");
                _gameModel.addNumericPanelForGame(questionString);
              });
              Navigator.pop(context, true);
            },
            child: Text(
              "Next".toUpperCase(),
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ),
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Stack(
        children: <Widget>[


          Listener(
            behavior: HitTestBehavior.opaque, // 子Widget以外もタッチイベント対象にする
            onPointerDown: _pointerDown,
            onPointerMove: _pointerMove,
            onPointerUp: _pointerUp,
            child:
                Stack(
                  children: [
                    _movePanel(_gameModel.panelPosList , "Draggable"),
                    Visibility(child: AnswerLineWidget(_gameModel.answerStart,_gameModel.answerEnd),
                               visible: _gameModel.visibleAnswerLine),//_visibleAnswerLine),
                  ],
              )
          ),

          operatorBoard(),

          Center(child:
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Spacer(),
                    Visibility(
                      visible:  _gameModel.visibleAnswerLine,
                      child:Text(
                        'capture : ${_gameModel.capturedString} = ${ calcString(_gameModel.capturedString) }',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )
                    )
                  ],
              ),
            ),
          ),

         ],

      ),
    );
  }

  Color panelBorderColor(PanelData panelData)
  {
    Color borderColor;
    if ( panelData.kind == PanelDataKind.NUMERIC ){
      borderColor = Colors.indigo;
    }else{
      borderColor = Colors.white30;
    }
    return panelData.selected == true ? Colors.redAccent : borderColor;
  }

  Color panelBodyColor(PanelData panelData)
  {
    Color bodyColor;
    if ( panelData.kind == PanelDataKind.NUMERIC ){
      bodyColor = Colors.blue;
    }else{
      bodyColor = Colors.grey;
    }
    return panelData.selected == true ? Colors.pink[200] : bodyColor;
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
              child: Container(color: panelBorderColor(panelData),
                  child:Card(
                    color: panelBodyColor(panelData),
                    child: Center(
                      child: Text(panelData.title),
                    ),
                  )),
            )
        ],
    );
  }

  Widget operatorBoard()
  {
    return Container(
      child: Row(
        children: <Widget>[
          Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child:           Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  operationButton("C" , ModelData.OPERATOR_PANEL_WIDTH , ModelData.OPERATOR_PANEL_HEIGHT , (_) => {
                    setState((){
                      _gameModel.clearOperator();
                    })
                  }),
                ]
              ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                operationButton("+" , ModelData.OPERATOR_PANEL_WIDTH , ModelData.OPERATOR_PANEL_HEIGHT , (offset) {
                  Offset newPos = Offset(offset.dx - ModelData.OPERATOR_PANEL_WIDTH , offset.dy);
                  addOperator(newPos, "+");
                }),
                Spacer(),
                operationButton("-" , ModelData.OPERATOR_PANEL_WIDTH , ModelData.OPERATOR_PANEL_HEIGHT , (offset) {
                  Offset newPos = Offset(offset.dx - ModelData.OPERATOR_PANEL_WIDTH , offset.dy);
                  addOperator(newPos, "-");
                }),
                Spacer(),
                operationButton("*" , ModelData.OPERATOR_PANEL_WIDTH , ModelData.OPERATOR_PANEL_HEIGHT , (offset) {
                  Offset newPos = Offset(offset.dx - ModelData.OPERATOR_PANEL_WIDTH , offset.dy);
                  addOperator(newPos, "*");
                }),
                Spacer(),
                operationButton("/" , ModelData.OPERATOR_PANEL_WIDTH , ModelData.OPERATOR_PANEL_HEIGHT , (offset) {
                  Offset newPos = Offset(offset.dx - ModelData.OPERATOR_PANEL_WIDTH , offset.dy);
                  addOperator(newPos, "/");
                }),
                Spacer(),
                operationButton("(" , ModelData.OPERATOR_PANEL_WIDTH , ModelData.OPERATOR_PANEL_HEIGHT , (offset) {
                  Offset newPos = Offset(offset.dx - ModelData.OPERATOR_PANEL_WIDTH , offset.dy);
                  addOperator(newPos, "(");
                }),
                Spacer(),
                operationButton(")" , ModelData.OPERATOR_PANEL_WIDTH , ModelData.OPERATOR_PANEL_HEIGHT , (offset) {
                  Offset newPos = Offset(offset.dx - ModelData.OPERATOR_PANEL_WIDTH , offset.dy);
                  addOperator(newPos, ")");
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget operationButton(String labelText , double width , double height , Function(Offset) tapEvent) {
    GlobalKey globalKey = GlobalKey();

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
        width: width,
        height: height,
        child:
              RaisedButton(
                  key: globalKey,
                  child: Text(labelText),
                  color: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () {
                    print("onPressed:$labelText");
                    RenderBox box = globalKey.currentContext.findRenderObject();
                    print("ウィジェットのサイズ :${box.size}");
                    print("ウィジェットの位置 :${box.localToGlobal(Offset.zero)}");
                    Offset widgetPos = box.localToGlobal(Offset.zero);
                    tapEvent(widgetPos);
                  },
                 onLongPress :(){
                   print("onLongPressed:$labelText");
                   RenderBox box = globalKey.currentContext.findRenderObject();
                   print("ウィジェットのサイズ :${box.size}");
                   print("ウィジェットの位置 :${box.localToGlobal(Offset.zero)}");
                   Offset widgetPos = box.localToGlobal(Offset.zero);
                   tapEvent(widgetPos);

                 },

              )
    );
  }

  Widget panel(String labelText , double width , double height) {
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
      width: width,
      height: height,
      child: Card(
        color: Colors.grey,
        child: Center(
          child: Text(labelText),
        ),
      ),
    );
  }

}
