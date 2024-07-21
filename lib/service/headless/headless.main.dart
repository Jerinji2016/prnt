import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import '../../db/db.dart';
import '../../db/message.table.dart';
import '../../helpers/globals.dart';
import '../../helpers/utils.dart';
import '../../modals/message_data.dart';
import '../redis_service.dart';

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
  debugPrint("ForegroundService.registerHeadlessEntry: Register Callback: ${response ? "✅Success" : "❌Failed"}");
}

void _onData(dynamic data) async {
  debugPrint("headless._onData: 🐞$data");
  if (data[0] == "remove-port") {
    IsolateNameServer.removePortNameMapping(headlessPortName);
    headlessReceivePort.close();
    return;
  }

  if (data[0] == "print") {
    int id = data[1];
    MessageTable messageTable = MessageTable();
    MessageRecord record = await messageTable.getById(id);
    RedisService.dispatchPrint(record.data);
    return;
  }

  String topic = data[0];
  String action = data[1];
  RedisService redisService = RedisService();
  SendPort? port = IsolateNameServer.lookupPortByName(uiPortName);
  try {
    if (action == "subscribe") {
      await redisService.startListeningOnTopic(topic);
    } else {
      await redisService.stopListeningOnTopic(topic);
    }
    port?.send([topic, action, true]);
  } catch (e) {
    port?.send([topic, action, false]);
  }
}

@pragma('vm:entry-point')
void headlessEntry() async {
  debugPrint("headlessEntry: default headless entry");
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  SharedPreferencesAndroid.registerWith();

  SendPort? headlessPort = IsolateNameServer.lookupPortByName(headlessPortName);
  if (headlessPort == null) {
    bool headlessPortStatus = IsolateNameServer.registerPortWithName(headlessReceivePort.sendPort, headlessPortName);
    debugPrint("registerIsolatePorts: ✅Headless Port registered ($headlessPortStatus)");
  }

  await DB.initialize();
  sharedPreferences = await SharedPreferences.getInstance();

  headlessReceivePort.listen(_onData);
  SendPort? port = IsolateNameServer.lookupPortByName(uiPortName);
  if (port == null) {
    debugPrint("headlessEntry: ❌ERROR: Headless port not found");
  }

  port?.send(['headless', 'initialized']);
  debugPrint("headlessEntry: ✅Headless initialization complete");
}
