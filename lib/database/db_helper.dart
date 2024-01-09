import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = await getDatabasesPath();
    String dbPath = join(path, 'DocScannerPro.db');

    return await openDatabase(
        dbPath,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              """
CREATE TABLE IF NOT EXISTS scanner (
  id_scanner INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  created_at TEXT NULL,
  images_path TEXT NULL
);
              """
          );
        }
    );
  }
}
