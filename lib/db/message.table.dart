import 'package:sqflite/sqflite.dart';

import 'db.dart';

class MessageTable {
  static const tableName = "Messages";

  static const id = "id", type = "type", data = "data", status = "status";

  static const createTableQuery = "CREATE TABLE $tableName ("
      "$id INTEGER PRIMARY KEY AUTOINCREMENT, "
      "$type TEXT NOT NULL, "
      "$data TEXT NOT NULL, "
      "$status INT NOT NULL "
      ")";

  Database get _db => DB.getDatabaseInstance();
}
