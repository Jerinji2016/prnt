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
import '../widgets/primary_button.dart';

class NotificationPermissionDelegate extends StatelessWidget {
  const NotificationPermissionDelegate._();

  static Future<bool?> show(BuildContext context) => showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        builder: (context) => BottomSheet(
          onClosing: () {},
          builder: (context) {
            return const NotificationPermissionDelegate._();
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Notification Permission",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          const Text(
            "This app requires notification permissions to start your printer service.\n\n"
            "Please tap on \"Allow\" if you wish to run your printer service in background.\n\n"
            "Alternatively, you can run this service in foreground by changing it in settings "
            "although this is not recommended.",
          ),
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PrimaryButton(
                text: "Deny",
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                color: Colors.red.shade700,
                onTap: () => Navigator.pop(context, false),
              ),
              PrimaryButton(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                text: "Allow",
                onTap: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
      bool? confirm = await NotificationPermissionDelegate.show(context);
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
