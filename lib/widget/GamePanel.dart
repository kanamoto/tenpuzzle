import 'package:flutter/material.dart';
import 'package:tenpuzzle/model/ModelData.dart';

class GamePanel extends StatefulWidget{
  final PanelData panelData;
  final double expansionRate;

  const GamePanel({Key? key, required this.panelData , this.expansionRate = 0.0}) : super(key: key);

  State<StatefulWidget> createState() => GamePanelState();
}

class GamePanelState extends State<GamePanel>{
  @override
  Widget build(BuildContext context) {
    return gamePanel(widget.panelData , expansionRate:widget.expansionRate);
  }

  static const int _baseFontSize = 36;
  static const int _maxEnlargementFontSize = 150;

  static const DEFAULT_SELECTED_LINE_COLOR = Colors.redAccent;
  // ignore: non_constant_identifier_names
  static get DEFAULT_SELECTED_BODY_COLOR => Colors.pink[200];

  AnimatedPositioned gamePanel(PanelData panelData , {double expansionRate = 0.0}) {
    return AnimatedPositioned(key:panelData.key, // Drag完了で、GamePanelのZ-indexの位置が変わると、動かしていないものもアニメーションする。Keyを更新すると、別Widgetとみなされ、z-index変更時のアニメーション対象としない。
      duration: Duration(milliseconds: 100),
      left: panelData.rect.left - expansionRate,
      top: panelData.rect.top - expansionRate,
      width: panelData.rect.width + expansionRate * 2,
      height: panelData.rect.height + expansionRate * 2,
      child: Container(color: panelBorderColor(panelData),
          child:Card(
            color: panelBodyColor(panelData, expansionRate),
            child: Center(
              child: Text(panelData.showStr,
                style: TextStyle(
                    fontSize: _baseFontSize + _maxEnlargementFontSize * (expansionRate / 100) ,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )),
    );
  }


  Color panelBorderColor(PanelData panelData)
  {
    Color borderColor;
    if ( panelData.kind == PanelDataKind.NUMERIC ){
//      borderColor = Colors.indigo;
      borderColor = Colors.white30;
    }else{
      borderColor = Colors.white30;
    }
    return panelData.selected == true ? DEFAULT_SELECTED_LINE_COLOR : borderColor;
  }

  Color panelBodyColor(PanelData panelData, double expansionRate)
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
    return panelData.selected == true ? DEFAULT_SELECTED_BODY_COLOR : bodyColor;
  }
}