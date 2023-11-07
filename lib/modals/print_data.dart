import 'dart:convert';

import 'message_data.dart';

class PrintMessageData extends MessageData {
  PrintMessageData.fromMessageList(super.messageList) : super.fromMessageList();

  PrintMessageData(super.type, super.channel, super.data, super.timestamp);

  @override
  PrintData get data {
    Map<String, dynamic> data = jsonDecode(super.data);
    return PrintData(data);
  }

  String get dataEncoded => jsonEncode(data._json);
}

class PrintData {
  final Map<String, dynamic> _json;

  PrintData(this._json);

  String get template => (_json["template"] as String).replaceAll("\n", "");

  PrinterDetails get printer => PrinterDetails(_json["printer"]);

  @override
  String toString() => jsonEncode(_json);
}

class PrinterDetails {
  final Map<String, dynamic> _json;

  PrinterDetails(this._json);

  String get id => _json["_id"];

  String get companyId => _json["companyId"];

  String get name => _json["name"];

  String get value => _json["value"];
}
