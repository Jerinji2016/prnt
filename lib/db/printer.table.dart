import 'package:sqflite/sqflite.dart';

import 'db.dart';

class PrinterTable {
  static const tableName = "Printer";

  static const name = "name", id = "id", address = "address";

  static const createTableQuery = "CREATE TABLE $tableName ("
      "$id INTEGER PRIMARY KEY AUTOINCREMENT, "
      "$name TEXT NOT NULL, "
      "$address TEXT "
      ")";

  Database get _db => DB.getDatabaseInstance();
}
