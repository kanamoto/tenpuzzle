import 'dart:core';
import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:tenpuzzle/model/DataStore.dart';
import 'package:tenpuzzle/model/GameModel.dart';
import 'package:tenpuzzle/model/ModelData.dart';
import 'package:tenpuzzle/model/TimeElement.dart';
import 'package:tenpuzzle/peripheral/Log.dart';

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

class RecordListState extends State<RecordListWidget>{

  final GameModel _gameModel;

  RecordListState(this._gameModel)
  {
    _ascending = _gameModel.recordListAscending;
    _orderByColumn = GAME_RECORD_COLUMN.values[_gameModel.recordListOrderByColumn];
  }


  List<GameRecord> _gameRecordList = [];

  double _screenWidth = 0;
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

    reloadGameRecord();
  }

  @override
  void initState() {
    Log.print("${this.runtimeType} initState");
    super.initState();
  }

  @override
  void dispose() {
    Log.print("${this.runtimeType} dispose");
    super.dispose();
    _gameModel.saveRecordSettingData(orderByColumn: _orderByColumn.index , ascending: _ascending ).then((value){
      Log.print("RecordListPage dispose saveRecordSettingData done result:$value");
      if ( value == false ){
        // 保存に失敗している。
        print("***** DATA SAVE FAILED *****");
      }
    });
  }

  void reloadGameRecord() {
    Future<List<GameRecord>> future = _gameModel.recordList(orderBy:_orderByColumn , ascending: _ascending);
    future.then((value) {
      setState(() {
        _gameRecordList = value;
      });
    });
  }

  Widget listTitleWidget(double width, String titleStr , GAME_RECORD_COLUMN orderByColumn , {bool sorted = false , bool ascending = false} )
  {
    final String titleStrWithArrow = titleStr + (_orderByColumn == orderByColumn ? (_ascending ? "▼" : "▲") : "");

    return Listener(
      child: Center(
          child:SizedBox(width:width,
              child:
              Text(titleStrWithArrow)
          )
      ),
      onPointerDown:(event){
        setState(() {
          if ( _orderByColumn == orderByColumn){
            _ascending = _ascending == true ? false : true;
          }else{
            _orderByColumn = orderByColumn;
          }
          reloadGameRecord();
        });
      },
    );
  }

  Widget listRecordWidget(double width, String titleStr )
  {
    return Center(
          child:SizedBox(width:width,
              child:
              //Text(titleStr)
              AutoSizeText(
                titleStr,
                textAlign: TextAlign.left,
                maxLines: 1,
                style: TextStyle(fontSize: 30.0),
                minFontSize: 1,
              )
          )
      );
  }

  @override
  Widget build(BuildContext context) {

    final double listWidthUnit = _screenWidth * (1 / 7);

    return Scaffold(
      appBar: AppBar(title: Text("Clear Records"),),
      body:
        Column(children: <Widget>[
          Row(
            children: <Widget> [
              Spacer(),
              listTitleWidget(listWidthUnit    , "Question"   , GAME_RECORD_COLUMN.QUESTION        ),
              listTitleWidget(listWidthUnit    , "Expression" , GAME_RECORD_COLUMN.CLEAR_EXPRESSION),
              Spacer(),
              listTitleWidget(listWidthUnit    , "ClearTime"  , GAME_RECORD_COLUMN.GAME_CLEAR_TIME ),
              Spacer(),
              listTitleWidget(listWidthUnit * 2, "Play Date"  , GAME_RECORD_COLUMN.PLAY_DATETIME   ),
              Spacer(),
            ],
          ),
        Flexible(child:
        _gameRecordList.length == 0 ? AutoSizeText("No Record", maxLines: 1, style: TextStyle(fontSize: 30.0), minFontSize: 1,) :
          ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: Row(
                children: <Widget> [
                  Spacer(),
                  listRecordWidget(listWidthUnit    , _gameRecordList[index].question),
                  listRecordWidget(listWidthUnit    , ModelData.calcStrToShowStr(_gameRecordList[index].clearExpression) ),
                  Spacer(),
                  listRecordWidget(listWidthUnit    , TimeElement.fromCount(_gameRecordList[index].gameClearTime).toString()),
                  Spacer(),
                  listRecordWidget(listWidthUnit * 2, DateTime.fromMillisecondsSinceEpoch(_gameRecordList[index].playDateTime).toString()),
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