import 'package:flutter/material.dart';

import 'package:flutter/services.dart'; // landscape レイアウト指定

import 'package:tenpuzzle/AnswerLine.dart';
import 'package:tenpuzzle/GameModel.dart';

import 'package:tenpuzzle/strEval.dart';

import 'package:tenpuzzle/QuestionData.dart';

void main() {

    // 文字列evalテストコード
    double r = calcString("1*2*3*4*5*6*7*8*9");
    print("r:$r");

    String questionData = QuestionData.getDataAtRandom();
    print("questionData:$questionData");

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    print("screen $screenWidth x $screenHeight");

    _gameModel.initialize(screenWidth, screenHeight);

    String questionString = QuestionData.getDataAtRandom();
    print("questionString:$questionString");

    _gameModel.addNumericPanelForGame(questionString);

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

  void addOperator(String operatorStr)
  {
    setState(() {
      _gameModel.addOperator(operatorStr);
    });
  }

  void _pointerDown(PointerEvent details) {
    print("PointerDown");
    _currentPosition = details.position;
    if ( _gameModel.isDragging ){return;}
    setState(() {
      _gameModel.dragStartAction(details.position);
    });
  }

  void _pointerMove(PointerEvent details) {
    print("PointerMove");
    _currentPosition = details.position;
    setState(() {
      _gameModel.dragAction(details.position);
    });
  }

  void _pointerUp(PointerEvent details) {
    print("PointerUp");
    _currentPosition = details.position;
    setState(() {
      _gameModel.dragEndAction(details.position);
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

          Container(
            child: Row(
              children: <Widget>[
                Spacer(),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      operationButton("+" , ModelData.OPERATOR_PANEL_WIDTH , ModelData.OPERATOR_PANEL_HEIGHT , () => {
                        addOperator("+")
                      }),
                      Spacer(),
                      operationButton("-" , ModelData.OPERATOR_PANEL_WIDTH , ModelData.OPERATOR_PANEL_HEIGHT , () => {
                        addOperator("-")
                      }),
                      Spacer(),
                      operationButton("*" , ModelData.OPERATOR_PANEL_WIDTH , ModelData.OPERATOR_PANEL_HEIGHT , () => {
                        addOperator("*")
                      }),
                      Spacer(),
                      operationButton("/" , ModelData.OPERATOR_PANEL_WIDTH , ModelData.OPERATOR_PANEL_HEIGHT , () => {
                        addOperator("/")
                      }),
                      Spacer(),
                      operationButton("(" , ModelData.OPERATOR_PANEL_WIDTH , ModelData.OPERATOR_PANEL_HEIGHT , () => {
                        addOperator("(")
                      }),
                      Spacer(),
                      operationButton(")" , ModelData.OPERATOR_PANEL_WIDTH , ModelData.OPERATOR_PANEL_HEIGHT , () => {
                        addOperator(")")
                      }),
                      Spacer(),
                      operationButton("C" , ModelData.OPERATOR_PANEL_WIDTH , ModelData.OPERATOR_PANEL_HEIGHT , () => {
                        setState((){
                          _gameModel.clearOperator();
                        })
                      }),
                    ],
                  ),
                ),

              ],
            ),
          ),
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
        ]
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


  Widget operationButton(String labelText , double width , double height , Function() tapEvent) {
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
                  child: Text(labelText),
                  color: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () {
                    print("onPressed:$labelText");
                    tapEvent();
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
