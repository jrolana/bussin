import 'dart:convert';

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
      databaseFactory = databaseFactoryFfiWeb;
    }
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'db.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
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
    await db.execute(
      'CREATE TABLE favorites(id INTEGER PRIMARY KEY AUTOINCREMENT, favorite TEXT NOT NULL)',
    );
    await instance.initializeItems(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS main');
    await db.execute('DROP TABLE IF EXISTS side');
    await db.execute('DROP TABLE IF EXISTS drink');
    await db.execute('DROP TABLE IF EXISTS meal');
    await db.execute('DROP TABLE IF EXISTS favorites');
    await _onCreate(db, newVersion);
  }

  Future<int> insertItem(Item item, String table, {Database? db}) async {
    db ??= await instance.db;
    return await db.insert(
      table,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertFavorite(List<Item> items, {Database? db}) async {
    db ??= await instance.db;
    return await db.insert("favorites", {
      "order": jsonEncode(items),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFavorite(int id) async {
    Database db = await instance.db;
    await db.delete("favorite", where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateItem(Item item, String table, {Database? db}) async {
    db ??= await instance.db;
    return await db.update(
      table,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id, String table, {Database? db}) async {
    db ??= await instance.db;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> initializeItems(Database db) async {
    List<dynamic> drinkItems = await loadJsonMenu("drink");
    List<dynamic> mainItems = await loadJsonMenu("main");
    List<dynamic> sideItems = await loadJsonMenu("side");
    List<dynamic> mealItems = await loadJsonMenu("meal");

    for (Item item in drinkItems) {
      await insertItem(item, 'drink', db: db);
    }

    for (Item item in mainItems) {
      await insertItem(item, 'main', db: db);
    }

    for (Item item in sideItems) {
      await insertItem(item, 'side', db: db);
    }

    for (Item item in mealItems) {
      await insertItem(item, 'meal', db: db);
    }
  }
}
