import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';
import 'package:vector_math/vector_math.dart';

import 'package:tenpuzzle/peripheral/strEval.dart';
import 'package:tenpuzzle/peripheral/Log.dart';

import 'package:tenpuzzle/model/ModelData.dart';
import 'package:tenpuzzle/model/QuestionData.dart';

import 'package:tenpuzzle/model/DataStore.dart';

///
class GameModel{

  double _dx = 0;
  double _dy = 0;

  final ModelData _modelData = ModelData();

  final DataStore _dataStore = DataStore();

  bool visibleAnswerLine = false;
  Offset answerStart = new Offset(100 , 100);
  Offset answerEnd = new Offset(200 , 300);

  List<PanelData> get panelPosList => _modelData.panelPosList;
  List<PanelData> get operatorPosList => _modelData.operatorPanelPosList;

  PanelData get trashPanel => _modelData.trashPanel;

  String _calculateString = "?";
  get calculateString => _calculateString;

  String _showString = "?";
  get showString => _showString;

  double _answerValue = 0;
  get answerValue => _answerValue;

  bool _validExpression = false;
  get validExpression => _validExpression;

  bool _isDataLoaded = false;

  bool _hasSavePlayData = false;
  get hadSavePlayData => _hasSavePlayData;

  get hadPlayData => _modelData.hadQuestionString;

  get isDataLoaded => _isDataLoaded;

  get recordListOrderByColumn => _modelData.recordListOrderByColumn;
  get recordListAscending => _modelData.recordListAscending;

  get playTime => _modelData.playTime;

  Future<void> initialize(/*void onInitialized(GameModel gameModel)*/) async
  {
    Log.print("GameModel initialize start");

    await _dataStore.initializeDB();

    _adjustPanelStream = _adjustStreamController.stream.asBroadcastStream();
    _adjustPanelStreamSubscription = _adjustPanelStream.listen((PanelData panelData){}); // FIXME: これ必要?

    Log.print("GameModel initialize end _adjustPanelStream:$_adjustPanelStream");
  }

  Future loadPlayData(void onLoaded(GameModel gameModel)) async {

    await _dataStore.loadPlayData(_modelData).then((value) {

      if ( _modelData.screenWidth != _modelData.oldScreenWidth ||
          _modelData.screenHeight != _modelData.oldScreenHeight  ){
        _modelData.adjustPanelPosition(_modelData.oldScreenWidth , _modelData.oldScreenHeight, _modelData.screenWidth , _modelData.screenHeight);
      }

      _hasSavePlayData = _modelData.panelPosList.length > 0;
      _isDataLoaded = true;
      onLoaded(this);
    });

  }

  void initializeScreenSize(double width , double height)
  {
    _modelData.initialize(width, height);
    _modelData.createOperationPanels(width, height);
  }

  void adjustPanelPositionIfNeeded(double newWidth , double newHeight)
  {
    _modelData.adjustPanelPositionIfNeeded(newWidth, newHeight);
  }

  bool _dragging = false;

  bool get isDragging => _dragging;

  PanelData? _candidateOperatorPanelData;

  void startDragAction(Offset position)
  {
    if ( _modelData.hadQuestionString == false ){
      return;
    }

    _dragging = true;
    _dx = position.dx;
    _dy = position.dy;

    Log.print("dragStartAction");
    _modelData.selectedIdx = -1;
    int selectedIdx = -1;
    PanelData? selectedRect;

    _modelData.clearSelectedPanel();

    for ( int idx = 0 ; idx < _modelData.panelPosList.length ; idx++ ){
      PanelData target = _modelData.panelPosList[idx];

      if ( target.rect.contains(position) ){
        selectedRect = target;
        selectedIdx = idx;

        updateAllPanelKey();

        Log.print("[selected] idx:$idx target:${target.showStr} ${target.rect} position:$position");
        break;
      }else {
        Log.print("           idx:$idx target:${target.showStr} ${target.rect} position:$position");
      }
    }

    if ( selectedIdx == -1) {
      /* どのパネルでもない */
      Log.print("Long tap empty area.");

      /* 演算子を押しているか確認する */
      for ( int idx = 0 ; idx < _modelData.operatorPanelPosList.length ; idx++ ){

        PanelData target = _modelData.operatorPanelPosList[idx];
        if ( target.rect.contains(position) ){
          _candidateOperatorPanelData = target;
          break;
        }
      }

    }else{
      if ( selectedRect != null){
        _modelData.setDraggingPanel(selectedRect);
      }
    }
  }

