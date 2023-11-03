import 'package:pos_printer_manager/models/pos_printer.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/services/printer_manager.dart';

import '../widgets/printer_connection_panel.dart';

typedef POSPrinterList = List<POSPrinter>;
typedef POSPrinterIterable = Iterable<POSPrinter>;

typedef BluetoothPrinterList = List<BluetoothPrinter>;
typedef BluetoothPrinterIterable = Iterable<BluetoothPrinter>;

typedef NetworkPrinterList = List<NetWorkPrinter>;
typedef NetworkPrinterIterable = Iterable<NetWorkPrinter>;

typedef USBPrinterList = List<USBPrinter>;
typedef USBPrinterIterable = Iterable<USBPrinter>;

typedef OnPrinterSelected = void Function(
  PrinterConnectionType type,
  POSPrinter printer,
  PrinterManager manager,
);

typedef POSPrintersMap = Map<PrinterConnectionType, POSPrinterIterable>;