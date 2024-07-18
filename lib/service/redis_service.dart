import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pos_printer_manager/models/pos_printer.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/services/printer_manager.dart';
import 'package:redis/redis.dart';

import '../db/message.table.dart';
import '../db/printer.table.dart';
import '../helpers/environment.dart';
import '../helpers/extensions.dart';
import '../helpers/utils.dart';
import '../modals/message_data.dart';
import '../modals/print_data.dart';

class RedisService {
  final String topic;

  RedisService(this.topic);

  String get host => Environment.redisHost;

  int get port => Environment.redisPort;

  String get password => Environment.redisPassword;

  Future<void> startListeningOnUiIsolate() => _startListeningOnTopic();

  Future<void> stopListeningOnUiIsolate() async => _stopListeningOnTopic();

  String get type {
    if (topic.contains("dineazy")) {
      return "dineazy";
    }
    return "eazypms";
  }

  Future<void> _stopListeningOnTopic() async {
    final cmd = await RedisConnection().connect(host, port);
    await cmd.send_object(['AUTH', password]);
    final pubSub = PubSub(cmd);
    pubSub.unsubscribe([topic]);
    debugPrint("RedisService._stopListeningOnTopic: ✅Unsubscribed successfully");
  }

  Future<void> _startListeningOnTopic() async {
    final cmd = await RedisConnection().connect(host, port);
    await cmd.send_object(['AUTH', password]);
    final pubSub = PubSub(cmd);
    pubSub.subscribe([topic]);

    final stream = pubSub.getStream();
    await for (final msg in stream) {
      debugPrint("RedisService._startListeningOnTopic: 🐞new message");
      MessageData messageData = MessageData.fromMessageList(msg);

      if (messageData.type == "subscribe" && messageData.data == 1) {
        debugPrint("RedisService._startListeningOnTopic: ✅Subscribed successfully");
        continue;
      }

      if (messageData.type == "message") {
        log(messageData.data);
        PrintMessageData printMessageData = PrintMessageData.fromMessageList(msg);

        await MessageTable().add(printMessageData);
        debugPrint("RedisService._startListeningOnTopic: ✅Message saved successfully");

        dispatchPrint(printMessageData);
        continue;
      }
    }

    debugPrint("RedisService._startListeningOnTopic: 🐞finishing connection...");
  }

  static Future<void> dispatchPrint(PrintMessageData printMessageData) async {
    POSPrinter? printer = await PrinterTable().getPrinterByName(printMessageData.data.printer.value);
    if (printer == null) {
      debugPrint(
          "RedisService.dispatchPrint: ❌ERROR: Expected Printer(${printMessageData.data.printer.value}) was not found");
      return;
    }

    ConnectionType? connectionType = printer.connectionType;
    if (connectionType == null) {
      debugPrint("RedisService.dispatchPrint: ❌ERROR: Unknown Printer connection type");
      return;
    }

    debugPrint("_dispatchPrint: name: ${printMessageData.data.printer.name}");
    debugPrint("_dispatchPrint: value: ${printMessageData.data.printer.value}");

    PrinterManager manager = await connectionType.getAdapter().connect(printer);
    debugPrint("RedisService.dispatchPrint: ✅Connected to ${printer.name} | ${printer.address}");

    final bytes = await contentToImage(printMessageData.data.template);
    img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
    if (image == null) {
      debugPrint("RedisService.dispatchPrint: ❌ERROR: Failed to convert to Image");
      return;
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    generator.reset();
    List<int> printBytes = generator.imageRaster(image);
    printBytes += generator.feed(2);
    printBytes += generator.cut(mode: PosCutMode.partial);

    await connectionType.getAdapter().dispatchPrint(manager, printBytes);
    debugPrint("RedisService.dispatchPrint: ✅Print Dispatched successfully");
  }
}