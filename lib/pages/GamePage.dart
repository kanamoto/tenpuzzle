import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:tenpuzzle/pages/TitlePage.dart';

import 'package:tenpuzzle/widget/AnswerLine.dart';
import 'package:tenpuzzle/model/GameModel.dart';
import 'package:tenpuzzle/model/ModelData.dart';

import 'package:tenpuzzle/peripheral/strEval.dart';
import 'package:tenpuzzle/model/TimeElement.dart';
import 'package:tenpuzzle/widget/GameCard.dart';
import 'package:tenpuzzle/widget/MeasureWidget.dart';

import 'RecordListPage.dart';

class GamePage extends StatefulWidget {
  GamePage(this._gameModel, {Key key, this.title , this.loadGame}) : super(key: key);

  final GameModel _gameModel;

  final String title;

  final bool loadGame;

  @override
  _GamePageState createState() => _GamePageState(_gameModel, loadGame);
}



class _GamePageState extends State<GamePage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {

  GameModel _gameModel;

  _GamePageState(this._gameModel, bool loadGame)
  {
    if ( loadGame == true ){
      print("before _loadPlayData");
      _loadPlayData();
      print("after _loadPlayData");
    }
  }

  void _loadPlayData() async
  {
    print("start _loadPlayData");
    bool loadGame = _gameModel.hadPlayData;
    if ( loadGame == true){
      _gameModel.loadPlayData().then((value){
        _startGamePlayCount();
        if ( mounted ) {
          setState((){ });
        }else{
          print("GamePage _loadPlayData not mounted");
        }
      });
    }
    print("end _loadPlayData");
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    initAnimation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    if ( state == AppLifecycleState.paused ){

      _gameModel.savePlayData().then((value){
        if ( value == false ){
          // 保存に失敗している。
          print("");
        }
      });

      //_saveRecord();
    }
  }

  double _screenWidth;
  double _screenHeight;

  static const String PLAY_TIME_RESET_STR = "00:00:00:000";
  String _playTimerString = PLAY_TIME_RESET_STR;// "00:00:00:000";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    print("screen $screenWidth x $screenHeight");

    _screenWidth = screenWidth;
    _screenHeight = screenHeight;

