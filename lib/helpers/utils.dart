import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:webcontent_converter/webcontent_converter.dart';

import 'extensions.dart';
import 'types.dart';

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

Future<POSPrinterIterable> getPrinters() async {
  POSPrinterList allPrinters = [];

  List<POSPrinterIterable> responses = await Future.wait(
    ConnectionType.values.map((e) async {
      POSPrinterIterable printers = await e.getAdapter().scan();
      return printers;
    }),
  );

  for(POSPrinterIterable printers in responses) {
    if(printers.isNotEmpty) {
      allPrinters.addAll(printers);
    }
  }
  debugPrint("getPrinters: ${allPrinters.length}");
  return allPrinters;
}

Future<List<int>> testTicket() async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);
  List<int> bytes = [];

  bytes += generator.text('Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
  bytes += generator.text(
    'Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
    styles: const PosStyles(codeTable: 'CP1252'),
  );
  bytes += generator.text(
    'Special 2: blåbærgrød',
    styles: const PosStyles(codeTable: 'CP1252'),
  );

  bytes += generator.text(
    'Bold text',
    styles: const PosStyles(bold: true),
  );
  bytes += generator.text('Reverse text', styles: const PosStyles(reverse: true));
  bytes += generator.text('Underlined text', styles: const PosStyles(underline: true), linesAfter: 1);
  bytes += generator.text('Align left', styles: const PosStyles(align: PosAlign.left));
  bytes += generator.text('Align center', styles: const PosStyles(align: PosAlign.center));
  bytes += generator.text('Align right', styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

  bytes += generator.text(
    'Text size 200%',
    styles: const PosStyles(
      height: PosTextSize.size2,
      width: PosTextSize.size2,
    ),
  );

  bytes += generator.feed(2);
  bytes += generator.cut();
  return bytes;
}
