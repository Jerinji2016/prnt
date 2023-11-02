import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/services/printer_manager.dart';

import '../helpers/types.dart';
import 'impl.dart';

class BluetoothAdapter extends IPrinterConnectionAdapters<BluetoothPrinter, BluetoothPrinterManager> {
  const BluetoothAdapter();

  @override
  Future<PrinterManager> connect(BluetoothPrinter printer) async {
    const paperSize = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final manager = BluetoothPrinterManager(printer, paperSize, profile);
    final conn = await manager.connect();

    debugPrint("BluetoothAdapter.connect: ${conn.msg}");
    debugPrint("BluetoothAdapter.connect: ${conn.value}");

    return manager;
  }

  @override
  Future<BluetoothPrinterIterable> scan() {
    try {
      return BluetoothPrinterManager.discover();
    } catch (e, st) {
      debugPrint("BluetoothAdapter.connect: ❌ERROR: $e, $st");
      rethrow;
    }
  }
}
