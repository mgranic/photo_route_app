import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDbHandler {
  /// database should only be created once for all instances of SqliteDbHandler
  /// (singleton)
  static Database? _database =
      null; // explicitly set to null because it is not implicitly set for some reason

  static const String TRIP_DESCRIPTION =
      '''create table trip_description (id INTEGER PRIMARY KEY AUTOINCREMENT,
                                            name varchar(50),
                                            description varchar (200),
                                            start_time DATETIME,
                                            end_time DATETIME);''';

  static const String TRIP_STOP_POINTS =
      '''create table metal_price (id INTEGER PRIMARY KEY AUTOINCREMENT, 
                                            trip_id int,
                                            latitude double,
                                            longitude double,
                                            start_time DATETIME,
                                            end_time DATETIME,
                                            FOREIGN KEY (trip_id) REFERENCES trip_description (id)); ''';

  SqliteDbHandler();

  /*

    /// handler is singleton
  static late SqliteDbHandler _sqliteDbHandler;

  static get sqliteDbHandler => SqliteDbHandler.singleton();
  static get database => _database;

  static get dbCreate {
    SqliteDbHandler.singleton();
    return _database;
  }

  SqliteDbHandler._private() {
    _sqliteDbHandler = this;
  }

  SqliteDbHandler() {
    SqliteDbHandler.singleton();
  }

  factory SqliteDbHandler.singleton() => _sqliteDbHandler ?? SqliteDbHandler._private();
  */

  /// create database if it does not exist
  /// use SQFlite API function openDatabase to create database
  /// onCreate is executed when this app is first installed
  Future<Database> _createDatabase() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'exchange_app.db');

    return await openDatabase(dbPath, version: 1, onCreate: _populateDb);
    // return _database;
  }

  /// create tables that are needed in this database
  Future<void> _populateDb(Database database, int version) async {
    await database.execute(TRIP_DESCRIPTION);
    await database.execute(TRIP_STOP_POINTS);
  }

  /// insert rows into table
  Future<int> insertIntoTable(
      String tableName, String columns, String values) async {
    _database ??= await _createDatabase();
    return await _database!
        .rawInsert('''INSERT INTO $tableName ($columns) VALUES ($values);''');
  }

  Future<int> updateTable(String tableName, String set, String where) async {
    //print('''INSERT INTO $tableName ($columns) VALUES ($values);''');
    _database ??= await _createDatabase();
    return await _database!
        .rawUpdate('''UPDATE $tableName SET $set WHERE $where;''');
  }

  /// select rows from table using condition. Select specified columns (can be *)
  Future<List<Map>> selectFromTableConditional(
      String tableName, String columns, String condition) async {
    _database ??= await _createDatabase();
    return await _database!
        .rawQuery('''SELECT $columns FROM $tableName WHERE $condition''');
    /*
    // Get the records
    List<Map> list = await database.rawQuery('SELECT * FROM Test');
    List<Map> expectedList = [
      {'name': 'updated name', 'id': 1, 'value': 9876, 'num': 456.789},
      {'name': 'another name', 'id': 2, 'value': 12345678, 'num': 3.1416}
];
     */
  }

  /// select rows from table without condition. Select specified columns (can be *)
  Future<List<Map>> selectFromTable(String tableName, String columns) async {
    //print('''SELECT $columns FROM $tableName;''');
    _database ??= await _createDatabase();
    return await _database!.rawQuery('''SELECT $columns FROM $tableName;''');
  }

  /// Delete rows from table where IDs are matched from list of IDs
  Future<void> deleteRowsById(String tableName, String ids) async {
    _database ??= await _createDatabase();
    await _database!.execute('DELETE FROM $tableName WHERE id IN ($ids);"');
  }

  /// create tables that are needed in this database
  Future<void> truncateTable(String tableName) async {
    _database ??= await _createDatabase();
    await _database!.execute('DELETE FROM $tableName');
  }

  /// close database after usage
  Future<void> closeDatabase() async {
    await _database?.close();
    _database = null;
  }
}