    _gameModel.initializeScreenSize(screenWidth, screenHeight);
  }


  void addOperator(Offset offset , String operatorStr)
  {
    setState(() {
      _gameModel.addOperator(offset , operatorStr);
    });
  }

  void _pointerDown(PointerEvent details) {
    print("PointerDown Start");
    if ( _gameModel.isDragging ){return;}
    setState(() {
      print("PointerDown segState");
      _gameModel.dragStartAction(details.position);
    });
    print("PointerDown End");
  }

  void _pointerMove(PointerEvent details) {
    print("PointerMove start");
    setState(() {
      print("PointerMove setState");
      _gameModel.dragAction(details.position);
    });
    print("PointerMove end");
  }

  void _pointerUp(PointerEvent details) {
    print("PointerUp Start");
    setState(() {
      print("PointerUp setState");
      _gameModel.dragEndAction(details.position);
    });
    print("PointerUp End");

    if (_gameModel.checkAnswer()){

      _gameModel.stopCount();

      _gameModel.writeRecord();

      showDialog<int>(context: context , builder: (_)
      {
        AssetsAudioPlayer.newPlayer().open(
          Audio("assets/sound/decision4.mp3"),
          autoStart: true,
          showNotification: false,
        );
        return createClearDialog();
      }).then((value) {
        if (value == 1){
          setState((){
            _newGame();
          });
        }else{
          setState((){
            _clearGame();
          });
        }
      });
    }
  }

  SimpleDialog createClearDialog() {
    return SimpleDialog(
        title: Center(child: Text("Cleared!")),
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
            child: Center( child:Column(children: <Widget> [
              Text('${_gameModel.capturedString}= ${ calcString(_gameModel.capturedString) } ・・・ OK!'),
              Text('Time:$_playTimerString'),
              Text("Try to next one.")
            ],)),
          ),
            Row(children: <Widget>[

              Spacer(),
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.grey)),
                color: Colors.white,
                textColor: Colors.red,
                padding: EdgeInsets.all(8.0),
                minWidth: 100,
                onPressed: () {
                  // ここでは画面を消すだけ。
                  Navigator.pop(context, 1);
                },
                child: Text(
                  "Next".toUpperCase(),
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
              Spacer(),
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.grey)),
                color: Colors.white,
                textColor: Colors.red,
                padding: EdgeInsets.all(8.0),
                minWidth: 100,
                onPressed: () {
                  // setState((){
                  //   newGame();
                  // });
                  Navigator.pop(context, 0);
                },
                child: Text(
                  "End".toUpperCase(),
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
              Spacer(),

            ])

        ]
    );
  }

  void _newGame() {

    _gameModel.resetCount();

    _playTimerString = PLAY_TIME_RESET_STR;

    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/sound/decision25.mp3"),
      autoStart: true,
      showNotification: false,
    );

    _gameModel.newGame();

    _animationController.reset();
    _animationController.forward();
  }

  void _clearGame(){
    _gameModel.resetCount();
    _gameModel.clearAllPanel();
    _playTimerString = PLAY_TIME_RESET_STR;
  }

  void _showRecord()
  {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RecordListPage(_gameModel))
    );

    // Future<List<GameRecord>> future = _gameModel.recordList();
    // future.then((value) {
    //   for ( GameRecord record in value){
    //     var id = record.id;
    //     var question = record.question;
    //     var playDateTime = record.playDateTime;
    //     var gameClearTime = record.gameClearTime;
    //     var clearExpression = record.clearExpression;
    //
    //     print("$id $question $playDateTime $gameClearTime $clearExpression ");
    //
    //     print("$record.id $record.question $record.playDateTime $record.gameClearTime $record.clearExpression ");
    //   }
    // });
  }

  void toTitlePage()
  {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return TitlePage(_gameModel);
      },
    ));
  }


  ///
  /// プレイデータを保存して、タイトルに戻る
  ///
  void _saveRecord()
  {
    _gameModel.savePlayData().then((value){
      _clearGame();

      if ( value == true ){
        toTitlePage();
      }else{
        AlertDialog(
          title: Text("Save failure"),
          content: Text("Sorry, Failed to save game data."),
          actions: <Widget>[
            // ボタン領域
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                toTitlePage();
              },
            ),
          ],
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body://SafeArea(child:
      Stack(
        children: <Widget>[
          MeasureWidget(_screenWidth,_screenHeight),
          Listener(
              behavior: HitTestBehavior.opaque, // 子Widget以外もタッチイベント対象にする
              onPointerDown: _pointerDown,
              onPointerMove: _pointerMove,
              onPointerUp: _pointerUp,
              child:
              Stack(
                children: [
                  _operatorPanel(_gameModel.operatorPosList),
                  _movePanel(_gameModel.panelPosList , "Draggable"),
                  Visibility(child: AnswerLineWidget(_gameModel.answerStart,_gameModel.answerEnd),
                      visible: _gameModel.visibleAnswerLine),//_visibleAnswerLine),
                ],
              )
          ),

          Center(child:
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                ),
                Spacer(),
              ],
            ),
          ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 10, 10),
            child:
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Card(
                    color: Colors.white,
                    child:
                        PopupMenuButton<int>(
                          onSelected: (int result) { setState(() {
                            switch(result){
                              case 0:
                                _newGame();
                                break;
                              case 1:
                                _showRecord();
                                break;
                              case 2:
                                _saveRecord();
                                break;
                            }
                          }); } ,
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                            const PopupMenuItem<int>(
                              value: 0,
                              child: Text('New Question'),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem<int>(
                              value: 1,
                              child: Text('Record'),
                            ),
                            const PopupMenuItem<int>(
                              value: 2,
                              child: Text('Save'),
                            ),
                            const PopupMenuItem<int>(
                              value: 3,
                              child: Text('about'),
                            ),
                          ],
                        )
                  ),
                    Text(
                      _playTimerString,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )
                ]
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 10, 20),
            child:
            Column(
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

        ],

      ),
      //     ),// SaveArea
    );
  }

  Widget _operatorPanel( List<PanelData> panelList) {
    return Stack(
      children: <Widget>[
        for (var panelData in panelList)
          operatorButton(panelData)
      ],
    );
  }

  Widget operatorButton(PanelData panelData)
  {
    return Positioned(
      left: panelData.rect.left,
      top: panelData.rect.top,
      width: panelData.rect.width,
      height: panelData.rect.height,
      child:
      RaisedButton(
        child: Text(panelData.title,
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold),

        ),
        color: Colors.white,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        onPressed: () {},
      ),
    );
  }

  Animation<double> _animation;
  AnimationController _animationController;
  double _expansionRate = 0.0;

  void initAnimation() {
    if ( _animationController != null){
      _animationController.dispose();
    }

    _animationController =
    AnimationController( duration: const Duration(seconds: 1), vsync: this)..addListener(() {
      setState(() {
        _expansionRate = _animation.value;
      });
    })..addStatusListener((status) {
      print('AnimationController Status:$status');
      if (status == AnimationStatus.completed) {
        _startGamePlayCount();
      }
      // if (status == AnimationStatus.completed) {
      //   _animationController.reverse();
      // } else if (status == AnimationStatus.dismissed) {
      //   _animationController.forward();
      // }
    });
    _animation = ReverseTween(Tween(begin: 0.0, end: 100.0)).animate(_animationController);
  //  _animationController.forward();
  }

  void _startGamePlayCount() {
    _gameModel.startCount((count) {
      //print("TimeCount:$count");
      TimeElement timeElement = TimeElement.fromCount(count);
      _playTimerString = timeElement.toString();
      if (mounted){
        setState(() {});
      }
    });
  }

  Widget _movePanel( List<PanelData> panelList , String labelText) {
    return Stack(
      children: <Widget>

      [for (var panelData in panelList)
          GameCard(panelData:panelData , expansionRate:_expansionRate)
      ],
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

