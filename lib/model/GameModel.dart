import 'dart:async';
import 'dart:ui'; // Rect

import 'package:tuple/tuple.dart';
import 'package:vector_math/vector_math.dart';

import 'package:tenpuzzle/peripheral/strEval.dart';

import 'package:tenpuzzle/model/ModelData.dart';
import 'package:tenpuzzle/model/QuestionData.dart';

import 'package:tenpuzzle/model/DataStore.dart';

///
class GameModel {

  double _dx = 0;
  double _dy = 0;

  ModelData _modelData = ModelData();

  DataStore _dataStore = DataStore();

//  String _questionString = "";

  bool visibleAnswerLine = false;
  Offset answerStart = new Offset(100 , 100);
  Offset answerEnd = new Offset(200 , 300);

  List<PanelData> get panelPosList => _modelData.panelPosList;
  List<PanelData> get operatorPosList => _modelData.operatorPanelPosList;

  String _capturedString = "nan";
  get capturedString => _capturedString;

  bool _validExpression = false;

  bool _initialized = false;


  bool _hasSavePlayData = false;
  get hadSavePlayData => _hasSavePlayData;

  get hadPlayData => _modelData.hadQuestionString;


  get initialized => _initialized;

  Future<void> initialize(void onInitialized(GameModel gameModel)) async
  {
    print("GameModel initialize start");
    await _dataStore.initializeDB();

    await _dataStore.hasSavePlayData().then((value){
      _hasSavePlayData = value;
      _initialized = true;
      onInitialized(this);
    });

    print("GameModel initialize end");
  }

  void initializeScreenSize(double width , double height)
  {
    _modelData.initialize(width, height);
  }

  bool _dragging = false;

  bool get isDragging => _dragging;

