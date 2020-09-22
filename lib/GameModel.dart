import 'dart:ui'; // Rect
import 'dart:math' as math;

import 'package:tuple/tuple.dart';
import 'package:vector_math/vector_math.dart';

import 'package:tenpuzzle/strEval.dart';

enum PanelDataKind{
  NUMERIC,
  OPERATOR,
}


enum QuestionState{
  PREPARE,
  THINKING,
  CLEARED,
}

class PanelData {
  int id = 0;
  Rect rect;
  String title = "";
  bool selected = false;
  double ansDist = 0;
  PanelDataKind kind = PanelDataKind.NUMERIC;

  // ignore: non_constant_identifier_names
  static int ID_COUNTER = 1;

  PanelData()
  {
    id = ID_COUNTER++;
  }

}

class ModelData {

  int selectedIdx = -1;
  PanelData selectedPanel;

  List<PanelData>  panelPosList = [];
  static const double _PANEL_WIDTH = 50.0;
  static const double _PANEL_HEIGHT = 50.0;

  List<PanelData>  operatorPanelPosList = [];
  static const double OPERATOR_PANEL_WIDTH = 50.0;
  static const double OPERATOR_PANEL_HEIGHT = 50.0;

  var _random = new math.Random();

  double _screenWidth  = 0;
  double _screenHeight = 0;

  List<String> operatorString = [
    "+",
    "-",
    "*",
    "/",
    "(",
    ")",
  ];

  void initialize(double screenWidth , double screenHeight)
  {
    _screenWidth  = screenWidth;
    _screenHeight = screenHeight;
    // for ( int i = 0 ; i < 10 ; i++ ){
    //   PanelData panelData = PanelData();
    //   panelData.rect = Rect.fromLTWH((i.toDouble() * _PANEL_WIDTH) % (_PANEL_WIDTH * 3), (i ~/ 3).toDouble() * _PANEL_HEIGHT , _PANEL_WIDTH, _PANEL_HEIGHT);
    //   panelData.title = "$i";
    //   panelPosList.add(panelData);
    // }
    //
    // panelPosList.asMap().forEach((key, target) {
    //   print("idx:$key target:${target.title} ${target.rect}");
    // });

    double padding = 10;
    double paddingWidth = 30;
    double panelHeight = _PANEL_HEIGHT;
    double panelWidth = _PANEL_WIDTH;
    double validSize = screenHeight / operatorString.length;
    print("initialize validSize:$validSize");
    if ( panelHeight > validSize ){
      double tempPadding = validSize - panelHeight;
      if ( padding > tempPadding){
        padding = tempPadding;
      }
      panelHeight = validSize - padding;
      panelWidth = validSize - padding;

    }

    double operatorTotalHeight = (panelHeight + padding) * operatorString.length ;
    double operatorStartHeight = (screenHeight - operatorTotalHeight) / 2;
    print("initialize $_screenWidth x $_screenHeight operatorTotalHeight:$operatorTotalHeight operatorStartHeight:$operatorStartHeight");
    operatorPanelPosList.clear();

    for (int index = 0 ; index < operatorString.length ; index++){
      PanelData panelData = new PanelData();
      panelData.rect = Rect.fromLTWH( screenWidth - panelWidth - paddingWidth , operatorStartHeight + ( panelHeight + padding) * index , panelWidth, panelHeight);
      panelData.title = operatorString[index];
      operatorPanelPosList.add(panelData);
    }

  }

  void addNumericPanelForTitle()
  {
    panelPosList.clear();

    for ( int i = 0 ; i < 10 ; i++ ){
      PanelData panelData = PanelData();
      panelData.rect = Rect.fromLTWH((i.toDouble() * _PANEL_WIDTH) % (_PANEL_WIDTH * 3), (i ~/ 3).toDouble() * _PANEL_HEIGHT , _PANEL_WIDTH, _PANEL_HEIGHT);
      panelData.title = "$i";
      panelPosList.add(panelData);
    }

    panelPosList.asMap().forEach((key, target) {
      print("idx:$key target:${target.title} ${target.rect}");
    });
  }

