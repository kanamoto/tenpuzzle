
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tenpuzzle/model/ModelData.dart';
import 'package:tenpuzzle/widget/GameCard.dart';

class OperatorCard extends GameCard {

  const OperatorCard({Key key, panelData , expansionRate = 0.0}) : super(key:key , panelData:panelData, expansionRate:expansionRate );

  State<StatefulWidget> createState() => OperatorCardState();
}



class OperatorCardState extends GameCardState {

  @override
  Color _panelBorderColor(PanelData panelData)
  {
    Color borderColor;
    if ( panelData.kind == PanelDataKind.NUMERIC ){
//      borderColor = Colors.indigo;
      borderColor = Colors.white30;
    }else{
      borderColor = Colors.white30;
    }
    return panelData.selected == true ? Colors.redAccent : borderColor;
  }

  @override
  Color _panelBodyColor(PanelData panelData, double expansionRate)
  {
    Color bodyColor;
    if ( panelData.kind == PanelDataKind.NUMERIC ){
      //0xFF2196F3
      bodyColor = Color.fromARGB(
          0xff - (0xff * (0.01 * expansionRate)).toInt() ,
//          0x21, 0x96, 0xF3);   //Colors .blue;
          0xff, 0xff, 0xff);   //Colors .blue;
    }else{
      bodyColor = Colors.grey;
    }
    return panelData.selected == true ? Colors.pink[200] : bodyColor;
  }

}