import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:tenpuzzle/model/ModelData.dart';
import 'package:tenpuzzle/peripheral/Log.dart';

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
      QUESTION : question,
      PLAY_DATE_TIME : playDateTime,
      GAME_CLEAR_TIME : gameClearTime,
      CLEAR_EXPRESSION : clearExpression,
    };
  }

  static const String QUESTION = 'question';
  static const String PLAY_DATE_TIME = 'playDateTime';
  static const String GAME_CLEAR_TIME = 'gameClearTime';
  static const String CLEAR_EXPRESSION = 'clearExpression';
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
      join(await getDatabasesPath(), 'gamerecord.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        print("onCreate call start");
        _createResumePanelData(db);
        print("onCreate call end");
        return db;
      },
      onOpen:(db){
        // print("onOpen call start");
        // print("onOpen call end");
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
      GAME_RECORD_COLUMN.QUESTION : GameRecord.QUESTION,
      GAME_RECORD_COLUMN.PLAY_DATETIME : GameRecord.PLAY_DATE_TIME,
      GAME_RECORD_COLUMN.GAME_CLEAR_TIME: GameRecord.GAME_CLEAR_TIME,
      GAME_RECORD_COLUMN.CLEAR_EXPRESSION: GameRecord.CLEAR_EXPRESSION,
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
        question: maps[i][GameRecord.QUESTION],
        playDateTime: maps[i][GameRecord.PLAY_DATE_TIME],
        gameClearTime: maps[i][GameRecord.GAME_CLEAR_TIME],
        clearExpression: maps[i][GameRecord.CLEAR_EXPRESSION],
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

        print("${this.runtimeType} panelPosList ${modelData.panelPosList.length}");
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
          print("${this.runtimeType} Savedata $panelDataMap");

          await txn.insert(
            'resumePanelData',
            panelDataMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // その他のデータ
        print("await txn.delete('storeModelData');");
        await txn.delete('storeModelData');

        Log.print("modelData.questionString:${modelData.questionString}");

        Log.print("questionString     :${modelData.questionString         }");
        Log.print("playTime           :${modelData.playTime               }");
        Log.print("playStartTime      :${modelData.playStartTime          }");
        Log.print("recordListOrder    :${modelData.recordListOrderByColumn}");
        Log.print("recordListAscending:${modelData.recordListAscending    }");
        Log.print("screenWidth        :${modelData.screenWidth            }");
        Log.print("screenHeight       :${modelData.screenHeight           }");

        await saveModelDataString("questionString"     , modelData.questionString , txn);
        await saveModelDataInt   ("playTime"           , modelData.playTime       , txn);
        await saveModelDataInt   ("playStartTime"      , modelData.playStartTime  , txn);
        await saveModelDataInt   ("recordListOrder"    , modelData.recordListOrderByColumn , txn);
        await saveModelDataInt   ("recordListAscending", modelData.recordListAscending == false ? 0 : 1 , txn);
        await saveModelDataReal  ("screenWidth"        , modelData.screenWidth  , txn);
        await saveModelDataReal  ("screenHeight"       , modelData.screenHeight , txn);

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

  Future saveModelDataString(String saveKey, String saveValue, Transaction txn) async {
    Map<String, dynamic> questionStringMap = {
      'key': saveKey,
      'valueText': saveValue,
    };
    await txn.insert(
      'storeModelData',
      questionStringMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future saveModelDataInt(String saveKey, int saveValue, Transaction txn) async {
    Map<String, dynamic> questionStringMap = {
      'key': saveKey,
      'valueInt': saveValue,
    };
    await txn.insert(
      'storeModelData',
      questionStringMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future saveModelDataReal(String saveKey, double saveValue, Transaction txn) async {
    Map<String, dynamic> questionStringMap = {
      'key': saveKey,
      'valueReal': saveValue,
    };
    await txn.insert(
      'storeModelData',
      questionStringMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  Future<Map<String, dynamic>> loadPlayData(ModelData modelData) async
  {
    Log.print("load start loadPlayData");
    final List<Map<String, dynamic>> maps = await _database.query('resumePanelData' , orderBy: "id" );

    Map<String, dynamic> returnMap = Map();

    returnMap["panelData"] = List.generate(maps.length, (i) {
       PanelData panelData = PanelData();
       Log.print("i:$i");
       Log.print(maps[i].toString());
       Log.print(maps.toString());
       panelData.rect = Rect.fromLTRB(maps[i]['left'],
                                      maps[i]['top'],
                                      maps[i]['right'],
                                      maps[i]['bottom']);
       panelData.calcStr = maps[i]['title'];
       panelData.showStr = ModelData.calcStrToShowStr(panelData.calcStr);
       panelData.kind = PanelDataKind.values[maps[i]['kind']];
      return panelData;
    });

    final List<Map<String, dynamic>> questionStringMap = await _database.query('storeModelData' , where:"key='questionString'");
    final List<Map<String, dynamic>> playTimeMap       = await _database.query('storeModelData' , where:"key='playTime'");
    final List<Map<String, dynamic>> playStartTimeMap  = await _database.query('storeModelData' , where:"key='playStartTime'");
    final List<Map<String, dynamic>> recordListOrderMap = await _database.query('storeModelData' , where:"key='recordListOrder'");
    final List<Map<String, dynamic>> recordListAscendingMap = await _database.query('storeModelData' , where:"key='recordListAscending'");
    final List<Map<String, dynamic>> screenWidthMap         = await _database.query('storeModelData' , where:"key='screenWidth'");
    final List<Map<String, dynamic>> screenHeightMap        = await _database.query('storeModelData' , where:"key='screenHeight'");

    returnMap["questionString"]      = questionStringMap.length > 0 ? questionStringMap[0]["valueText"] : "";
    returnMap["playTime"]            = playTimeMap.length > 0 ? playTimeMap[0]["valueInt"] : 0;
    returnMap["playStartTime"]       = playStartTimeMap.length > 0 ? playStartTimeMap[0]['valueInt'] : 0;
    returnMap["recordListOrder"]     = recordListOrderMap.length > 0 ? recordListOrderMap[0]['valueInt'] : 0;
    returnMap["recordListAscending"] = recordListAscendingMap.length > 0 ? recordListAscendingMap[0]['valueInt'] == 0 ? false : true : false;
    returnMap["screenWidth"]         = screenWidthMap.length > 0 ? screenWidthMap[0]['valueReal'] : 0;
    returnMap["screenHeight"]        = screenHeightMap.length > 0 ? screenHeightMap[0]['valueReal'] : 0;

    {
      Log.print("GameModel.dataStore.loadPlayData then ");
      modelData.questionString = returnMap["questionString"];
      modelData.playTime = returnMap["playTime"];
      modelData.playStartTime = returnMap["playStartTime"];
      modelData.panelPosList = returnMap["panelData"] ?? [];
      modelData.recordListOrderByColumn = returnMap["recordListOrder"];
      modelData.recordListAscending = returnMap["recordListAscending"];
      double oldScreenWidth = returnMap["screenWidth"] ?? 0;
      double oldScreenHeight = returnMap["screenHeight"] ?? 0;
      if ( modelData.screenWidth  != oldScreenWidth ||
          modelData.screenHeight != oldScreenHeight  ){
        modelData.adjustPanelPosition(oldScreenWidth , oldScreenHeight, modelData.screenWidth , modelData.screenHeight);
      }

      Log.print("GameModel.dataStore.loadPlayData then. "
          "questionString: ${modelData.questionString} "
          "playTime: ${modelData.playTime} "
          "playStartTime: ${modelData.playStartTime} "
          "recordListOrder: ${modelData.recordListOrderByColumn} "
          "recordListAscending: ${modelData.recordListAscending} "
      );
    }


    return returnMap;
  }


  Future<bool> saveRecordSettingData(ModelData modelData) async
  {
    var completer = new Completer<bool>();

    final Database db = _database;

    db.transaction((txn) async {
      try {
        // その他のデータ
        print("await txn.delete('storeModelData');");

        await saveModelDataInt("recordListOrder"     , modelData.recordListOrderByColumn , txn);
        await saveModelDataInt("recordListAscending" , modelData.recordListAscending == true ? 0 : 1 , txn);

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

//     // old version DB transrate
//     try {
//       await db.execute(
//         '''
//         ALTER TABLE gamerecord ADD COLUMN playStartDateTime INTEGER;
//         ''');
//     }catch(e){
// //      print(e);
//       // FIXME:問題なけれは何もしないコードにする
//     }

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
