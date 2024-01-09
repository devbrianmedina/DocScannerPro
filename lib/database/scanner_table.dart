import 'package:doc_scanner_pro/database/db_helper.dart';
import 'package:doc_scanner_pro/models/Scanner.dart';
import 'package:sqflite/sqflite.dart';

class ScannerTable {
  static const String tableName = 'scanner';

  static Future<int> add(Scanner scanner) async {
    Database db = await DBHelper().database;
    return db.insert(tableName, scanner.toMap());
  }

  static Future<int> update(Scanner scanner) async {
    Database db = await DBHelper().database;
    return db.update(tableName, scanner.toMap(), where: 'id_scanner = ?', whereArgs: [scanner.idScanner]);
  }

  static Future<int> delete(Scanner scanner) async {
    Database db = await DBHelper().database;
    return db.delete(tableName, where: 'id_scanner = ?', whereArgs: [scanner.idScanner]);
  }

  static Future<List<Scanner>?> getAll() async {
    Database db = await DBHelper().database;
    List<Map<String, dynamic>> list = await db.query(tableName);
    return list.isNotEmpty ? list.map((map) => Scanner.fromMap(map)).toList() : null;
  }

  static Future<Scanner?> getById(int idScanner) async {
    Database db = await DBHelper().database;
    List<Map<String, dynamic>> list = await db.query(tableName, where: 'id_scanner = ?', whereArgs: [idScanner]);
    return list.isNotEmpty ? list.map((map) => Scanner.fromMap(map)).toList().first : null;
  }
}