

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tenpuzzle/model/ModelData.dart';

class OperatorPanelWidget extends StatelessWidget {

  final List<PanelData> _panelList;
  final double _screenWidth;
  final double _screenHeight;
  final Function(PanelData) _tapEvent;

  OperatorPanelWidget(this._panelList, this._screenWidth , this._screenHeight , this._tapEvent);

  @override
  Widget build(BuildContext context) {
    return
      _operatorPanel( _panelList , _screenWidth , _screenHeight, _tapEvent);
    }

  // Widget _sampleBuild(BuildContext context) {
  //   return
  //     Container(
  //         decoration: BoxDecoration(
  //             border: Border.all(
  //               color: Colors.teal, //.red[500],
  //             ),
  //             borderRadius: BorderRadius.all(Radius.circular(20))
  //         ),
  //         child:
  //         Wrap(children: [
  //
  //           Padding(
  //             padding: EdgeInsets.all(5.0),
  //             child: Column(
  //               children: [
  //                 Text(
  //                   '6',
  //                   style: TextStyle(
  //                       color: Colors.red[500],
  //                       fontSize: 25),
  //                 ),
  //                 Text(
  //                   'sep',
  //                   style: TextStyle(
  //                       color: Colors.red[500]),
  //                 ),
  //                 Text('Hello, World!', style: Theme.of(context).textTheme.headline4)
  //
  //               ],
  //             ),
  //           ),
  //
  //         ])
  //     );
  // }


  Widget _operatorPanel( List<PanelData> panelList , double screenWidth , double screenHeight, Function(PanelData) tapEvent) {
        return
        Padding( padding: const EdgeInsets.all(10.0),
        child:
          Align(alignment: Alignment.centerRight,
            child:
            // Positioned(
            //     top: screenHeight / 2,
            //     right: 10,
            //     child:
                  Container(
                            decoration: BoxDecoration(
                                                      border: Border.all(
                                                                  color: Colors.black, //.red[500],
                                                                  width: 1.0
                                                              ),
                                                  borderRadius: BorderRadius.all(Radius.circular(20))
                                                  ),
                  child:
                      Wrap(children: [
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child:
                                Column(
                                  mainAxisSize:MainAxisSize.min,
                                  children:[
                                    Row(
                                        mainAxisSize:MainAxisSize.min,
                                        children:[
                                          operatorButton(panelList[0] , tapEvent),
                                          operatorButton(panelList[1] , tapEvent),
                                        ]
                                    ),
                                    Row(
                                        mainAxisSize:MainAxisSize.min,
                                        children:[
                                          operatorButton(panelList[2] , tapEvent),
                                          operatorButton(panelList[3] , tapEvent),
                                        ]
                                    ),
                                    Row(
                                        mainAxisSize:MainAxisSize.min,
                                        children:[
                                          operatorButton(panelList[4] , tapEvent),
                                          operatorButton(panelList[5] , tapEvent),
                                     ]
                                    )
                                  ]
                                )
                            )
                      ])
                  )

           )
        )
    ;
  }


  static const double _PANEL_WIDTH = 48.0;
  static const double _PANEL_HEIGHT = 48.0;

  Widget operatorButton(PanelData panelData , Function(PanelData) tapEvent)
  {
    return
      Padding(
        padding: EdgeInsets.all(5.0),
        child:
        SizedBox(
          width: _PANEL_WIDTH,
          height: _PANEL_HEIGHT,
          child:
          RaisedButton(
            child: Text(panelData.title, textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold),

            ),
            color: Colors.white,
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            onPressed: () {
              tapEvent(panelData);
            },
          ),
        )
      );
  }

}



