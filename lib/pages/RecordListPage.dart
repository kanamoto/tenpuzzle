import 'package:flutter/material.dart';
import 'package:tenpuzzle/GameModel.dart';

import 'DataStore.dart';
import 'TimeElement.dart';

//void main() => runApp(RootWidget());

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
  double _screenHeight;

  static const String PLAY_TIME_RESET_STR = "00:00:00:000";
  String _playTimerString = PLAY_TIME_RESET_STR;// "00:00:00:000";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
  }


  @override
  Widget build(BuildContext context) {

    Future<List<GameRecord>> future = _gameModel.recordList();
    future.then((value) {
      setState(() {
        _gameRecordList = value;
      });
    });

    return Scaffold(
      appBar: AppBar(title: Text("Clear Records"),),
      body:
        Column(children: <Widget>[
          // Text("Clear Records"),
          Row(
            children: <Widget> [
              Spacer(),
              //Center(child:SizedBox(width:50 , child:Text((index + 1).toString()))),
              Center(child:SizedBox(width:_screenWidth * (1 / 7), child:Text("Question"))),
              Center(child:SizedBox(width:_screenWidth * (1 / 7), child:Text("Expression"))),
              Center(child:SizedBox(width:_screenWidth * (1 / 7), child:Text("ClearTime"))),
              Center(child:SizedBox(width:_screenWidth * (2 / 7), child:Text("Play Date"))),
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

  // void _loadRecord()
  // {
  //   Future<List<GameRecord>> future = _gameModel.recordList();
  //   future.then((value) {
  //     for ( GameRecord record in value){
  //       var id = record.id;
  //       var question = record.question;
  //       var playDateTime = record.playDateTime;
  //       var gameClearTime = record.gameClearTime;
  //       var clearExpression = record.clearExpression;
  //
  //       print("$id $question $playDateTime $gameClearTime $clearExpression ");
  //
  //       print("$record.id $record.question $record.playDateTime $record.gameClearTime $record.clearExpression ");
  //     }
  //   });
  // }
}