  void dragStartAction(Offset position)
  {
    if ( _modelData.hadQuestionString == false ){
      return;
    }

    _dragging = true;
    _dx = position.dx;
    _dy = position.dy;

    print("dragStartAction");
    _modelData.selectedIdx = -1;
    int selectedIdx = -1;
    PanelData selectedRect;

    _modelData.clearSelectedPanel();

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

      /* 演算子を押しているか確認する */
      bool pushOperator = false;
      for ( int idx = 0 ; idx < _modelData.operatorPanelPosList.length ; idx++ ){
        PanelData target = _modelData.operatorPanelPosList[idx];

        if ( target.rect.contains(position) ){
          addOperator(position ,target.title);

          pushOperator = true;
          break;
        }
      }

      /* どのパネルもボタンも押されていない。 */
      if (pushOperator == false){
        visibleAnswerLine = true;
        answerStart = new Offset(position.dx , position.dy);
        answerEnd = new Offset(position.dx , position.dy);
      }
    }else{
      _modelData.setSelectedPanel(selectedRect);
    }
  }


  void dragAction(Offset position)
  {
    if ( _modelData.hadQuestionString == false ){
      return;
    }

    print("dragAction _selectedIdx:${_modelData.selectedIdx} position:$position");

    if (_modelData.selectedIdx == -1){
      visibleAnswerLine = true;
      answerEnd = new Offset(position.dx , position.dy);
      _modelData.clearSelectedPanel();
      _capturedString = captureAnswerLine().item1;
      return;
    }


    if ( _modelData.panelPosList.length == 0 ){
      return;
    }

    PanelData target = _modelData.panelPosList[_modelData.panelPosList.length - 1];

    double newDx = target.rect.center.dx + (position.dx - _dx);
    double newDy = target.rect.center.dy + (position.dy - _dy);

    target.rect = Rect.fromCenter(center: Offset(newDx , newDy) , width: target.rect.width , height:target.rect.height);

    _dx = position.dx;
    _dy = position.dy;
  }

  void dragEndAction(Offset offset) {
    print("dragEndAction");
    _dragging = false;
    if (_modelData.selectedIdx == -1){
      visibleAnswerLine = false;
      answerEnd = new Offset(offset.dx , offset.dy);
      /* 判定処理 */
      var result = captureAnswerLine();
      _capturedString = result.item1;
      _validExpression = result.item2;
      //print("result:$_capturedString validExpression:$_validExpression");

      _modelData.clearSelectedPanel();
    }else{
      _modelData.selectedIdx = -1;
      _modelData.selectedPanel.selected = false;
      _modelData.selectedPanel = null;
    }
  }

  Tuple2<String, bool> captureAnswerLine()
  {
    Vector3 ansP1 = new Vector3( answerStart.dx, answerStart.dy, 0.0);
    Vector3 ansP2 = new Vector3( answerEnd.dx  , answerEnd.dy, 0.0);

    bool allNumericSelcted = false;

    Vector3 ansVect =  ansP2 - ansP1;

    if ( ansVect == Vector3.zero() ){
      return Tuple2<String , bool>("" , false);
    }
    Vector3	ansVectUnit = ansVect.normalized();
    double ansLineLen =  ansVect.length;

    List<PanelData> ansPanelAry = new List();


    // パネル毎の距離を出します。
    for (int i = 0 ; i < panelPosList.length ; i++){
      PanelData panel = panelPosList[i];

      double widthHalf  = panel.rect.width / 2;
      //double heightHalf = panel.rect.height / 2;


      Vector3	panelPosVect =  new Vector3( panel.rect.center.dx , panel.rect.center.dy , 0.0);//   [Vector3D createWithX:panel.position.x + 24 Y:panel.position.y + 24 Z:0];
      Vector3	panelVect    =  panelPosVect - ansP1;

      double andDotPanel = ansVect.dot(panelVect);
      if ( andDotPanel <=  0){
        // 向きが違う
        print("panel:${panel.title} X ansLineLen.dot(onLineDist) $andDotPanel ");
        continue;
      }

      // 垂線との交点が、線上にない場合は違います。
      double onLineDist =  panelVect.dot(ansVectUnit);
      if (ansLineLen < onLineDist){
        print("panel:${panel.title} X ansLineLen < onLineDist $ansLineLen < $onLineDist");
        continue;
      }

      // 線とパネルの中央点との垂線交点です。
      Vector3 ansPanelCrossVect = ansVectUnit * onLineDist;// [ansVectUnit mul:onLineDist];

      // 線からパネルの幅半分以上離れている場合は無視します。
      double crossDist =  (panelVect - ansPanelCrossVect).length;//   [[panelVect sub:ansPanelCrossVect] norm];
      if (crossDist > widthHalf){
        print("panel:${panel.title} X crossDist:$crossDist > $widthHalf ");
        continue;
      }

      print("panel:${panel.title} SELECTED ansLineLen  onLineDist $ansLineLen , $onLineDist");

      panel.ansDist = onLineDist;
      panel.selected = true;
      ansPanelAry.add(panel);
    }

    if ( ansPanelAry.length == 0){
      return Tuple2<String , bool>("" , false);
    }

    List<PanelData> panelSortArray = List();
    panelSortArray.addAll(ansPanelAry);

    // 一番小さい距離から順に、文字列を得ます。
    panelSortArray.sort((a , b) => (a.ansDist - b.ansDist).sign.round()); //.sort((a,b) => a .id.compareTo(b.id));

    // 選択した文字列を連結して式文字列とします。
    StringBuffer ansString = StringBuffer("");
    panelSortArray.forEach((element) {ansString.write( element.title);});

    // 式文字列が正しく作らせれているか検査します。ここでは、数値が一つずつ選ばれてる事を確認します。
    int numCnt = 0;
    int numContCnt = 0;
    for (int i = 0 ; i < panelSortArray.length ; i++){
      PanelData panel =  panelSortArray[i];
      if (panel.kind == PanelDataKind.NUMERIC){
        if (numContCnt != 0){
          break;
        }
        numCnt++;
        numContCnt++;
      }else{
        numContCnt = 0;
      }
    }
    if (numCnt == 4){
      // 全ての数値を正しく(2つ以上つながることなく)選択しています。
      allNumericSelcted = true;
    }

    Tuple2 result = Tuple2<String , bool>(ansString.toString() , allNumericSelcted);
    return result;
  }


  void newGame()
  {
   clearData();
    String questionString = QuestionData.getDataAtRandom();
    print("questionString:$questionString");
    _modelData.addNumericPanelForGame(questionString);
  }

  void clearData(){
    resetCount();
    _dataStore.clearPlayData();
    clearAllPanel();
    _hasSavePlayData = false;
  }

  void addOperator(Offset offset , String operatorStr)
  {
    Offset newPosition = Offset(offset.dx -  ModelData.OPERATOR_PANEL_WIDTH / 2 , offset.dy -  ModelData.OPERATOR_PANEL_HEIGHT / 2 );

    PanelData panelData = _modelData.addOperatorPanel(newPosition , operatorStr);

    _modelData.setSelectedPanel(panelData);

    _dragging = true;
    _dx = offset.dx;
    _dy = offset.dy;

  }

  void clearOperator()
  {
    _modelData.clearOperator();
  }

  void clearAllPanel()
  {
    _modelData.clearAllPanel();
    _capturedString = "";
    _validExpression = false;
  }

  bool checkAnswer(void clearedProcess())
  {
    if ( _validExpression == false ){
      return false;
    }

    double answer = calcString(capturedString);
    if ( answer != 10){
      return false;
    }

    stopCount();
    writeRecord();

    clearedProcess();

    return true;
  }


