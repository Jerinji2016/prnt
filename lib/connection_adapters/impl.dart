import 'package:flutter/cupertino.dart';
import 'package:pos_printer_manager/models/pos_printer.dart';
import 'package:pos_printer_manager/services/printer_manager.dart';

import '../helpers/types.dart';

abstract class IPrinterConnectionAdapters<T extends POSPrinter, X extends PrinterManager> {
  const IPrinterConnectionAdapters();

  Future<POSPrinterIterable> scan();

  Future<PrinterManager> connect(T printer);

  Future<void> dispatchPrint(X printerManager, List<int> data) async {
    final conn = await printerManager.writeBytes(data, isDisconnect: false);
    debugPrint("IPrinterConnectionAdapters.dispatchPrint: conn value: ${conn.value}");
    debugPrint("IPrinterConnectionAdapters.dispatchPrint: conn msg: ${conn.msg}");
  }
}
