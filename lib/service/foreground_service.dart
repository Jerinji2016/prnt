import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pos_printer_manager/models/pos_printer.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/services/printer_manager.dart';
import 'package:redis/redis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

import '../helpers/extensions.dart';
import '../helpers/globals.dart';
import '../helpers/types.dart';
import '../helpers/utils.dart';
import '../modals/message_data.dart';
import '../modals/print_data.dart';
import '../providers/data_provider.dart';

enum ForegroundServiceStatus {
  stopped(
    name: "Stopped",
    icon: Icons.block_outlined,
    iconColor: Colors.red,
  ),
  running(
    name: "Running",
    icon: Icons.check_circle_outline,
    iconColor: Colors.green,
  ),
  loading(
    name: "Loading",
    icon: Icons.run_circle_outlined,
    iconColor: Colors.grey,
  );

  final String name;
  final IconData icon;
  final Color iconColor;

  const ForegroundServiceStatus({
    required this.name,
    required this.icon,
    required this.iconColor,
  });
}

class ForegroundService {
  ForegroundService._();

  static Future<void> registerHeadlessEntry() async {
    debugPrint("Headless.registerHeadlessEntry: ");
    if (Platform.isAndroid) {
      int? callbackMethodId = PluginUtilities.getCallbackHandle(headlessEntry)?.toRawHandle();
      if (callbackMethodId == null) {
        debugPrint("BackgroundSyncManager._registerHeadlessTask: Failed to get callback ID");
        return;
      }
      bool response = await registerServiceCallbackId(callbackMethodId);
      debugPrint("Headless.registerHeadlessEntry: Register Callback: ${response ? "✅" : "❌"}");
    } else if (Platform.isIOS) {
      debugPrint("⚠️ WARNING: background sync not implemented for iOS!");
      debugPrint("⚠️ WARNING: offline sync not implemented for iOS!");
    } else {
      throw "❌ Unimplemented platform";
    }
  }
}

@pragma('vm:entry-point')
void headlessEntry() async {
  debugPrint("headlessEntry: default headless entry");
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesAndroid.registerWith();

  sharedPreferences = await SharedPreferences.getInstance();
  await _registerWithRedisServer();
}

Future<void> runServerOnMainIsolate() => _registerWithRedisServer();

Future<void> _registerWithRedisServer() async {
  DataProvider dataProvider = DataProvider();
  String revenueCenterId = dataProvider.profile.revenueCenterId;
  String topic = "prod_dineazy_$revenueCenterId";

  final cmd = await RedisConnection().connect(
    RedisConfig.host,
    RedisConfig.port,
  );

  await cmd.send_object(['AUTH', RedisConfig.password]);
  final pubSub = PubSub(cmd);

  pubSub.subscribe([topic]);

  final stream = pubSub.getStream();
  await for (final msg in stream) {
    debugPrint("_registerWithRedisServer: new message");
    MessageData messageData = MessageData(msg);

    if (messageData.type == "subscribe" && messageData.data == 1) {
      debugPrint("_PubSubScreenState._onSubscribeTapped: ✅ Subscribed successfully");
      continue;
    }

    if (messageData.type == "message") {
      log(messageData.data);
      PrintMessageData printMessageData = PrintMessageData(msg);
      _dispatchPrint(printMessageData);
      continue;
    }
  }

  debugPrint("_registerWithRedisServer: finishing connection...");
}

void _dispatchPrint(PrintMessageData printMessageData) async {
  POSPrinterIterable printers = await getPrinters();


  int index = printers.toList().indexWhere(
        (element) => element.name == printMessageData.data.printer.value,
      );
  if (index == -1) {
    debugPrint("_dispatchPrint: ❌ERROR: Expected Printer(${printMessageData.data.printer.name}) was not found");
    return;
  }

  POSPrinter printer = printers.elementAt(index);
  ConnectionType? connectionType = printer.connectionType;
  if (connectionType == null) {
    debugPrint("_dispatchPrint: ❌ERROR: Unknown Printer connection type");
    return;
  }

  debugPrint("_dispatchPrint: name: ${printMessageData.data.printer.name}");
  debugPrint("_dispatchPrint: value: ${printMessageData.data.printer.value}");

  PrinterManager manager = await connectionType.getAdapter().connect(printer);
  debugPrint("_dispatchPrint: ✅ Connected to ${printer.name} | ${printer.address}");

  final bytes = await generateImageBytesFromHtml(printMessageData.data.template);
  img.Image? image = img.decodeImage(Uint8List.fromList(bytes));

  if (image == null) {
    debugPrint("_dispatchPrint: ❌ERROR: Failed to convert to Image");
    return;
  }

  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);
  List<int> printBytes = generator.imageRaster(image);
  printBytes += generator.feed(2);
  printBytes += generator.cut();

  await connectionType.getAdapter().dispatchPrint(manager, printBytes);
  debugPrint("dispatchPrint: ✅ Print Dispatched successfully");
}
