import 'package:flutter/cupertino.dart';
import 'package:pos_printer_manager/models/pos_printer.dart';
import 'package:pos_printer_manager/services/printer_manager.dart';
import 'package:webcontent_converter/webcontent_converter.dart';

import '../helpers/demo.dart';
import '../helpers/service.dart';
import '../helpers/types.dart';
import '../logger/logger.dart';

abstract class IPrinterConnectionAdapters<T extends POSPrinter, X extends PrinterManager> {
  const IPrinterConnectionAdapters();

  Future<POSPrinterIterable> scan();

  Future<PrinterManager> connect(T printer);

  Future<void> dispatchPrint(X printerManager) async {
    final content = Demo.getShortReceiptContent();
    final bytes = await WebcontentConverter.contentToImage(
      content: content,
      executablePath: WebViewHelper.executablePath(),
    );
    final service = ESCPrinterService(bytes);
    final data = await service.getBytes();

    debugPrint("BluetoothAdapter.dispatchPrint: IS CONNECTED: ${printerManager.isConnected}");
    Logger.instance.debug("IS CONNECTED: ${printerManager.isConnected}");

    final conn = await printerManager.writeBytes(data, isDisconnect: false);
    debugPrint("IPrinterConnectionAdapters.dispatchPrint: conn value: ${conn.value}");
    debugPrint("IPrinterConnectionAdapters.dispatchPrint: conn msg: ${conn.msg}");

    Logger.instance.debug("Dispatch Response: value: ${conn.value}, msg: ${conn.msg}");
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
  Future<void> dispatchPrint([PrinterManager? printerManager]) {
    if ((viewModal.printerManager ?? printerManager) == null) {
      Logger.instance.error("Not connected to printer");
      throw "Not connected to printer";
    }
    return _adapter.dispatchPrint(viewModal.printerManager!);
  }
}
