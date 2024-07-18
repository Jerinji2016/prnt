import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pos_printer_manager/models/pos_printer.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/services/printer_manager.dart';
import 'package:redis/redis.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: depend_on_referenced_packages
import 'package:shared_preferences_android/shared_preferences_android.dart';

import '../db/db.dart';
import '../db/message.table.dart';
import '../db/printer.table.dart';
import '../helpers/environment.dart';
import '../helpers/extensions.dart';
import '../helpers/globals.dart';
import '../helpers/utils.dart';
import '../modals/message_data.dart';
import '../modals/print_data.dart';

Future<void> registerHeadlessEntry() async {
  debugPrint("Headless.registerHeadlessEntry: ");
  if (!Platform.isAndroid) {
    throw "Unimplemented Platform $defaultTargetPlatform";
  }

  int? callbackMethodId = PluginUtilities.getCallbackHandle(headlessEntry)?.toRawHandle();
  if (callbackMethodId == null) {
    debugPrint("ForegroundService._registerHeadlessTask: Failed to get callback ID");
    return;
  }
  bool response = await registerServiceCallbackId(callbackMethodId);
  debugPrint("ForegroundService.registerHeadlessEntry: Register Callback: ${response ? "✅ Success" : "❌ Failed"}");
}

@pragma('vm:entry-point')
void headlessEntry() async {
  debugPrint("headlessEntry: default headless entry");
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  SharedPreferencesAndroid.registerWith();
  debugPrint("headlessEntry: ensure initialised");

  await DB.initialize();
  sharedPreferences = await SharedPreferences.getInstance();

  // DataProvider dataProvider = DataProvider();
  // String revenueCenterId = dataProvider.dineazyProfile.revenueCenterId;
  // String topic = "prod_dineazy_${revenueCenterId}_kot";
  // await _registerWithRedisServer(topic);
}

Future<void> runServerOnMainIsolate(String topic) => _registerWithRedisServer(topic);

Future<void> stopServerOnMainIsolate(String topic) async {
  final cmd = await RedisConnection().connect(
    Environment.redisHost,
    Environment.redisPort,
  );

  await cmd.send_object(['AUTH', Environment.redisPassword]);
  final pubSub = PubSub(cmd);
  pubSub.unsubscribe([topic]);
  debugPrint("stopServerOnMainIsolate: ✅ Unsubscribed successfully");
}

Future<void> _registerWithRedisServer(String topic) async {
  final cmd = await RedisConnection().connect(
    Environment.redisHost,
    Environment.redisPort,
  );

  await cmd.send_object(['AUTH', Environment.redisPassword]);
  final pubSub = PubSub(cmd);

  pubSub.subscribe([topic]);

  final stream = pubSub.getStream();
  await for (final msg in stream) {
    debugPrint("_registerWithRedisServer: new message");
    MessageData messageData = MessageData.fromMessageList(msg);

    if (messageData.type == "subscribe" && messageData.data == 1) {
      debugPrint("_PubSubScreenState._onSubscribeTapped: ✅ Subscribed successfully");
      continue;
    }

    if (messageData.type == "message") {
      log(messageData.data);
      PrintMessageData printMessageData = PrintMessageData.fromMessageList(msg);

      await MessageTable().add(printMessageData);
      debugPrint("_dispatchPrint: ✅ Message saved successfully");

      dispatchPrint(printMessageData);
      continue;
    }
  }

  debugPrint("_registerWithRedisServer: finishing connection...");
}

Future<void> dispatchPrint(PrintMessageData printMessageData) async {
  POSPrinter? printer = await PrinterTable().getPrinterByName(printMessageData.data.printer.value);
  if (printer == null) {
    debugPrint("_dispatchPrint: ❌ERROR: Expected Printer(${printMessageData.data.printer.value}) was not found");
    return;
  }

  ConnectionType? connectionType = printer.connectionType;
  if (connectionType == null) {
    debugPrint("_dispatchPrint: ❌ERROR: Unknown Printer connection type");
    return;
  }

  debugPrint("_dispatchPrint: name: ${printMessageData.data.printer.name}");
  debugPrint("_dispatchPrint: value: ${printMessageData.data.printer.value}");

  PrinterManager manager = await connectionType.getAdapter().connect(printer);
  debugPrint("_dispatchPrint: ✅ Connected to ${printer.name} | ${printer.address}");

  final bytes = await contentToImage(printMessageData.data.template);
  img.Image? image = img.decodeImage(Uint8List.fromList(bytes));

  if (image == null) {
    debugPrint("_dispatchPrint: ❌ERROR: Failed to convert to Image");
    return;
  }

  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);
  generator.reset();
  List<int> printBytes = generator.imageRaster(image);
  printBytes += generator.feed(2);
  printBytes += generator.cut(mode: PosCutMode.partial);

  await connectionType.getAdapter().dispatchPrint(manager, printBytes);
  debugPrint("dispatchPrint: ✅ Print Dispatched successfully");
}