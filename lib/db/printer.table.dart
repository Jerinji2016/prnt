import 'package:pos_printer_manager/enums/connection_type.dart';
import 'package:pos_printer_manager/models/bluetooth_printer.dart';
import 'package:pos_printer_manager/models/network_printer.dart';
import 'package:pos_printer_manager/models/pos_printer.dart';
import 'package:pos_printer_manager/models/usb_printer.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/types.dart';
import 'db.dart';

class PrinterTable {
  static const tableName = "Printer";

  static const name = "name",
      id = "id",
      address = "address",
      connectionType = "connectionType",
      type = "type",
      vendorId = "vendorId",
      productId = "productId",
      deviceId = "deviceId";

  static const createTableQuery = "CREATE TABLE $tableName ("
      "$id TEXT PRIMARY KEY, "
      "$name TEXT NOT NULL, "
      "$address TEXT,"
      "$connectionType INT, "
      "$type INT, "
      "$vendorId INT, "
      "$productId INT, "
      "$deviceId INT "
      ")";

  Database get _db => DB.getDatabaseInstance();

  POSPrinter getPOSPrinterFromCursor(Map<String, dynamic> json) {
    ConnectionType connectionType = ConnectionType.values[json[PrinterTable.connectionType]];

    switch (connectionType) {
      case ConnectionType.network:
        return NetWorkPrinter(
          id: json[id],
          name: json[name],
          address: json[address],
          type: json[type],
          connectionType: connectionType,
        );
      case ConnectionType.bluetooth:
        return BluetoothPrinter(
          id: json[id],
          name: json[name],
          address: json[address],
          type: json[type],
          connectionType: connectionType,
        );
      case ConnectionType.usb:
        return USBPrinter(
          id: json[id],
          name: json[name],
          address: json[address],
          type: json[type],
          connectionType: connectionType,
          deviceId: json[deviceId],
          vendorId: json[vendorId],
          productId: json[productId],
        );
    }
  }

  Future<POSPrinterIterable> getPrinters() async {
    POSPrinterList printers = [];
    final cursor = await _db.query(tableName);
    if (cursor.isEmpty) return [];

    for (Map<String, dynamic> item in cursor) {
      printers.add(
        getPOSPrinterFromCursor(item),
      );
    }
    return printers;
  }

  Future<void> add(POSPrinter printer) => _db.insert(tableName, {
        id: printer.id,
        name: printer.name,
        address: printer.address,
        connectionType: printer.connectionType?.index,
        type: printer.type,
        vendorId: printer.vendorId,
        productId: printer.productId,
        deviceId: printer.deviceId,
      });

  Future<void> remove(POSPrinter printer) => _db.delete(
        tableName,
        where: "$id=?",
        whereArgs: [printer.id],
      );

  Future<POSPrinter?> getPrinterByName(String name) async {
    final cursor = await _db.query(
      tableName,
      where: "$name=?",
      whereArgs: [name],
    );

    if (cursor.isEmpty) return null;
    return getPOSPrinterFromCursor(cursor.first);
  }
}
