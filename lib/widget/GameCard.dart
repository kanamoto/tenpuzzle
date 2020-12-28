import 'package:flutter/material.dart';
import 'package:tenpuzzle/model/ModelData.dart';

class GameCard extends StatefulWidget{
  final PanelData panelData;
  final double expansionRate;

  const GameCard({Key key, this.panelData , this.expansionRate = 0.0}) : super(key: key);

  State<StatefulWidget> createState() => GameCardState();
}

class GameCardState extends State<GameCard>{
  @override
  Widget build(BuildContext context) {
    return gameCard(widget.panelData , expansionRate:widget.expansionRate);
  }

  Positioned gameCard(PanelData panelData , {double expansionRate = 0.0}) {
    return Positioned(
      left: panelData.rect.left - expansionRate,
      top: panelData.rect.top - expansionRate,
      width: panelData.rect.width + expansionRate * 2,
      height: panelData.rect.height + expansionRate * 2,
      child: Container(color: _panelBorderColor(panelData),
          child:Card(
            color: _panelBodyColor(panelData, expansionRate),
            child: Center(
              child: Text(panelData.title,
                style: TextStyle(
                    fontSize: 36 + 150 * (expansionRate / 100) ,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )),
    );
  }

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