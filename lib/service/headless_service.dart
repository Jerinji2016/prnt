import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: depend_on_referenced_packages
import 'package:shared_preferences_android/shared_preferences_android.dart';

import '../db/db.dart';
import '../helpers/globals.dart';
import '../helpers/utils.dart';
import '../ui.bottom_sheet/notification_permission_rationale.dart';

class HeadlessService {
  HeadlessService._();

  static Future<void> initialize(BuildContext context) async {
    bool isRunning = await isForegroundServiceRunning();

    if (!isRunning) {
      if (!context.mounted) throw "Context unmounted";
      await HeadlessService._()._initialize(context);
    }
  }

  Future<void> _initialize(BuildContext context) async {
    await _checkNotificationPermissions(context);
    bool status = await startForegroundService();
    if (!status) throw "Failed to start Service";
  }

  Future<void> _checkNotificationPermissions(BuildContext context) async {
    final status = await Permission.notification.status;
    if (status == PermissionStatus.granted) return;

    final shouldShowRationale = await Permission.notification.shouldShowRequestRationale;
    if (!context.mounted) throw "Context unmounted";

    const permissionErrorMessage = "Please provide notification permissions to start service";
    if (shouldShowRationale) {
      bool? confirm = await NotificationPermissionRationale.show(context);
      if (!(confirm ?? false)) {
        throw permissionErrorMessage;
      }
    }

    final requestedStatus = await Permission.notification.request();
    if (requestedStatus == PermissionStatus.granted) return;
    throw permissionErrorMessage;
  }
}

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
