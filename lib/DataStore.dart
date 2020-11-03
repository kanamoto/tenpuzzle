import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/widgets.dart';

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

class DataStore {

  Future<Database> _database;

  void initializeDB() async
  {
    WidgetsFlutterBinding.ensureInitialized();

    /*final Future<Database>*/
    _database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'gamerecord.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        // db.execute(
        //   "DROP TABLE gamerecord;",
        // );
        return db.execute(
          "CREATE TABLE if not exists gamerecord(id INTEGER PRIMARY KEY AUTOINCREMENT , question TEXT , playDateTime INTEGER , gameClearTime  INTEGER , clearExpression TEXT);",
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    //  databaseFuture.then((value) => null).then((value) => database = value);
  }

  // final fido = Dog(
  //   id: 0,
  //   name: 'Fido',
  //   age: 35,
  // );
  //
  // await insertDog(database, fido);
  //
  // Future<List<Dog>> dogListFuture = dogs(database);
  // List<Dog> dogList = await dogListFuture;
  // for (Dog dog in dogList){
  // print("${dog.name} ${dog.id} ${dog.age}");
  // }
  //
  // print(await dogs(database));


  // Define a function that inserts dogs into the database
  Future<void> insertGameRecord(GameRecord gameRecord) async {
    // Get a reference to the database.
    final Database db = await _database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'gamerecord',
      gameRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<GameRecord>> loadRecordData() async {
    // Get a reference to the database.
    final Database db = await _database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('gamerecord' , orderBy: "question");

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
}
