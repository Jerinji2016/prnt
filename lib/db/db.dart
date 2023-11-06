import 'package:prnt/db/message.table.dart';
import 'package:prnt/db/printer.table.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  static final DB _mInstance = DB._internal();

  factory DB() => _mInstance;

  DB._internal();

  static const _dbName = "PrintBot.db";
  static const int _version = 1;

  late Database _db;

  static Database getDatabaseInstance() => _mInstance._db;

  static Future<void> initializeDB() async {
    final String path = await getDatabasesPath();
    final String dbPath = "$path/$_dbName";

    _mInstance._db = await openDatabase(
      dbPath,
      version: _version,
      onConfigure: (Database db) async {
        //  enable foreign key supports
        await db.execute("PRAGMA foreign_keys=ON;");
      },
      onCreate: (Database db, int version) async {
        await Future.wait([
          db.execute(PrinterTable.createTableQuery),
          db.execute(MessageTable.createTableQuery),
        ]);
      },
    );
  }
}
