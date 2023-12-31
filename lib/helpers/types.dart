import 'package:pos_printer_manager/models/pos_printer.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/services/printer_manager.dart';

import '../modals/message_data.dart';

typedef POSPrinterList = List<POSPrinter>;
typedef POSPrinterIterable = Iterable<POSPrinter>;

typedef BluetoothPrinterIterable = Iterable<BluetoothPrinter>;

typedef NetworkPrinterIterable = Iterable<NetWorkPrinter>;

typedef USBPrinterIterable = Iterable<USBPrinter>;

typedef OnPrinterSelected = void Function(
  ConnectionType type,
  POSPrinter printer,
  PrinterManager manager,
);

typedef MessageRecordList = List<MessageRecord>;
typedef MessageRecordIterable = Iterable<MessageRecord>;
