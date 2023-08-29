import 'package:flutter/material.dart';
import 'package:tenpuzzle/model/GameModel.dart';
import 'package:tenpuzzle/model/TimeElement.dart';

class PlayTimerDisplay extends StatefulWidget{

  //final String playTimerString;
  //final Stream<int> stream;
  final GameModel _gameModel;

  const PlayTimerDisplay({Key? key, required gameModel}) : _gameModel = gameModel, super(key: key);

  @override
  State<StatefulWidget> createState() => PlayTimerDisplayState();
}

class PlayTimerDisplayState extends State<PlayTimerDisplay>
{
  static const String PLAY_TIME_RESET_STR = "00:00:00:000";

  @override
  Widget build(BuildContext context) {
    // return Text(
    //   widget.playTimerString,
    //   textAlign: TextAlign.center,
    //   overflow: TextOverflow.ellipsis,
    //   style: TextStyle(
    //       fontSize: 20,
    //       fontWeight: FontWeight.bold),
    // );
    return StreamBuilder(
        stream: widget._gameModel.timeStream, // .stream,
        builder: (BuildContext context, AsyncSnapshot<int> snapShot) {
          return Text(
            snapShot.hasData ? TimeElement.fromCount(snapShot.data ?? 0).toString() : PLAY_TIME_RESET_STR,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold),
          );
        });
  }

}