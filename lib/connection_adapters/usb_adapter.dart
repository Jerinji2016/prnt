import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/services/printer_manager.dart';

import '../helpers/types.dart';
import 'impl.dart';

class USBAdapter extends IPrinterConnectionAdapters<USBPrinter, USBPrinterManager> {
  const USBAdapter();

  @override
  Future<PrinterManager> connect(USBPrinter printer) async {
    const paperSize = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final manager = USBPrinterManager(printer, paperSize, profile);
    final conn = await manager.connect();

    debugPrint("USBAdapter.connect: ${conn.msg}");
    debugPrint("USBAdapter.connect: ${conn.value}");

    return manager;
  }

  @override
  Future<USBPrinterIterable> scan() {
    try {
      return USBPrinterManager.discover();
    } catch (e, st) {
      debugPrint("USBAdapter.connect: ❌ERROR: $e, $st");
      rethrow;
    }
  }
}
