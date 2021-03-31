import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/widgets.dart';
import 'package:tenpuzzle/model/ModelData.dart';

// id(Unique) , Question , Datetime , cleartime , clear string

///
///
///
class GameRecord {
  final int id;
  final String question;
  final int playDateTime;
  final int gameClearTime;
  final String clearExpression;

  GameRecord({this.id, this.question, this.playDateTime, this.gameClearTime,
      this.clearExpression});

  Map<String, dynamic> toMap() {
    return {
      //'id': id,
      'question':  question,
      'playDateTime': playDateTime,
      'gameClearTime': gameClearTime,
      'clearExpression': clearExpression,
    };
  }
}

enum GAME_RECORD_COLUMN {
  QUESTION,
  PLAY_DATETIME,
  GAME_CLEAR_TIME,
  CLEAR_EXPRESSION,
}


class DataStore {

  Database _database;

  Future<void> initializeDB() async
  {
    print("initializeDB start");
    WidgetsFlutterBinding.ensureInitialized();

    /*final Future<Database>*/
    _database = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'gamerecord.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        print("onCreate call start");
        db.execute(
          "CREATE TABLE if not exists gamerecord(id INTEGER PRIMARY KEY AUTOINCREMENT , question TEXT , playDateTime INTEGER , gameClearTime  INTEGER , clearExpression TEXT);",
        );
        print("onCreate call end");
        return db;
      },
      onOpen:(db){
        print("onOpen call start");
        _createResumePanelData(db);
        print("onOpen call end");
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    print("initializeDB end");
  }

  Future<void> insertGameRecord(GameRecord gameRecord) async {
    // Get a reference to the database.
    final Database db = _database;

    await db.insert(
      'gamerecord',
      gameRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Map<GAME_RECORD_COLUMN, String> _orderByMap = {
      GAME_RECORD_COLUMN.QUESTION : 'question',
      GAME_RECORD_COLUMN.PLAY_DATETIME : 'playDateTime',
      GAME_RECORD_COLUMN.GAME_CLEAR_TIME:'gameClearTime',
      GAME_RECORD_COLUMN.CLEAR_EXPRESSION:'clearExpression',
  };

  // A method that retrieves all the dogs from the dogs table.
  Future<List<GameRecord>> loadRecordData({GAME_RECORD_COLUMN orderBy = GAME_RECORD_COLUMN.QUESTION , bool ascending}) async {
    // Get a reference to the database.
    final Database db = _database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('gamerecord' , orderBy: _orderByMap[orderBy] + (ascending ? " asc" : " desc") );

 //   print("loadRecorddata $maps");

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return GameRecord(
        id: maps[i]['id'],
        question: maps[i]['question'],
        playDateTime: maps[i]['playDateTime'],
        gameClearTime: maps[i]['gameClearTime'],
        clearExpression: maps[i]['clearExpression'],
      );
    });
  }

