import '../db/message.table.dart';
import 'print_message_data.dart';

class MessageData<T> {
  final String type;

  final String channel;

  final T data;

  final DateTime timestamp;

  MessageData(this.type, this.channel, this.data, this.timestamp);

  MessageData.fromMessageList(List<dynamic> messageList)
      : type = messageList.first,
        channel = messageList[1],
        data = messageList.last,
        timestamp = DateTime.now();
}

class MessageRecord {
  final int id;
  final PrintMessageData data;
  final int statusCode;

  MessageRecord.fromJson(Map<String, dynamic> json)
      : id = json[MessageTable.id],
        data = PrintMessageData(
          json[MessageTable.type],
          json[MessageTable.channel],
          json[MessageTable.data],
          DateTime.fromMillisecondsSinceEpoch(
            json[MessageTable.timestamp],
          ),
        ),
        statusCode = json[MessageTable.status];
}
