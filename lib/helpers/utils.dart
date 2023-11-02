import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prnt/helpers/types.dart';
import 'package:webcontent_converter/webcontent_converter.dart';

import '../widgets/printer_connection_panel.dart';

const MethodChannel _channel = MethodChannel("com.jerin.prnt/main");

const _registerCallbackMethod = "registerCallbackId";
const _startServiceMethod = "startFgService";
const _getServiceStatusMethod = "getServiceStatus";
const _stopServiceMethod = "stopServiceMethod";

Future<bool> registerServiceCallbackId(int callbackId) async =>
    await _channel.invokeMethod(_registerCallbackMethod, callbackId) as bool;

Future<bool> startForegroundService() async => await _channel.invokeMethod(_startServiceMethod) as bool;

Future<bool> stopForegroundService() async => await _channel.invokeMethod(_stopServiceMethod) as bool;

Future<bool> isForegroundServiceRunning() async => await _channel.invokeMethod(_getServiceStatusMethod) as bool;

Future<List<int>> generateImageBytesFromHtml(String content) async {
  return await WebcontentConverter.contentToImage(
    content: content,
    executablePath: WebViewHelper.executablePath(),
  );
}

void showToast(BuildContext context, String message, {Color? color}) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: color ?? Theme.of(context).colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
      ),
    );


Future<Map<PrinterConnectionType, POSPrinterIterable>> getPrinters() async {
  Map<PrinterConnectionType, POSPrinterIterable> printerMap = {};

  List<POSPrinterEntry> responses = await Future.wait(
    [
      PrinterConnectionType.network,
      PrinterConnectionType.bluetooth,
    ].map((e) async {
      POSPrinterIterable printers = await e.adapter.scan();
      return MapEntry(e, printers);
    }),
  );

  printerMap.addEntries(responses);
  return printerMap;
}