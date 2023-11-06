import 'package:flutter/cupertino.dart';
import 'package:pos_printer_manager/models/pos_printer.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/services/printer_manager.dart';

import '../../db/printer.table.dart';
import '../../helpers/extensions.dart';
import '../../helpers/types.dart';
import '../../helpers/utils.dart';

class SetUpPrintersViewModal extends ChangeNotifier {
  final POSPrinterList _scannedPrinters = [];
  final POSPrinterList _savedPrinters = [];

  bool _isScannedDevicesLoading = false;
  bool _isSavedDevicesLoading = false;

  POSPrinterIterable get scannedPrinters => _scannedPrinters;

  POSPrinterIterable get savedPrinters => _savedPrinters;

  bool get isScannedDevicesLoading => _isScannedDevicesLoading;

  bool get isSavedDevicesLoading => _isSavedDevicesLoading;

  void getSavedPrinters() async {
    _isSavedDevicesLoading = true;
    notifyListeners();

    try {
      POSPrinterIterable printers = await PrinterTable().getPrinters();
      _savedPrinters
        ..clear()
        ..addAll(printers);
    } catch (e) {
      debugPrint("SetUpPrintersViewModal.getSavedPrinters: ❌ERROR: $e");
    }

    _isSavedDevicesLoading = false;
    notifyListeners();
  }

  void scanPrinters() async {
    _isScannedDevicesLoading = true;
    notifyListeners();

    try {
      POSPrinterIterable printers = await getPrinters();
      debugPrint("_ViewPrintersState._loadPrinters: ✅ Fetched ${printers.length} printers");
      _scannedPrinters.clear();
      for (POSPrinter printer in printers) {
        if (!_savedPrinters.any((element) => element.id == printer.id)) {
          _scannedPrinters.add(printer);
        }
      }
    } catch (e) {
      debugPrint("_ViewPrintersState._loadPrinters: ❌ERROR: $e");
    }

    _isScannedDevicesLoading = false;
    notifyListeners();
  }

  void savePrinter(POSPrinter printer) async {
    await PrinterTable().add(printer);
    _savedPrinters.add(printer);
    _scannedPrinters.removeWhere((element) => element.id == printer.id);
    notifyListeners();
  }

  void removePrinter(POSPrinter printer) async {
    await PrinterTable().remove(printer);
    _savedPrinters.removeWhere((element) => element.id == printer.id);
    scanPrinters();
  }

  void testPrint(POSPrinter printer) async {
    debugPrint("SetUpPrintersViewModal.testPrint: ${printer.name}");
    final bytes = await testTicket();
    ConnectionType? connectionType = printer.connectionType;
    if (connectionType == null) {
      debugPrint("_dispatchPrint: ❌ERROR: Unknown Printer connection type");
      return;
    }

    PrinterManager manager = await connectionType.getAdapter().connect(printer);
    await connectionType.getAdapter().dispatchPrint(manager, bytes);
  }
}
