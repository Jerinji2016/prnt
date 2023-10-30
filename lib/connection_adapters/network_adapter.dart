import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/services/printer_manager.dart';

import '../helpers/types.dart';
import 'impl.dart';

class NetworkAdapter extends IPrinterConnectionAdapters<NetWorkPrinter, NetworkPrinterManager> {
  const NetworkAdapter();

  @override
  Future<PrinterManager> connect(NetWorkPrinter printer) async {
    const paperSize = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final manager = NetworkPrinterManager(printer, paperSize, profile);
    final conn = await manager.connect();

    debugPrint("NetworkAdapter.connect: ${conn.msg}");
    debugPrint("NetworkAdapter.connect: ${conn.value}");

    return manager;
  }

  @override
  Future<NetworkPrinterIterable> scan() {
    try {
      return NetworkPrinterManager.discover();
    } catch (e, st) {
      debugPrint("NetworkAdapter.connect: ❌ERROR: $e, $st");
      rethrow;
    }
  }
}
