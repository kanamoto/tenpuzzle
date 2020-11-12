//import 'dart:async';
import 'dart:ui'; // Rect
import 'dart:math' as math;

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

  int playTime = 0; //< プレイ時間(ms)
  int playStartTime = 0; //< プレイ開始時間(ms) from UNIX EPOCH

  List<PanelData>  panelPosList = [];
  static const double _PANEL_WIDTH = 48.0;
  static const double _PANEL_HEIGHT = 48.0;

  List<PanelData>  operatorPanelPosList = [];
  static const double OPERATOR_PANEL_WIDTH = 48.0;
  static const double OPERATOR_PANEL_HEIGHT = 48.0;

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

  // void load()
  // {
  //
  // }
  //
  // void save()
  // {
  //
  // }

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
