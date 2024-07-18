import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_android/shared_preferences_android.dart';

import '../db/db.dart';
import '../helpers/globals.dart';
import '../helpers/utils.dart';

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

  await DB.initialize();
  sharedPreferences = await SharedPreferences.getInstance();
  debugPrint("headlessEntry: ✅Headless initialization complete");

  // DataProvider dataProvider = DataProvider();
  // String revenueCenterId = dataProvider.dineazyProfile.revenueCenterId;
  // String topic = "prod_dineazy_${revenueCenterId}_kot";
  // await _registerWithRedisServer(topic);
}
