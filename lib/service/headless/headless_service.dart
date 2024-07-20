import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../helpers/globals.dart';
import '../../helpers/utils.dart';
import '../../ui.bottom_sheet/notification_permission_rationale.dart';

class HeadlessService {
  HeadlessService._();

  static Future<void> initialize(BuildContext context) async => await HeadlessService._()._initialize(context);

  static Future<void> stop() async {
    SendPort? port = IsolateNameServer.lookupPortByName(headlessPortName);
    port?.send(["remove-port"]);
    await stopForegroundService();
  }

  Future<void> _initialize(BuildContext context) async {
    await _checkNotificationPermissions(context);
    await startForegroundService();
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
