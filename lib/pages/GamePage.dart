import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tenpuzzle/model/ResourceConst.dart';
import 'package:tenpuzzle/model/GameModel.dart';
import 'package:tenpuzzle/model/ModelData.dart';
import 'package:tenpuzzle/model/TimeElement.dart';
import 'package:tenpuzzle/pages/ManualPage.dart';
import 'package:tenpuzzle/pages/TitlePage.dart';
import 'package:tenpuzzle/peripheral/Log.dart';
import 'package:tenpuzzle/widget/GamePanelFactory.dart';
import 'package:tenpuzzle/widget/MeasureWidget.dart';
import 'package:tenpuzzle/widget/PlayTimerDisplay.dart';

import 'RecordListPage.dart';


class GamePage extends StatefulWidget {
  GamePage(this._gameModel, {Key? key, required this.title , required this.loadGame}) : super(key: key);

  final GameModel _gameModel;

  final String title;

  final bool loadGame;

  @override
  _GamePageState createState() => _GamePageState(_gameModel);
}



class _GamePageState extends State<GamePage> with WidgetsBindingObserver, TickerProviderStateMixin {//{}SingleTickerProviderStateMixin {

  GameModel _gameModel;

  bool _loadedOrAlreadyNewGame = false; // iOSでrecord画面遷移時にdidChangeDependenciesが呼び出されて、データが再ロードされてしまう。それを防ぐ措置。

  _GamePageState(this._gameModel);

  void _loadPlayData() async
  {

    if ( _loadedOrAlreadyNewGame == true){
      Log.print("_loadedOrAlreadyNewGame");
      return;
    }
    Log.print("start _loadPlayData");
    bool hadGame = _gameModel.hadSavePlayData;
    if ( hadGame == true){
      await _gameModel.loadPlayData((gameModel) {
        if ( mounted ) {
          _loadedOrAlreadyNewGame = true;
          playPanelAppearingSound();
          restartNewGamePanelAppearanceAnimation();
          setState((){
            Log.print("GamePage _loadPlayData mounted　_startGamePlayCount");
            _startGamePlayCount();
            tryCheckAnswer();
          });
        }else{
          Log.print("GamePage _loadPlayData not mounted");
        }
      });
    }
    Log.print("end _loadPlayData");
  }

  @override
  void initState() {
    Log.print("${this.runtimeType} initState");
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    initAnimation();
  }

  @override
  void dispose() {
    Log.print("${this.runtimeType} dispose");
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Log.print('${this.runtimeType} didChangeAppLifecycleState state = $state');
    if ( state == AppLifecycleState.paused ){
      /* GameModelの中でAppLifecycleStateを受け取って保存すると、ゲームデータがない状態が発生するため、今はここで保存する */
      _gameModel.savePlayData().then((value){
        Log.print("${this.runtimeType} didChangeAppLifecycleState savePlayData done result:$value");
        if ( value == false ){
          // 保存に失敗している。
          print("***** DATA SAVE FAILED *****");
        }
      });
    }
  }

  double _screenWidth = 0;
  double _screenHeight = 0;

  @override
  void didChangeDependencies() {
    Log.print('state = didChangeDependencies');
    super.didChangeDependencies();

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // WindowPadding padding = WidgetsBinding.instance.window.viewPadding;
    // print("screen $screenWidth x $screenHeight padding:$padding");

    // 変更前後の比率rx,ryをえる。
    // 画面中央と各パネルの距離差分をとる。
    // パネルの差分に比率をかけて中央座標をたして、新座標とする。
    if ( _screenWidth != 0 && _screenHeight != 0) {
      Log.print("_screenWidth:$_screenWidth != 0 && _screenHeight:$_screenHeight != 0");
      _gameModel.adjustPanelPositionIfNeeded(screenWidth, screenHeight);
    }

    _screenWidth = screenWidth;
    _screenHeight = screenHeight;

    _gameModel.initializeScreenSize(screenWidth, screenHeight);
    if ( widget.loadGame == true ){
      Log.print("before _loadPlayData");
      _loadPlayData();
      Log.print("after _loadPlayData");
    }else{
      if ( _loadedOrAlreadyNewGame == false ) {
        _loadedOrAlreadyNewGame = true;
        Log.print("_newGame");
        _newGame();
      }
    }
  }

  void addOperator(Offset offset , PanelData panelData)
  {
    setState(() {
      _gameModel.addOperator(offset , panelData.showStr);
    });
  }

  void _pointerDown(PointerEvent details) {
    if ( _gameModel.isDragging ){return;}
    setState(() {
      _gameModel.startDragAction(details.position);
    });
  }

  void _pointerMove(PointerEvent details) {
    setState(() {
      _gameModel.dragAction(details.position);
    });
  }

  void _pointerUp(PointerEvent details) {
    setState(() {
      _gameModel.endDragAction(details.position);
    });

    tryCheckAnswer();
  }