  /// z-indexが変化するときのアニメーションを抑制するために、keyを更新する(Widgetの連続性が切られるのでアニメーションしなくなる)
  void updateAllPanelKey()
  {
    _modelData.panelPosList.forEach((element) { element.key = UniqueKey();});
  }

  void dragAction(Offset position)
  {
//   print("dragAction");
    if ( _modelData.hadQuestionString == false ){
//      print("dragAction return");
      return;
    }

//    print("dragAction _selectedIdx:${_modelData.selectedIdx} position:$position");

    if (_modelData.selectedIdx == -1){
      if ( _candidateOperatorPanelData != null) {
        if ( _candidateOperatorPanelData?.rect.contains(position) == false) {
          Log.print("_candidateOperatorPanelData:${_candidateOperatorPanelData?.showStr}");
          addOperatorWithDrag(position, _candidateOperatorPanelData!.showStr);
          _candidateOperatorPanelData = null;
        }
      }

      // visibleAnswerLine = true;
      // answerEnd = new Offset(position.dx , position.dy);
      // _modelData.clearSelectedPanel();
      // _capturedString = captureAnswerLine().item1;
      // updateAnswerString(_capturedString , _validExpression);
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

  // void updateAnswerString(String formulaStr , bool validExpression) {
  //   _answerValue = calcString(formulaStr);
  //   if ( _answerValue.isNaN || _answerValue.isInfinite || validExpression == false) {
  //     _answerString = "?";
  //   }else{
  //     _answerString = _answerValue.toString();
  //   }
  // }

  void endDragAction(Offset offset) {
    Log.print("dragEndAction");

    if ( _dragging == false ){
      return;
    }
    if ( _modelData.hadQuestionString == false ){
      return;
    }

    _dragging = false;
    // if (_modelData.selectedIdx == -1){
    //   visibleAnswerLine = false;
    //   answerEnd = new Offset(offset.dx , offset.dy);
    //   /* 判定処理 */
    //   var result = captureAnswerLine();
    //   _capturedString = result.item1;
    //   _validExpression = result.item2;
    //   updateAnswerString(_capturedString , _validExpression);
    //   //print("result:$_capturedString validExpression:$_validExpression");
    //
    //   _modelData.clearSelectedPanel();
    //
    // }else{

    _candidateOperatorPanelData = null;

    if (_modelData.selectedPanel != null){
      if ( _trashCheck(_modelData.trashPanel, _modelData.selectedPanel!) == true){
        _modelData.removeOperatorPanel(_modelData.selectedPanel!);
      }

      // _modelData.adjustmentPanelPosition(_modelData.selectedPanel);

      _modelData.adjustmentPanel(_modelData.selectedPanel! , (PanelData panelData){
        _adjustStreamController.sink.add(panelData);
      });

      _modelData.clearDraggingPanel();
    }
  }


  bool _trashCheck(PanelData trashPanel , PanelData target )
  {
    Rect intersectRect = trashPanel.rect.intersect(target.rect);
    if ( intersectRect.width < 0 || intersectRect.height < 0){
      return false;
    }
    return true;
  }

  @Deprecated("old style game rule")
  Tuple2<String, bool> captureAnswerLine()
  {
    Vector3 ansP1 = new Vector3( answerStart.dx, answerStart.dy, 0.0);
    Vector3 ansP2 = new Vector3( answerEnd.dx  , answerEnd.dy, 0.0);

    bool allNumericSelected = false;

    Vector3 ansVector =  ansP2 - ansP1;

    if ( ansVector == Vector3.zero() ){
      return Tuple2<String , bool>("" , false);
    }
    Vector3	ansVectorUnit = ansVector.normalized();
    double ansLineLen =  ansVector.length;

    List<PanelData> ansPanelAry = [];


    // パネル毎の距離を出します。
    for (int i = 0 ; i < panelPosList.length ; i++){
      PanelData panel = panelPosList[i];

      double widthHalf  = panel.rect.width / 2;
      //double heightHalf = panel.rect.height / 2;


      Vector3	panelPosVector =  new Vector3( panel.rect.center.dx , panel.rect.center.dy , 0.0);//   [Vector3D createWithX:panel.position.x + 24 Y:panel.position.y + 24 Z:0];
      Vector3	panelVector    =  panelPosVector - ansP1;

      double andDotPanel = ansVector.dot(panelVector);
      if ( andDotPanel <=  0){
        // 向きが違う
//        print("panel:${panel.title} X ansLineLen.dot(onLineDist) $andDotPanel ");
        continue;
      }

      // 垂線との交点が、線上にない場合は違います。
      double onLineDist =  panelVector.dot(ansVectorUnit);
      if (ansLineLen < onLineDist){
//        print("panel:${panel.title} X ansLineLen < onLineDist $ansLineLen < $onLineDist");
        continue;
      }

      // 線とパネルの中央点との垂線交点です。
      Vector3 ansPanelCrossVector = ansVectorUnit * onLineDist;// [ansVectorUnit mul:onLineDist];

      // 線からパネルの幅半分以上離れている場合は無視します。
      double crossDist =  (panelVector - ansPanelCrossVector).length;//   [[panelVector sub:ansPanelCrossVector] norm];
      if (crossDist > widthHalf){
//        print("panel:${panel.title} X crossDist:$crossDist > $widthHalf ");
        continue;
      }

//      print("panel:${panel.title} SELECTED ansLineLen  onLineDist $ansLineLen , $onLineDist");

      panel.ansDist = onLineDist;
      panel.selected = true;
      ansPanelAry.add(panel);
    }

    if ( ansPanelAry.length == 0){
      return Tuple2<String , bool>("" , false);
    }

    List<PanelData> panelSortArray = [];
    panelSortArray.addAll(ansPanelAry);

    // 一番小さい距離から順に、文字列を得ます。
    panelSortArray.sort((a , b) => (a.ansDist - b.ansDist).sign.round()); //.sort((a,b) => a .id.compareTo(b.id));

    // 選択した文字列を連結して式文字列とします。
    StringBuffer ansString = StringBuffer("");
    panelSortArray.forEach((element) {ansString.write( element.showStr);});

    // 式文字列が正しく作らせれているか検査します。ここでは、数値が一つずつ選ばれてる事を確認します。
    allNumericSelected = checkValidFormula(panelSortArray);

    var result = Tuple2<String , bool>(ansString.toString() , allNumericSelected);
    return result;
  }

  bool checkValidFormula(List<PanelData> panelSortArray) {
    bool result = false;
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
      result = true;
    }
    return result;
  }


  void newGame()
  {
    resetGame();
    String questionString = QuestionData.getDataAtRandom();
//    String questionString = QuestionData.getDataForDemo(); // for Test
    Log.print("questionString:$questionString");
    _modelData.addNumericPanelForGame(questionString);
  }

  /// ゲーム状態をリセットする
  void resetGame(){
    _resetCount();

    _clearAllPanel();
  }

  /// DBからセーブデータを削除する
  void removeSaveData(){
    _dataStore.clearPlayData();
    _hasSavePlayData = false;
    _isDataLoaded = false;
  }

  /// ゲームの状態をリセットして、保存データも消す
  void clearGame(){
    resetGame();
    removeSaveData();
  }

  void addOperatorWithDrag(Offset offset  , String operatorStr)
  {
    Offset newPosition = Offset(offset.dx -  ModelData.OPERATOR_PANEL_WIDTH / 2 , offset.dy -  ModelData.OPERATOR_PANEL_HEIGHT / 2 );

    PanelData panelData = _modelData.addOperatorPanel(newPosition , operatorStr);

    _modelData.setDraggingPanel(panelData);

    _dragging = true;
    _dx = offset.dx;
    _dy = offset.dy;

  }

  void addOperator(Offset offset , String operatorStr)
  {
    Offset newPosition = Offset(offset.dx -  ModelData.OPERATOR_PANEL_WIDTH / 2 , offset.dy -  ModelData.OPERATOR_PANEL_HEIGHT / 2 );
    PanelData addOperatorPanel = _modelData.addOperatorPanel(newPosition , operatorStr);

    _modelData.adjustmentPanel(addOperatorPanel, (PanelData panelData){
      _adjustStreamController.sink.add(panelData);
    });
  }

  void clearOperator()
  {
    _modelData.clearOperator();
    _calculateString = "";
    _showString = "";
//    _answerString = "";
    _validExpression = false;
  }

  void _clearAllPanel()
  {
    _modelData.clearAllPanel();
    _calculateString = "";
    _showString = "";
//    _answerString = "";
    _validExpression = false;
  }

  bool checkAnswer(void clearedProcess())
  {
    String checkString = "";
    String showString = "";
    List<PanelData> sortedPanelList = _modelData.takeFormulaListFromPanel();

    sortedPanelList.forEach((element) {
      checkString += element.calcStr;
      showString += element.showStr;
    });
    _calculateString = checkString;
    _showString = showString;

// print("checkAnswer _calculateString:$_calculateString");
// print("checkAnswer _showString:$_showString");
// print("checkAnswer calc:${calcString(checkString)}");

    _validExpression = checkValidFormula(sortedPanelList);
    _answerValue = calcString(_calculateString);
//updateAnswerString(_calculateString , validExpression);
    if ( _validExpression == false ){
//      print("checkAnswer validExpression == false");
      return false;
    }

    double answer = calcString(checkString);
    if ( answer != 10){
//      print("checkAnswer answer != 10 ($answer)");
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
  Stream<int>?  _timeStream;
  get timeStream => _timeStream;

  StreamController<PanelData> _adjustStreamController = new StreamController<PanelData>();
  late Stream<PanelData> _adjustPanelStream;
  get adjustPanelStream => _adjustPanelStream;
  late StreamSubscription<PanelData> _adjustPanelStreamSubscription;

  get adjustStreamController => _adjustStreamController;

  void setAdjustStreamListener(void onData(PanelData panelData)){
    _adjustStreamController.stream.listen(onData);
  }

  /// When finish running timer, it need to dispose.
  Future<void> dispose() async {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }

    await _timeStreamController.close();

    await _adjustPanelStreamSubscription.cancel();
    await _adjustStreamController.close();
  }

  Timer? _timer;
  int _stopTime = 0; //< 停止していた時間
  int _pauseTime = 0; //< 一時中断していた時刻

  void _handle(Timer? timer) {
    var playCount = DateTime.now().millisecondsSinceEpoch -
        _modelData.playStartTime +
        _stopTime;
    if ( playCount < 0 ){
      playCount = 0;
    }
    _modelData.playTime = playCount;
    _timeStreamController.add(playCount);
  }

  void startCount(void onData(int event)){
    _timeStreamController.add(_modelData.playTime);

    if (_timer == null || !_timer!.isActive) {
      if ( _modelData.playStartTime == 0){
        _modelData.playStartTime = DateTime.now().millisecondsSinceEpoch;
      }

      _timer = Timer.periodic(const Duration(milliseconds: 10), _handle);
      if ( _timeStream == null) {
        _timeStream = _timeStreamController.stream.asBroadcastStream();
      }
    }
  }

  void pauseCount() {
    if (_timer != null || _timer!.isActive) {
      _pauseTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  void resumeCount() {
    if (_timer == null || !_timer!.isActive) {
      _stopTime += DateTime.now().millisecondsSinceEpoch - _pauseTime;
      _timer = Timer.periodic(const Duration(milliseconds: 10), _handle);
    }
  }

  void stopCount() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
      _handle(null);
    }
  }

  void _resetCount() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
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
        clearExpression: _calculateString,
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
      Log.print("savePlayData done result:$value");
      _hasSavePlayData = value;
    });
  }

  Future<bool> saveRecordSettingData({int orderByColumn = 0, bool ascending = false}) async
  {
    _modelData.recordListOrderByColumn = orderByColumn;
    _modelData.recordListAscending = ascending;
    return _dataStore.saveRecordSettingData(_modelData);
  }
}