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

class ConnectionViewModal<T extends POSPrinter, X extends PrinterManager> extends ChangeNotifier {
  final key = UniqueKey();

  final _printers = <T>[];

  Iterable<T> get printers => _printers;

  void setPrinters(Iterable<T> printers) {
    _printers
      ..clear()
      ..addAll(printers);

    notifyListeners();
  }

  PrinterManager? printerManager;
}

mixin class PrinterConnectionMixin<X extends PrinterManager> implements IPrinterConnectionAdapters {
  late IPrinterConnectionAdapters _adapter;

  late final ConnectionViewModal viewModal;

  void registerAdapter<T extends IPrinterConnectionAdapters>(T adapter) {
    _adapter = adapter;
    viewModal = ConnectionViewModal();
  }

  @override
  Future<PrinterManager> connect(POSPrinter printer) async {
    PrinterManager printerManager = await _adapter.connect(printer);
    viewModal.printerManager = printerManager;
    return printerManager;
  }

  @override
  Future<POSPrinterIterable> scan() async {
    debugPrint("PrinterConnectionMixin.scan: ");
    final printers = await _adapter.scan();
    viewModal.setPrinters(printers);
    return printers;
  }

  @override
  Future<void> dispatchPrint(PrinterManager printerManager, List<int> data) async {}
}
