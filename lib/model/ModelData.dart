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
  int id = 0; /// 識別子
  Rect rect; /// 配置矩形
  String showStr = ""; /// 表示文字
  String calcStr = ""; /// 計算文字
  bool selected = false; /// 選択状態
  double ansDist = 0; /// 選択線からの距離
  PanelDataKind kind = PanelDataKind.NUMERIC; /// 種別
  bool contactEdge = false; /// 端に接している時 true 位置の補正時にこれ以上補正できない位置にある時に使う。

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

  int recordListOrderByColumn = 0; //< プレイ記録並び順
  bool recordListAscending = false; //< プレイ記録昇順

  List<PanelData>  panelPosList = [];
  static const double _PANEL_WIDTH = 48.0;
  static const double _PANEL_HEIGHT = 48.0;

  List<PanelData>  operatorPanelPosList = [];
  static const double OPERATOR_PANEL_WIDTH = 48.0;
  static const double OPERATOR_PANEL_HEIGHT = 48.0;

  PanelData _trashPanel;
  PanelData get trashPanel => _trashPanel;

  var _random = new math.Random();

  String questionString = "";

  double _screenWidth  = 0;
  double _screenHeight = 0;

  static const String MULTIPLE_SIGN = "×"; /// U+00D7

  List<String> operatorString = [
    "+",
    "-",
    MULTIPLE_SIGN,
    "/",
    "(",
    ")",
  ];

  static const String TRASH_STRING = "🗑";

  get  hadQuestionString => questionString.isNotEmpty;

  void initialize(double screenWidth , double screenHeight)
  {
    _screenWidth  = screenWidth;
    _screenHeight = screenHeight;

    createOperatorPanelTwoByThree(screenWidth, screenHeight);

    createTrash(screenWidth, screenHeight);
  }

  // void createOperatorPanelForVerticalLeft(double screenWidth, double screenHeight) {
  //   double paddingHeight = 10;
  //   double paddingWidth = 50;
  //   double panelHeight = _PANEL_HEIGHT;
  //   double panelWidth = _PANEL_WIDTH;
  //   double validSize = screenHeight / operatorString.length;
  //   print("initialize validSize:$validSize");
  //   // 画面サイズに対して演算子パネルのサイズを調整する。
  //   if ( panelHeight > validSize ){
  //     double tempPadding = validSize - panelHeight;
  //     if ( paddingHeight > tempPadding){
  //       paddingHeight = tempPadding;
  //     }
  //     panelHeight = validSize - paddingHeight;
  //     panelWidth = validSize - paddingHeight;
  //   }
  //
  //   double operatorTotalHeight = (panelHeight + paddingHeight) * operatorString.length ;
  //   double operatorStartHeight = (screenHeight - operatorTotalHeight) / 2;
  //   print("initialize $_screenWidth x $_screenHeight operatorTotalHeight:$operatorTotalHeight operatorStartHeight:$operatorStartHeight");
  //   operatorPanelPosList.clear();
  //
  //   for (int index = 0 ; index < operatorString.length ; index++){
  //     PanelData panelData = new PanelData();
  //     panelData.rect = Rect.fromLTWH( screenWidth - panelWidth - paddingWidth , operatorStartHeight + ( panelHeight + paddingHeight) * index , panelWidth, panelHeight);
  //     panelData.title = operatorString[index];
  //     operatorPanelPosList.add(panelData);
  //   }
  // }

  void createOperatorPanelTwoByThree(double screenWidth, double screenHeight) {
    final int operatorRowCount = 3;
    final int operatorColumnCount = 2;
    final double paddingHeight = 10;
    final double paddingWidth = 10;
    final double paddingWidthFromBorder = 30;
    final double panelHeight = _PANEL_HEIGHT;
    final double panelWidth = _PANEL_WIDTH;

    operatorPanelPosList.clear();

    double operatorStartHeight = (screenHeight // 画面縦幅
            - ((panelHeight * operatorRowCount) // 縦の段数分のサイズ合計
                  + (paddingHeight * (operatorRowCount - 1)) // 縦の段数に入るパディングのサイズ合計
              )
        ) / 2 ; // 値を2で割って中央寄せするときの開始位置(縦)とする。

    operatorString.asMap().forEach((int index, String value) {
      PanelData panelData = new PanelData();
      int rowLevel = index ~/ operatorColumnCount;
      int columnLevel = index % operatorColumnCount;

      double rowPos    =  (panelWidth + paddingWidth) * ( operatorColumnCount - columnLevel) ;
      double columnPos =  (panelHeight + paddingHeight) * rowLevel ;

      panelData.rect = Rect.fromLTWH(
          screenWidth - rowPos - paddingWidthFromBorder,
          operatorStartHeight + columnPos,
          panelWidth,
          panelHeight);

      if ( index - columnLevel == 1 ){
        operatorStartHeight += panelHeight + paddingHeight;
      }
      panelData.showStr = value;
      operatorPanelPosList.add(panelData);

    });
    // for (int index = 0 ; index < operatorString.length ; index++){
    //   PanelData panelData = new PanelData();
    //   int rowLevel = index ~/ operatorColumnCount;
    //   int columnLevel = index % operatorColumnCount;
    //
    //   double rowPos    =  (panelWidth + paddingWidth) * ( operatorColumnCount - columnLevel) ;
    //   double columnPos =  (panelHeight + paddingHeight) * rowLevel ;
    //
    //   panelData.rect = Rect.fromLTWH(
    //       screenWidth - rowPos - paddingWidthFromBorder,
    //       operatorStartHeight + columnPos,
    //       panelWidth,
    //       panelHeight);
    //
    //   if ( index - columnLevel == 1 ){
    //     operatorStartHeight += panelHeight + paddingHeight;
    //   }
    //   panelData.title = operatorString[index];
    //   operatorPanelPosList.add(panelData);
    // }
  }

  void createTrash(double screenWidth, double screenHeight)
  {
    const double paddingHeight = 20;
    final double panelTop  = screenHeight - _PANEL_HEIGHT - paddingHeight;
    final double panelLeft = (screenWidth - _PANEL_WIDTH) / 2;

    PanelData panelData = new PanelData();
    panelData.rect = Rect.fromLTWH( panelLeft , panelTop , _PANEL_WIDTH, _PANEL_HEIGHT);
    panelData.showStr = "🗑";

    _trashPanel = panelData;
  }


  // void createOperatorPanelForHorizontalBottom(double screenWidth, double screenHeight) {
  //   double paddingHeight = 20;
  //   double paddingWidth = 20;
  //   double panelHeight = _PANEL_HEIGHT;
  //   double panelWidth = _PANEL_WIDTH;
  //   double validSize = screenHeight / operatorString.length;
  //   print("initialize validSize:$validSize");
  //   // 画面サイズに対して演算子パネルのサイズを調整する。
  //   if ( panelWidth > validSize ){
  //     double tempPadding = validSize - panelHeight;
  //     if ( paddingWidth > tempPadding){
  //       paddingWidth = tempPadding;
  //     }
  //     panelHeight = validSize - paddingWidth;
  //     panelWidth = validSize - paddingWidth;
  //   }
  //
  //   double operatorTotalWidth = (panelWidth + paddingWidth) * operatorString.length - paddingWidth;
  //   double operatorStartWidth = (screenWidth - operatorTotalWidth) / 2;
  //   print("initialize $_screenWidth x $_screenHeight operatorTotalWidth:$operatorTotalWidth operatorStartWidth:$operatorStartWidth");
  //   operatorPanelPosList.clear();
  //
  //   for (int index = 0 ; index < operatorString.length ; index++){
  //     PanelData panelData = new PanelData();
  //     panelData.rect = Rect.fromLTWH( operatorStartWidth + ( panelWidth + paddingWidth) * index , screenHeight - panelHeight - paddingHeight , panelWidth, panelHeight);
  //     panelData.title = operatorString[index];
  //     operatorPanelPosList.add(panelData);
  //   }
  // }

  void addNumericPanelForTitle()
  {
    panelPosList.clear();

    for ( int i = 0 ; i < 10 ; i++ ){
      PanelData panelData = PanelData();
      panelData.rect = Rect.fromLTWH((i.toDouble() * _PANEL_WIDTH) % (_PANEL_WIDTH * 3), (i ~/ 3).toDouble() * _PANEL_HEIGHT , _PANEL_WIDTH, _PANEL_HEIGHT);
      panelData.showStr = "$i";
      panelPosList.add(panelData);
    }

    panelPosList.asMap().forEach((key, target) {
      print("idx:$key target:${target.showStr} ${target.rect}");
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
    panelData.showStr = numStr;
    panelData.calcStr = showStrToCalcStr(numStr);
    panelPosList.add(panelData);
    return panelData;
  }

  PanelData addOperatorPanel(Offset offset , String operatorStr)
  {
    PanelData panelData = PanelData();
    panelData.kind = PanelDataKind.OPERATOR;
    panelData.rect = Rect.fromLTWH( offset.dx , offset.dy , _PANEL_WIDTH, _PANEL_HEIGHT);
    panelData.showStr = operatorStr;
    panelData.calcStr = showStrToCalcStr(operatorStr);
    panelPosList.add(panelData);
    return panelData;
  }

  static String showStrToCalcStr(String showStr)
  {
    String calcStr = showStr.replaceAll(MULTIPLE_SIGN,"*");
    return calcStr;
  }

  static String calcStrToShowStr(String calcStr)
  {
    String showStr = calcStr.replaceAll("*", MULTIPLE_SIGN);
    return showStr;
  }

  void clearAllPanel()
  {
    questionString = "";
    panelPosList.clear();
  }

  void setDraggingPanel(PanelData panelData)
  {
    print("setSelectedPanel:${panelData.showStr}");
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

  void removeOperatorPanel(PanelData operatorPanel)
  {
    if ( operatorPanel.kind != PanelDataKind.OPERATOR){
      return;
    }
    bool removed = panelPosList.remove(operatorPanel);
    if ( removed == false){
      print("warning: A deletion order was issued for the unknown panel.");
    }
  }

  void clearSelectedPanel() {
    panelPosList.asMap().forEach((key, target) {
      target.selected = false;
    });
  }

  /// パネルの位置調整処理
  void adjustmentPanel(final PanelData pivotPanel , void adjustEvent(PanelData panelData))
  {
    print("adjustmentPanel start:$pivotPanel");
    List<PanelData> movedPanelList = _adjustmentPanel(pivotPanel, adjustEvent);
    print("adjustmentPanel first movedPanelList.length:${movedPanelList.length}");
    if ( movedPanelList.isNotEmpty ) {
      _adjustmentPanelLoop(movedPanelList , adjustEvent);
    }

    // 処理中にセットされた画面端に接したフラグを元に戻す。
    panelPosList.asMap().forEach((key, target) {
      target.contactEdge = false;
    });
    print("adjustmentPanel end:$pivotPanel");
  }

  /// 位置調整処理のメインループ
  void _adjustmentPanelLoop(List<PanelData> movedPanelList, void adjustEvent(PanelData panelData)) {
    List<PanelData> nextCheckPanelList = [];
    if ( movedPanelList.isNotEmpty ){
      movedPanelList.asMap().forEach((key, target) {
        print("_adjustmentPanelLoop title:${target.showStr}");

        List<PanelData> adjustResult =  _adjustmentPanel(target, adjustEvent);
        print("_adjustmentPanelLoop adjustResult.length:${adjustResult.length}");
        nextCheckPanelList.addAll(adjustResult);
      });
    }

    print("nextCheckPanelList.length:${nextCheckPanelList.length}");

    if ( nextCheckPanelList.isNotEmpty ) {
      // 重なり合う状態のものがまだある。
      // 画面が狭くて重なり具合を完結できない場合の条件をチェックする。
      // 横に並んだ後のサイズの合計が画面幅を超える場合、それ以上の移動をしない
      bool margins = _adjustmentCheckMargins(nextCheckPanelList);
      if (margins) {
        _adjustmentPanelLoop(nextCheckPanelList, adjustEvent);
      }
    }
  }

  /// 位置調整するための余白があるかを確認する。
  bool _adjustmentCheckMargins(List<PanelData> nextCheckPanelList) {
    bool margins  = false;

    double minX = this._screenWidth;
    double maxX = 0;

    panelPosList.asMap().forEach((key, target) {
      if ( target.rect.left < minX){
        minX = target.rect.left;
      }

      if ( target.rect.left > maxX){
        maxX = target.rect.left;
      }

    });

    if ( minX > 0 || maxX < this._screenWidth){
      // まだ移動余地があるので、続ける。
      margins = true;
    }

    print("_adjustmentCheckMargins minX:$minX maxX:$maxX margins:$margins");

    return margins;
  }

  /// 指定したパネルと重なっていパネルの位置を調整する。
  /// 移動したパネルを返す。
  List<PanelData> _adjustmentPanel(final PanelData pivotPanel, void adjustEvent(PanelData panelData))
  {
    print("_adjustmentPanel pivotPanel:${pivotPanel.showStr} rect:${pivotPanel.rect} width:${pivotPanel.rect.width} height:${pivotPanel.rect.height}");
    final Offset pivotPanelCenter = pivotPanel.rect.center;
    final Offset baseLine = new Offset( pivotPanelCenter.dx + 1 , 0);

    List<PanelData> overlappedPanelList = [];
    panelPosList.asMap().forEach((key, target) {

      if ( target.contactEdge ){
        /* この調整処理中に。画面の端に一度到達したパネルなので。これ以上移動対象としない */
        print("contactEdge idx:$key target:${target.showStr}");
        return;
      }

      /* 画面外に出た場合は、座標を画面内に納める */
      adjustInsideScreen(pivotPanel);

      /* パネル間の重なりがなければ、処理しない   */
      // ignore: unrelated_type_equality_checks
      if (identical(target , pivotPanel) == true){
        print("identical idx:$key target:${target.showStr}");
        return;
      }
      Rect intersectRect = pivotPanel.rect.intersect(target.rect);
      if ( intersectRect.width <= 0 || intersectRect.height <= 0){
        // 重なっていないので、処理しない。
        print("_adjustmentPanel out range idx:$key target:${target.showStr} target.rect:${target.rect} intersect:$intersectRect width:${intersectRect.width} height:${intersectRect.height}");
        target.key = UniqueKey();
        return;
      }

      // cosとって方向をみる。>0 が右　<0が左 0の場合一旦右に置く
      Offset vector = target.rect.center - pivotPanelCenter;
      double innerProduct = (baseLine.dx * vector.dx) + (baseLine.dy * vector.dy);

      double newLeft = 0;
      if ( innerProduct > 0 ){
        print("_adjustmentPanel  right  range idx:$key target:${target.showStr} target.rect:${target.rect} intersect:$intersectRect width:${intersectRect.width} height:${intersectRect.height}");
        // 右
        newLeft = pivotPanel.rect.left + pivotPanel.rect.width;
      }else if ( innerProduct < 0 ){
        print("_adjustmentPanel  left   range idx:$key target:${target.showStr} target.rect:${target.rect} intersect:$intersectRect width:${intersectRect.width} height:${intersectRect.height}");
        // 左
        newLeft = pivotPanel.rect.left - target.rect.width;
      }else{
        print("_adjustmentPanel (right)  range idx:$key target:${target.showStr} target.rect:${target.rect} intersect:$intersectRect width:${intersectRect.width} height:${intersectRect.height}");
        // 垂直方向の場合、一旦右に置く
        newLeft = pivotPanel.rect.left + pivotPanel.rect.width;
      }

      bool contacted = false;
      /* 画面外に出た場合は、座標を画面内に納める */
      if ( (newLeft + pivotPanel.rect.width) > this._screenWidth){
        newLeft = this._screenWidth - pivotPanel.rect.width;
        contacted = true;
      }
      if ( newLeft < 0){
        newLeft = 0;
        contacted = true;
      }

      // 対象パネル
      if ( contacted == false) {
        overlappedPanelList.add(target);
      }

      Rect newRect = Rect.fromLTWH(newLeft , target.rect.top , target.rect.width , target.rect.height);
      target.rect = newRect;
      target.contactEdge = contacted;

      adjustEvent(target);
    });
    return overlappedPanelList;
  }

  void adjustInsideScreen(PanelData pivotPanel) {
    if ( pivotPanel.rect.right > this._screenWidth){
      pivotPanel.rect = Rect.fromLTWH( this._screenWidth - pivotPanel.rect.width, pivotPanel.rect.top, pivotPanel.rect.width, pivotPanel.rect.height);
    }
    if ( pivotPanel.rect.left < 0){
      pivotPanel.rect = Rect.fromLTWH( 0, pivotPanel.rect.top, pivotPanel.rect.width, pivotPanel.rect.height);
    }
    if ( pivotPanel.rect.bottom > this._screenHeight){
      pivotPanel.rect = Rect.fromLTWH(pivotPanel.rect.left, this._screenHeight - pivotPanel.rect.height, pivotPanel.rect.width, pivotPanel.rect.height);
    }
    if ( pivotPanel.rect.top < 0){
      pivotPanel.rect = Rect.fromLTWH(pivotPanel.rect.left, 0, pivotPanel.rect.width, pivotPanel.rect.height);
    }
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
