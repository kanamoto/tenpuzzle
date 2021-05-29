

import 'package:tenpuzzle/model/ModelData.dart';
import 'GamePanel.dart';
import 'OperatorPanel.dart';

GamePanel gamePanelFactory(PanelData panelData, double expansionRate)
{
  GamePanel gamePanel;
  switch (panelData.kind){
      case PanelDataKind.NUMERIC:
        gamePanel = GamePanel(panelData: panelData,expansionRate: expansionRate);
        break;
      case PanelDataKind.OPERATOR:
        gamePanel = OperatorPanel(panelData: panelData,expansionRate: expansionRate);
        break;
  }
  return gamePanel;
}
