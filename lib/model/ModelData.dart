//import 'dart:async';
import 'dart:ui'; // Rect
import 'dart:math' as math;

import 'package:flutter/material.dart';

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

  Key key; /* AnimatedPositionで更新対象としたくないときにキーを更新する。*/

  PanelData()
  {
    id = ID_COUNTER++;
    key = null;
  }

}

class ModelData {

  int selectedIdx = -1;
  PanelData selectedPanel;

  int playTime = 0; //< プレイ時間(ms)
  int playStartTime = 0; //< プレイ開始時間(ms) from UNIX EPOCH

  List<PanelData>  panelPosList = [];
  static const double _PANEL_WIDTH = 48.0;
  static const double _PANEL_HEIGHT = 48.0;

  List<PanelData>  operatorPanelPosList = [];
  static const double OPERATOR_PANEL_WIDTH = 48.0;
  static const double OPERATOR_PANEL_HEIGHT = 48.0;

  var _random = new math.Random();

  String questionString = "";

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

  get  hadQuestionString => questionString.isNotEmpty;

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

    double paddingHeight = 10;
    double paddingWidth = 50;
    double panelHeight = _PANEL_HEIGHT;
    double panelWidth = _PANEL_WIDTH;
    double validSize = screenHeight / operatorString.length;
    print("initialize validSize:$validSize");
    if ( panelHeight > validSize ){
      double tempPadding = validSize - panelHeight;
      if ( paddingHeight > tempPadding){
        paddingHeight = tempPadding;
      }
      panelHeight = validSize - paddingHeight;
      panelWidth = validSize - paddingHeight;

    }

    double operatorTotalHeight = (panelHeight + paddingHeight) * operatorString.length ;
    double operatorStartHeight = (screenHeight - operatorTotalHeight) / 2;
    print("initialize $_screenWidth x $_screenHeight operatorTotalHeight:$operatorTotalHeight operatorStartHeight:$operatorStartHeight");
    operatorPanelPosList.clear();

    for (int index = 0 ; index < operatorString.length ; index++){
      PanelData panelData = new PanelData();
      panelData.rect = Rect.fromLTWH( screenWidth - panelWidth - paddingWidth , operatorStartHeight + ( panelHeight + paddingHeight) * index , panelWidth, panelHeight);
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
    this.questionString = questionStr;
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
    questionString = "";
    panelPosList.clear();
  }


  void setDraggingPanel(PanelData panelData)
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

  void clearDraggingPanel()
  {
    selectedIdx = -1;
    selectedPanel.selected = false;
    selectedPanel = null;
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

  void adjustmentPanelPosition(final PanelData pivotPanel)
  {
    final Offset pivotPanelCenter = pivotPanel.rect.center;
    final Offset baseLine = new Offset( pivotPanelCenter.dx + 1 , 0);

    // パネルの左と右に距離順に分ける
    // パネルが重ならないように位置を調整する。
    // パネルが重なっていないものは移動しない。
    // はみ出たパネルがある場合は、画面内に戻す。

    /* 動かしたパネルと、他の各パネルとの重なり具合を調整する */
    // List<SortedPanelData>  sortedPanelList = [];
    panelPosList.asMap().forEach((key, target) {
      /* パネル間の重なりがなければ、処理しない   */
      // ignore: unrelated_type_equality_checks
      if (identical(target , pivotPanel) == true){
        return;
      }
      Rect intersectRect = pivotPanel.rect.intersect(target.rect);
      if ( intersectRect.width < 0 || intersectRect.height < 0){
        print("out range idx:$key target:${target.title} intersect:$intersectRect");
        target.key = UniqueKey();
        return;
      }

      // cosとって方向をみる。>0 が右　<0が左 0の場合一旦右に置く
      Offset vector = target.rect.center - pivotPanelCenter;
      double innerProduct = (baseLine.dx * vector.dx) + (baseLine.dy * vector.dy);

      double newLeft = 0;
      if ( innerProduct > 0 ){
        // 右
        newLeft = pivotPanel.rect.left + pivotPanel.rect.width;
      }else if ( innerProduct < 0 ){
        // 左
        newLeft = pivotPanel.rect.left - target.rect.width;
      }else{
        // 垂直方向
        newLeft = pivotPanel.rect.left;
      }
      /* 画面外に出た場合は、座標を画面内に納める */
      if ( newLeft > this._screenWidth){
        newLeft = this._screenWidth - pivotPanel.rect.width;
      }
      if ( newLeft < 0){
        newLeft = 0;
      }

      Rect newRect = Rect.fromLTWH(newLeft , target.rect.top , target.rect.width , target.rect.height);
      target.rect = newRect;

      // print("idx:$key target:${sortedPanelData.panel.title} dist:${ sortedPanelData.distance}");
    });
  }

  /// パネルの並びから式を得る
  List<PanelData>  takeFormulaListFromPanel()
  {
    /* 左からパネルの位置を調査して、式文字列を作成する */
    List<PanelData>  sortedPanelList = [...panelPosList];
    sortedPanelList.sort((a,b) => a.rect.left.compareTo(b.rect.left));

    return sortedPanelList;
  }

}

class SortedPanelData {

  SortedPanelData(this.panel , this.vector);

  PanelData panel;
  Offset  vector;
  get distance => vector.distance;
}
