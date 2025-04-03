import 'json_service.dart';
import 'package:bussin/model/item.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._instance();
  static Database? _database;

  DatabaseService._instance();

  Future<Database> get db async {
    _database ??= await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    if (kIsWeb) {
      // Change default factory on the web
      databaseFactory = databaseFactoryFfiWeb;
    }
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'menu.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE main(id INTEGER PRIMARY KEY, name TEXT NOT NULL, price FLOAT NOT NULL, imageUrl TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE side(id INTEGER PRIMARY KEY, name TEXT NOT NULL, price FLOAT NOT NULL, imageUrl TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE drink(id INTEGER PRIMARY KEY, name TEXT NOT NULL, price FLOAT NOT NULL, imageUrl TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE meal(id INTEGER PRIMARY KEY, name TEXT NOT NULL, price FLOAT NOT NULL, imageUrl TEXT NOT NULL)',
    );
  }

  Future<int> insertItem(Item item, String table) async {
    Database db = await instance.db;
    return await db.insert(
      table,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> queryAllItems(String table) async {
    Database db = await instance.db;
    return await db.query(table);
  }

  Future<int> updateItem(Item item, String table) async {
    Database db = await instance.db;
    return await db.update(
      table,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id, String table) async {
    Database db = await instance.db;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> initializeItem() async {
    List<dynamic> drinkItems = await loadJsonMenu("drink");
    List<dynamic> mainItems = await loadJsonMenu("main");
    List<dynamic> sideItems = await loadJsonMenu("side");
    List<dynamic> mealItems = await loadJsonMenu("meal");

    for (Item item in drinkItems) {
      await insertItem(item, 'drink');
    }

    for (Item item in mainItems) {
      await insertItem(item, 'main');
    }

    for (Item item in sideItems) {
      await insertItem(item, 'side');
    }

    for (Item item in mealItems) {
      await insertItem(item, 'meal');
    }
  }
}
