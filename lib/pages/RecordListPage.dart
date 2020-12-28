import 'package:flutter/material.dart';
import 'package:tenpuzzle/model/GameModel.dart';

import 'package:tenpuzzle/model/DataStore.dart';
import 'package:tenpuzzle/model/TimeElement.dart';

class RecordListPage extends StatelessWidget {

  final GameModel _gameModel;

  RecordListPage(this._gameModel);

  @override
  Widget build(BuildContext context) {
    return  RecordListWidget(_gameModel);
  }
}

class RecordListWidget extends StatefulWidget {

  final GameModel _gameModel;

  RecordListWidget(this._gameModel);

  @override
  State<StatefulWidget> createState() {
    return RecordListState(_gameModel);
  }
}

class RecordListState extends State<RecordListWidget> {

  final GameModel _gameModel;

  RecordListState(this._gameModel);

  List<GameRecord> _gameRecordList = List<GameRecord>();

  double _screenWidth;
//  double _screenHeight;

  bool _ascending = true;
  GAME_RECORD_COLUMN _orderByColumn = GAME_RECORD_COLUMN.QUESTION;

  static const String PLAY_TIME_RESET_STR = "00:00:00:000";
//  String _playTimerString = PLAY_TIME_RESET_STR;// "00:00:00:000";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _screenWidth = MediaQuery.of(context).size.width;
//    _screenHeight = MediaQuery.of(context).size.height;

    Future<List<GameRecord>> future = _gameModel.recordList(orderBy:_orderByColumn , ascending: _ascending);
    future.then((value) {
      setState(() {
        _gameRecordList = value;
      });
    });

  }


  Widget listTitleWidget(double width, String titleStr , GAME_RECORD_COLUMN orderByColumn , {bool sorted = false , bool ascending = false} )
  {
    return Listener(child: Center(child:SizedBox(width:width, child:Text(titleStr))),
      onPointerDown:(event){
        setState(() {
          if ( _orderByColumn == orderByColumn){
            _ascending = _ascending == true ? false : true;
          }else{
            _orderByColumn = orderByColumn;
          }
        });
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    // Future<List<GameRecord>> future = _gameModel.recordList(orderBy:_orderByColumn , ascending: _ascending);
    // future.then((value) {
    //   setState(() {
    //     _gameRecordList = value;
    //   });
    // });
    //
    return Scaffold(
      appBar: AppBar(title: Text("Clear Records"),),
      body:
        Column(children: <Widget>[
          Row(
            children: <Widget> [
              Spacer(),
              listTitleWidget(_screenWidth * (1 / 7), "Question"   + (_orderByColumn == GAME_RECORD_COLUMN.QUESTION         ? (_ascending ? "▼" : "▲") : ""), GAME_RECORD_COLUMN.QUESTION        ),
              listTitleWidget(_screenWidth * (1 / 7), "Expression" + (_orderByColumn == GAME_RECORD_COLUMN.CLEAR_EXPRESSION ? (_ascending ? "▼" : "▲") : ""), GAME_RECORD_COLUMN.CLEAR_EXPRESSION),
              listTitleWidget(_screenWidth * (1 / 7), "ClearTime"  + (_orderByColumn == GAME_RECORD_COLUMN.GAME_CLEAR_TIME  ? (_ascending ? "▼" : "▲") : ""), GAME_RECORD_COLUMN.GAME_CLEAR_TIME ),
              listTitleWidget(_screenWidth * (2 / 7), "Play Date"  + (_orderByColumn == GAME_RECORD_COLUMN.PLAY_DATETIME    ? (_ascending ? "▼" : "▲") : ""), GAME_RECORD_COLUMN.PLAY_DATETIME   ),
              Spacer(),
            ],
          ),
        Flexible(child:
          ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: Row(
                children: <Widget> [
                  Spacer(),
                  //Center(child:SizedBox(width:50 , child:Text((index + 1).toString()))),
                  Center(child:SizedBox(width:_screenWidth * (1 / 7), child:Text(_gameRecordList[index].question))),
                  Center(child:SizedBox(width:_screenWidth * (1 / 7), child:Text(_gameRecordList[index].clearExpression))),
                  Center(child:SizedBox(width:_screenWidth * (1 / 7), child:Text(TimeElement.fromCount(_gameRecordList[index].gameClearTime).toString()))),
                  Center(child:SizedBox(width:_screenWidth * (2 / 7), child:Text(DateTime.fromMillisecondsSinceEpoch(_gameRecordList[index].playDateTime).toString()))),
                  Spacer(),
                ],
              ),
            );
          },
          itemCount: _gameRecordList.length,
          ),
        ),
      ],)
    );
  }
}