  Future<bool> savePlayData(ModelData modelData) async
  {
    var completer = new Completer<bool>();

    final Database db = _database;

    db.transaction((txn) async {
      try {
        await txn.delete('resumePanelData');

        for (int idx = 0; idx < modelData.panelPosList.length; idx++) {
          PanelData panel = modelData.panelPosList[idx];

          Map<String, dynamic> panelDataMap = {
            'left': panel.rect.left,
            'top': panel.rect.top,
            'right': panel.rect.right,
            'bottom': panel.rect.bottom,
            'title': panel.calcStr,
            'kind': panel.kind.index,
          };
          print("Savedata $panelDataMap");

          await txn.insert(
            'resumePanelData',
            panelDataMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // その他のデータ
        print("await txn.delete('storeModelData');");
        await txn.delete('storeModelData');

        Map<String, dynamic> questionStringMap = {
          'key': "questionString",
          'valueText': modelData.questionString,
        };
        await txn.insert(
          'storeModelData',
          questionStringMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        Map<String, dynamic> currentCountMap = {
          'key': "playTime",
          'valueInt': modelData.playTime,
        };
        await txn.insert(
          'storeModelData',
          currentCountMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        Map<String, dynamic> playStartTimeMap = {
          'key': "playStartTime",
          'valueInt': modelData.playStartTime,
        };
        await txn.insert(
          'storeModelData',
          playStartTimeMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // FYI:ここで読み込みを行うと、ロックがかかっていて止まる

        completer.complete(true);
      }catch(e){
        completer.complete(false);
        print(e);
        throw e;
      }
    });

    return completer.future;
  }

  Future<bool> hasSavePlayData() async
  {
    print("hasSavePlayData _database:$_database");

    return _database.rawQuery("select count(*) as cnt from resumePanelData;").then((value){
      print("hasPlayData success");
      if (value.length == 0) {
        return false;
      }

      Map<String, dynamic>  record = value[0];
      int val = record["cnt"];

      return val > 0 ? true : false;
    }).catchError((e){
      print("hasSavePlayData catchError");
      print(e);
      return false;
    });
  }

  Future<Map<String, dynamic>> loadPlayData() async
  {
    print("load start loadPlayData");
    final List<Map<String, dynamic>> maps = await _database.query('resumePanelData' , orderBy: "id" );

    Map<String, dynamic> returnMap = Map();

    returnMap["panelData"] = List.generate(maps.length, (i) {
       PanelData panelData = PanelData();
       print("i:$i");
       print(maps[i]);
       print(maps);
       panelData.rect = Rect.fromLTRB(maps[i]['left'],
                                      maps[i]['top'],
                                      maps[i]['right'],
                                      maps[i]['bottom']);
       panelData.calcStr = maps[i]['title'];
       panelData.showStr = ModelData.calcStrToShowStr(panelData.calcStr);
       panelData.kind = PanelDataKind.values[maps[i]['kind']];
//s       print("$panelData");
      return panelData;
    });

    final List<Map<String, dynamic>> questionStringMap = await _database.query('storeModelData' , where:"key='questionString'");
    final List<Map<String, dynamic>> playTimeMap = await _database.query('storeModelData' , where:"key='playTime'");
    final List<Map<String, dynamic>> playStartTimeMap = await _database.query('storeModelData' , where:"key='playStartTime'");

    returnMap["questionString"] =  questionStringMap[0]["valueText"];
    returnMap["playTime"] =  playTimeMap[0]["valueInt"];
    returnMap["playStartTime"] =  playStartTimeMap[0]['valueInt'];

    return returnMap;
  }




  void clearPlayData()
  {
    print("_dataStore.clearPlayData()");
    _database.delete("resumePanelData");
  }

  void _createResumePanelData(Database db) async
  {
    print("createResumePanelData start");

    // ゲームのクリア記録
    await db.execute('''
          CREATE TABLE if not exists gamerecord(
            id INTEGER PRIMARY KEY AUTOINCREMENT , 
            question TEXT , 
            playStartDateTime INTEGER default 0, 
            playDateTime INTEGER default 0, 
            gameClearTime INTEGER default 0 , 
            clearExpression TEXT
          );
        ''',
    );

    try {
      await db.execute(
        '''
        ALTER TABLE gamerecord ADD COLUMN playStartDateTime INTEGER;
        ''');
    }catch(e){
//      print(e);
      // FIXME:問題なけれは何もしないコードにする
    }

    // パネル用のテーブル
    await db.execute('''
      CREATE TABLE if not exists resumePanelData(
        id INTEGER PRIMARY KEY AUTOINCREMENT , 
        left REAL , 
        top REAL , 
        right REAL ,
        bottom REAL , 
        title TEXT,
        kind INTEGER
      );
    ''');

    // 他の細々した情報のKey-Value
    await db.execute('''
      CREATE TABLE if not exists storeModelData(
        id INTEGER PRIMARY KEY AUTOINCREMENT , 
        key TEXT,
        valueText TEXT default '',
        valueReal REAL default 0,
        valueInt  INTEGER default 0 
      );
    ''');

    print("createResumePanelData end");

  }

}
