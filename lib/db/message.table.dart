import 'package:sqflite/sqflite.dart';

import '../helpers/types.dart';
import '../modals/message_data.dart';
import '../modals/print_message_data.dart';
import 'db.dart';

class MessageTable {
  static const tableName = "Messages";

  static const id = "id", type = "type", data = "data", channel = "channel", status = "status", timestamp = "timestamp";

  static const createTableQuery = "CREATE TABLE $tableName ("
      "$id INTEGER PRIMARY KEY AUTOINCREMENT, "
      "$type TEXT NOT NULL, "
      "$channel TEXT NOT NULL, "
      "$data TEXT NOT NULL, "
      "$timestamp INTEGER NOT NULL, "
      "$status INT NOT NULL "
      ")";

  Database get _db => DB.getDatabaseInstance();

  Future<MessageRecordIterable> getAll() async {
    MessageRecordList messages = [];

    final cursor = await _db.query(tableName);
    for (Map<String, dynamic> json in cursor) {
      messages.add(MessageRecord.fromJson(json));
    }
    return messages;
  }

  Future<void> add(PrintMessageData printMessageData) => _db.insert(tableName, {
        type: printMessageData.type,
        channel: printMessageData.channel,
        data: printMessageData.dataEncoded,
        timestamp: printMessageData.timestamp.millisecondsSinceEpoch,
        status: 0,
      });
}