//region
  // ignore: close_sinks
  StreamController<int> _timeStreamController = new StreamController<int>();

  Stream<int>  _timeStream;

  get timeStream => _timeStream;


  StreamSubscription<int> _timeStreamSubscription;

  /// When finish running timer, it need to dispose.
  Future<void> dispose() async {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }

    await _timeStreamSubscription.cancel();
    await _timeStreamController.close();
  }

  Timer _timer;
  int _stopTime = 0; //< 停止していた時間
  int _pauseTime = 0; //< 一時中断していた時刻

  void _handle(Timer timer) {
    var playCount = DateTime.now().millisecondsSinceEpoch -
        _modelData.playStartTime +
        _stopTime;
    _modelData.playTime = playCount;
    _timeStreamController.add(playCount);
  }

  void startCount(void onData(int event)){
    _timeStreamController.add(_modelData.playTime);

    if (_timer == null || !_timer.isActive) {
      if ( _modelData.playStartTime == 0){
        _modelData.playStartTime = DateTime.now().millisecondsSinceEpoch;
      }

      _timer = Timer.periodic(const Duration(milliseconds: 10), _handle);
      if ( _timeStream == null) {
        _timeStream = _timeStreamController.stream.asBroadcastStream();
        _timeStreamSubscription = _timeStream.listen(onData,
            onDone: () {
              print("onDone");
            }, onError: (error) {
              print("onError:$error");
            });
      }
    }
  }

  void pauseCount() {
    if (_timer != null || _timer.isActive) {
      _pauseTime = DateTime.now().millisecondsSinceEpoch;
      _timeStreamSubscription?.pause();
    }
  }

  void resumeCount() {
    if (_timer == null || !_timer.isActive) {
      _stopTime += DateTime.now().millisecondsSinceEpoch - _pauseTime;
      _timer = Timer.periodic(const Duration(milliseconds: 10), _handle);
      _timeStreamSubscription?.resume();
    }
  }

  void stopCount() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _timer = null;
      _handle(null);
//      _timeStreamSubscription?.cancel();
    }
  }

  void resetCount() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _timer = null;
    }
    _modelData.playStartTime = 0;
    _stopTime = 0;
    _pauseTime = 0;
    _modelData.playTime = 0;
    _modelData.playStartTime = 0;
    _timeStreamController.add(0);
  }

//endregion

  void writeRecord() async
  {
    GameRecord gameRecord = GameRecord(
      question:_modelData.questionString,
        playDateTime: _modelData.playStartTime,
        gameClearTime: _modelData.playTime ,
        clearExpression: _capturedString,
    );

    await _dataStore.insertGameRecord(gameRecord);
  }

  Future<List<GameRecord>> recordList({GAME_RECORD_COLUMN orderBy = GAME_RECORD_COLUMN.QUESTION, bool ascending = true})
  {
    return  _dataStore.loadRecordData(orderBy: orderBy , ascending:ascending);
  }

  Future<bool> savePlayData()
  {
    return _dataStore.savePlayData(_modelData)..then((value){
      print("savePlayData done result:$value");
      _hasSavePlayData = value;
    });
  }

  Future<void> loadPlayData() async
  {
    if ( _hasSavePlayData == false ) {
      return;
    }
    return _dataStore.loadPlayData().then((value){
        print("GammeModle.dataStore.loadPlayData then ");
        _modelData.questionString = value["questionString"];
        _modelData.playTime = value["playTime"];
        _modelData.playStartTime = value["playStartTime"];
        _modelData.panelPosList = value["panelData"];
        print("GammeModle.dataStore.loadPlayData then. playTime: ${_modelData.playTime}");
        print("GammeModle.dataStore.loadPlayData then. playStartTime: ${_modelData.playStartTime}");
     });
  }

}