  bool addNumericPanelForGame(String questionStr)
  {
    bool success = true;
    questionStr.runes.forEach((int rune) {
      var character = new String.fromCharCode(rune);
      try {
        int _ = int.parse(character);
      } catch (exception) {
        character = "x";
        success = false;
      }

      addNumericPanel(character);

      print(character);
    });

    return success;
  }

  void load()
  {

  }

  void save()
  {

  }

  PanelData addNumericPanel(String numStr)
  {
    PanelData panelData = PanelData();
    panelData.kind = PanelDataKind.NUMERIC;
    panelData.rect = Rect.fromLTWH( (_screenWidth / 4) + _random.nextDouble() * (_screenWidth / 2) , ( _screenHeight / 4) + _random.nextDouble() * (_screenHeight / 2)  , _PANEL_WIDTH, _PANEL_HEIGHT);
    panelData.title = numStr;
    panelPosList.add(panelData);
    return panelData;
  }

  PanelData addOperatorPanel(Offset offset , String operatorStr)
  {
    PanelData panelData = PanelData();
    panelData.kind = PanelDataKind.OPERATOR;
//    panelData.rect = Rect.fromLTWH( (_screenWidth / 2) + _random.nextDouble() * (_screenWidth / 4) , ( _screenHeight / 2) + _random.nextDouble() * (_screenHeight / 4)  , _PANEL_WIDTH, _PANEL_HEIGHT);
    panelData.rect = Rect.fromLTWH( offset.dx , offset.dy , _PANEL_WIDTH, _PANEL_HEIGHT);
    panelData.title = operatorStr;
    panelPosList.add(panelData);
    return panelData;
  }

  void clearAllPanel()
  {
    panelPosList.clear();
  }


  void setSelectedPanel(PanelData panelData)
  {
    print("setSelectedPanel:${panelData.title}");
    if ( panelPosList.remove(panelData) == false){
      print("can't  remove");
    }
    panelPosList.add(panelData);

    selectedIdx = panelPosList.length - 1;
    selectedPanel = panelData;
    selectedPanel.selected = true;
  }

  void clearOperator()
  {
    for (int i = panelPosList.length - 1 ; i >= 0 ; i-- ){
      PanelData panel = panelPosList[i];
      if ( panel.kind == PanelDataKind.OPERATOR) {
        panelPosList.removeAt(i);
      }
    }
  }

  void clearSelectedPanel() {
    panelPosList.asMap().forEach((key, target) {
      target.selected = false;
    });
  }


  bool _correct = false;

  get isCleared => _correct;

  set setCleared(bool value){
    _correct = value;
  }

}

///
class GameModel {

  double _dx = 0;
  double _dy = 0;

  ModelData _modelData = ModelData();

  bool visibleAnswerLine = false;
  Offset answerStart = new Offset(100 , 100);
  Offset answerEnd = new Offset(200 , 300);

  List<PanelData> get panelPosList => _modelData.panelPosList;
  List<PanelData> get operatorPosList => _modelData.operatorPanelPosList;

  String _capturedString = "nan";
  get capturedString => _capturedString;

  bool _validExpression = false;


  void initialize(double width , double height)
  {
    _modelData.initialize(width, height);
  }


  bool _dragging = false;

  bool get isDragging => _dragging;

  void dragStartAction(Offset position)
  {
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
      print("result:$_capturedString validExpression:$_validExpression");

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

  bool addNumericPanelForGame(String questionStr)
  {
    _modelData.addNumericPanelForGame(questionStr);
    return true;
  }

  bool checkAnswer()
  {
    if ( _validExpression == false ){
      return false;
    }

    double answer = calcString(capturedString);
    if ( answer != 10){
      return false;
    }
    return true;
  }


}