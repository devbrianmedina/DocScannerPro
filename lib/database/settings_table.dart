import 'package:doc_scanner_pro/database/db_helper.dart';
import 'package:doc_scanner_pro/models/settings.dart';
import 'package:sqflite/sqflite.dart';

class SettingsTable {
  static const String tableName = 'settings';

  static Future<void> saveSettings(Settings settings) async {
    Database db = await DBHelper().database;
    await db.update(
      tableName,
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  static Future<Settings> getSettings() async {
    Database db = await DBHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(tableName, where: 'id = ?', whereArgs: [1]);

    if (maps.isNotEmpty) {
      return Settings.fromMap(maps.first);
    } else {
      return Settings(darkTheme: false, preferredAdType: '');
    }
  }
}