  /// クリアダイアログで"END"を選んだ場合
  static const int CLEAR_DIALOG_END_GAME = 0;
  /// クリアダイアログで"NEXT"を選んだ場合
  static const int CLEAR_DIALOG_NEW_GAME = 1;

  void tryCheckAnswer() {
    _gameModel.checkAnswer( () {
      showDialog<int>(context: context , builder: (_)
      {
        AssetsAudioPlayer.newPlayer().open(
          Audio("assets/sound/decision4.mp3"),
          autoStart: true,
          showNotification: false,
          respectSilentMode: true
        );
        return createClearDialog();
      }).then((value) {
        if (value == CLEAR_DIALOG_NEW_GAME){
          setState((){
            _newGame();
          });
        }else{
          setState((){
            _clearGame();
          });
        }
      });
    });
  }

  String answerValueToShowString(GameModel gameModel)
  {
    double answerValue = gameModel.answerValue;
    bool validExpression = gameModel.validExpression;
    String result = "?";
    if ( answerValue.isNaN || answerValue.isInfinite || validExpression == false ) {
      result = "?";
    }else{
      if ( answerValue % 1 == 0){
        result = answerValue.truncate().toString();
      }else {
        result = answerValue.toString();
      }
    }
    return result;
  }

  SimpleDialog createClearDialog() {
    //_gameModel.timeStream
    String playTimeString = TimeElement.fromCount(_gameModel.playTime).toString();

    Log.print('createClearDialog _playTimerString:$playTimeString');
    return SimpleDialog(
        title: Center(child: Text("Cleared!", style:TextStyle(fontSize: 30.0))),
        children: <Widget>[
          // コンテンツ領域
          SimpleDialogOption(
            child: Center( child:Column(children: <Widget> [
              Text('${_gameModel.showString} = ${answerValueToShowString(_gameModel)} ', style:TextStyle(fontSize: 30.0)),
              Text('Time:$playTimeString', style:TextStyle(fontSize: 24.0)),
              //Text("Try to next one.", style:TextStyle(fontSize: 24.0))
            ],)),
          ),
            Row(children: <Widget>[

              Spacer(),

              TextButton(
                  child: Text(
                      "Next".toUpperCase(),
                      style: TextStyle(fontSize: 14)
                  ),
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.white)
                          )
                      )
                  ),
                  onPressed: () {
                    Navigator.pop(context, CLEAR_DIALOG_NEW_GAME);
                  }
              ),

              Spacer(),

              TextButton(
                  child: Text(
                      "End".toUpperCase(),
                      style: TextStyle(fontSize: 14)
                  ),
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.white)
                          )
                      )
                  ),
                  onPressed: () {
                    Navigator.pop(context, CLEAR_DIALOG_END_GAME);
                  }
              ),

              Spacer(),

            ])

        ]
    );
  }

  void _newGame() {

    _gameModel.newGame();

    playPanelAppearingSound();
    restartNewGamePanelAppearanceAnimation();
  }

  void _clearGame(){
    _gameModel.clearGame();
  }

  void playPanelAppearingSound() {
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/sound/decision25.mp3"),
        autoStart: true,
        showNotification: false,
        respectSilentMode: true
    );
  }

  void _showRecord()
  {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RecordListPage(_gameModel))
    );
  }

  /// for Debug
  // void _recordDump()
  // {
  //   Future<List<GameRecord>> future = _gameModel.recordList();
  //   future.then((value) {
  //     for ( GameRecord record in value){
  //       var id = record.id;
  //       var question = record.question;
  //       var playDateTime = record.playDateTime;
  //       var gameClearTime = record.gameClearTime;
  //       var clearExpression = record.clearExpression;
  //
  //       print("$id $question $playDateTime $gameClearTime $clearExpression ");
  //
  //       print("$record.id $record.question $record.playDateTime $record.gameClearTime $record.clearExpression ");
  //     }
  //   });
  // }

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
      _gameModel.resetGame();

      if ( value == true ){
        toTitlePage();
      }else{
        AlertDialog(
          title: Text("Save failure"),
          content: Text("Sorry, Failed to save game data."),
          actions: <Widget>[
            // ボタン領域
            TextButton(
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

  void _showManual()
  {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ManualPage(ResourceConst.MANUAL_HTML))
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    Offset operatorOffset = Offset(_screenWidth / 2, _screenHeight / 2);

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
                  operatorButton(_gameModel.trashPanel , tapEvent:() => _gameModel.clearOperator() ),
                  _operatorPanel(_gameModel.operatorPosList, tapEvent:(PanelData panelData){
                      addOperator(operatorOffset, panelData);
                  }),
              StreamBuilder(
                  stream: _gameModel.adjustPanelStream,
                  builder: (BuildContext context, AsyncSnapshot<PanelData> snapShot) {
                    return _movePanel(_gameModel.panelPosList);
                  }),
                ],
              )
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(30, 15, 20, 15),
            child:headerWidget(),
          ),
        ],
      ),
      //     ),// SaveArea
    );
  }

  Widget headerWidget() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(color: Colors.white,
                     child: buildPopupMenuButton(_gameModel)
                ),
                Expanded(
                    child:
                Padding(padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                    child:
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    PlayTimerDisplay(gameModel:_gameModel),
                    Visibility(visible: _gameModel.showString.isNotEmpty , child:
                      Text('${_gameModel.showString} = ${answerValueToShowString(_gameModel)}',
                        style: TextStyle(
                          fontSize: 20,
                        fontWeight: FontWeight.bold),
                      )
                    )
                  ])
                )
                )
              ]
          );
  }

  PopupMenuButton<int>  buildPopupMenuButton(GameModel gameModel) {
    var saveEnabled = gameModel.hadPlayData;
    return PopupMenuButton<int>(
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
          case 3:
            _showManual();
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
        PopupMenuItem<int>(
          value: 2,
          child: Text('Save'),
          enabled: saveEnabled,
        ),
        const PopupMenuItem<int>(
          value: 3,
          child: Text('Manual'),
        ),
      ],
    );
  }

  /// 演算子追加パネル
  Widget _operatorPanel( List<PanelData> panelList , {Function(PanelData)? tapEvent}) {
    return Stack(
      children: <Widget>[
        for (var panelData in panelList)
          operatorButton(panelData, tapEvent:() => tapEvent!(panelData))
      ],
     );
  }

  Widget operatorButton(PanelData panelData, {Function()? tapEvent})
  {
    return Positioned(
      left: panelData.rect.left,
      top: panelData.rect.top,
      width: panelData.rect.width,
      height: panelData.rect.height,
      child:
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          side: BorderSide(
            color: Colors.black, //枠線!
            width: 1, //枠線！
          ),
          backgroundColor: Colors.white,
        ),
        onPressed: () {
          if ( tapEvent != null ) {
            tapEvent();
          }
        },
        child:Text(panelData.showStr, textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 30,
                color:Colors.black,
                fontWeight: FontWeight.bold),

          ),
      ),

    );
  }


  void initAnimation() {

    initNewGamePanelAppearanceAnimation();

    initOperatorAppearanceAnimation();
  }

  Animation<double>? _newGamePanelAppearanceAnimation;
  AnimationController? _newGamePanelAppearanceAnimationController;
  double _newGamePanelAppearanceAnimationExpansionRate = 0.0;

  ///
  /// パネル登場アニメーションの初期化
  ///
  void initNewGamePanelAppearanceAnimation() {
    if (_newGamePanelAppearanceAnimationController != null){
      _newGamePanelAppearanceAnimationController!.dispose();
    }
    
    _newGamePanelAppearanceAnimationController =
    AnimationController( duration: const Duration(seconds: 1), vsync: this)..addListener(() {
      setState(() {
        _newGamePanelAppearanceAnimationExpansionRate = _newGamePanelAppearanceAnimation!.value;
      });
    })..addStatusListener((status) {
      Log.print('GamePage AnimationController Status:$status');
      if (status == AnimationStatus.completed) {
        _startGamePlayCount();
      }
    });
    _newGamePanelAppearanceAnimation = ReverseTween(Tween(begin: 0.0, end: 100.0)).animate(_newGamePanelAppearanceAnimationController!);
      //  _animationController.forward();
  }

  void restartNewGamePanelAppearanceAnimation() {
    _newGamePanelAppearanceAnimationController?.reset();
    _newGamePanelAppearanceAnimationController?.forward();
  }

  void initOperatorAppearanceAnimation()
  {
  }

  void _startGamePlayCount() {
    _gameModel.startCount((count) {
      // このタイミングでsetStateが欲しいのは、ロードデータの読み込み直後に更新されない場合のみ
      // if (mounted){
      //   setState(() {});
      // }
    });
  }

  Widget _movePanel( List<PanelData> panelList) {
    return Stack(
      children: <Widget>

      [for (var panelData in panelList)
          gamePanelFactory(panelData , _newGamePanelAppearanceAnimationExpansionRate)
      ],
    );
  }

  Widget operationButton(String labelText , double width , double height , Function(Offset) tapEvent) {
    GlobalKey globalKey = GlobalKey();

    return Container(
        width: width,
        height: height,
        child:

        ElevatedButton(
          key: globalKey,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          onPressed: () {
            RenderBox? box = globalKey.currentContext?.findRenderObject() as RenderBox?;
            if (box != null){
              Offset widgetPos = box.localToGlobal(Offset.zero);
              tapEvent(widgetPos);
            }
          },
          onLongPress :(){
            RenderBox? box = globalKey.currentContext?.findRenderObject() as RenderBox?;
            if (box != null) {
              Offset widgetPos = box.localToGlobal(Offset.zero);
              tapEvent(widgetPos);
            }
          },
          child:Text(labelText,  style: TextStyle(fontSize: 25.0), textAlign: TextAlign.center),
        ),

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

