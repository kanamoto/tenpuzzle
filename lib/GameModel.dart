import 'dart:ui'; // Rect

import 'package:vector_math/vector_math.dart';

import 'dart:math' as math;

enum PanelDataKind{
  NUMERIC,
  OPERATOR,
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

  static const double OPERATOR_PANEL_WIDTH = 50.0;
  static const double OPERATOR_PANEL_HEIGHT = 50.0;

  var _random = new math.Random();

  double _screenWidth  = 0;
  double _screenHeight = 0;

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
        int num = int.parse(character);
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

  void addNumericPanel(String numStr)
  {
    PanelData panelData = PanelData();
    panelData.kind = PanelDataKind.NUMERIC;
    panelData.rect = Rect.fromLTWH( (_screenWidth / 2) + _random.nextDouble() * (_screenWidth / 4) , ( _screenHeight / 2) + _random.nextDouble() * (_screenHeight / 4)  , _PANEL_WIDTH, _PANEL_HEIGHT);
    panelData.title = numStr;
    panelPosList.add(panelData);
  }

  void addOperatorPanel(String operatorStr)
  {
    PanelData panelData = PanelData();
    panelData.kind = PanelDataKind.OPERATOR;
    panelData.rect = Rect.fromLTWH( (_screenWidth / 2) + _random.nextDouble() * (_screenWidth / 4) , ( _screenHeight / 2) + _random.nextDouble() * (_screenHeight / 4)  , _PANEL_WIDTH, _PANEL_HEIGHT);
    panelData.title = operatorStr;
    panelPosList.add(panelData);
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

  void clearPanelSelected() {
    panelPosList.asMap().forEach((key, target) {
      target.selected = false;
    });
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

  String _capturedString = "nan";
  get capturedString => _capturedString;

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

    _modelData.clearPanelSelected();

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

      visibleAnswerLine = true;
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
      visibleAnswerLine = true;
      answerEnd = new Offset(position.dx , position.dy);
      _modelData.clearPanelSelected();
      _capturedString = captureAnswerLine();
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
      /* TODO:判定処理 */
      String result = captureAnswerLine();
      print("result:$result");

      _modelData.clearPanelSelected();
    }else{
      _modelData.selectedIdx = -1;
      _modelData.selectedPanel.selected = false;
      _modelData.selectedPanel = null;
    }
  }

  String captureAnswerLine()
  {
    Vector3 ansP1 = new Vector3( answerStart.dx, answerStart.dy, 0.0);
    Vector3 ansP2 = new Vector3( answerEnd.dx  , answerEnd.dy, 0.0);

    //bool allNumericSelcted = false;

    Vector3 ansVect =  ansP2 - ansP1;

    if ( ansVect == Vector3.zero() ){
      return "";
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
    return "";
  }


  List<PanelData> panelSortArray = List();
  panelSortArray.addAll(ansPanelAry);

  panelSortArray.sort((a , b) => (a.ansDist - b.ansDist).sign.round()); //.sort((a,b) => a .id.compareTo(b.id));

  // // 一番小さい距離から順に、文字列を得ます。
  // while ([ansPanelAry count] != 0){
  //   Panel* ansTargetPanel = [ansPanelAry objectAtIndex:0];
  //   for (int i = 1 ; i < [ansPanelAry count] ; i++){
  //     Panel* vsPanel = [ansPanelAry objectAtIndex:i];
  //     if (ansTargetPanel.ansDist > vsPanel.ansDist){
  //       ansTargetPanel = vsPanel;
  //     }
  //   }
  //   [ansString appendString:ansTargetPanel.charcter];
  //   [ansPanelAry removeObject:ansTargetPanel];
  //
  //   [panelSortArray addObject:ansTargetPanel];
  // }

  StringBuffer ansString = StringBuffer("");

  panelSortArray.forEach((element) {ansString.write( element.title);});

  // int numCnt = 0;
  // int numContCnt = 0;
  // for (int i = 0 ; i < panelSortArray.length ; i++){
  //   PanelData panel =  panelSortArray[i];
  //   if (panel.kind == 0){
  //     if (numContCnt != 0){
  //       break;
  //     }
  //     numCnt++;
  //     numContCnt++;
  //   }else{
  //     numContCnt = 0;
  //   }
  // }
  // if (numCnt == 4){
  //   // 全ての数値を正しく(2つ以上つながることなく)選択しています。
  //   allNumericSelcted = true;
  // }
    String result = ansString.toString();
    return result;
  }


  void addOperator(String operatorStr)
  {
    _modelData.addOperatorPanel(operatorStr);
  }

  void clearOperator()
  {
    _modelData.clearOperator();
  }

  bool addNumericPanelForGame(String questionStr)
  {
    _modelData.addNumericPanelForGame(questionStr);
  }

}