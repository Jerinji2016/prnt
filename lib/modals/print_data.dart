import 'dart:convert';

import 'package:prnt/modals/message_data.dart';

class PrintMessageData extends MessageData {
  PrintMessageData(super.messageList);

  @override
  PrintData get data {
    Map<String, dynamic> data = jsonDecode(super.data);
    return PrintData(data);
  }
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
