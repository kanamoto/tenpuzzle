
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tenpuzzle/model/ModelData.dart';
import 'package:tenpuzzle/widget/GamePanel.dart';

class OperatorPanel extends GamePanel {

  const OperatorPanel({Key key, panelData , expansionRate = 0.0}) : super(key:key , panelData:panelData, expansionRate:expansionRate );

  State<StatefulWidget> createState() => OperatorPanelState();
}



class OperatorPanelState extends GamePanelState {

  @override
  Color panelBorderColor(PanelData panelData)
  {
    return panelData.selected == true ? GamePanelState.DEFAULT_SELECTED_LINE_COLOR : Colors.white30;
  }

  @override
  Color panelBodyColor(PanelData panelData, double expansionRate)
  {
    return panelData.selected == true ? GamePanelState.DEFAULT_SELECTED_BODY_COLOR : Colors.grey;
  }

}