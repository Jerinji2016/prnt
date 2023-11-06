import 'package:pos_printer_manager/enums/connection_type.dart';

import '../connection_adapters/bluetooth_adapter.dart';
import '../connection_adapters/impl.dart';
import '../connection_adapters/network_adapter.dart';
import '../connection_adapters/usb_adapter.dart';

extension ConnectionTypeExtension on ConnectionType {
  IPrinterConnectionAdapters getAdapter() {
    switch (this) {
      case ConnectionType.network:
        return const NetworkAdapter();

      case ConnectionType.bluetooth:
        return const BluetoothAdapter();

      case ConnectionType.usb:
        return const USBAdapter();
    }
  }

  String get formattedType {
    switch (this) {
      case ConnectionType.network:
        return "Network";
      case ConnectionType.bluetooth:
        return "Bluetooth";
      case ConnectionType.usb:
        return "USB";
    }
  }
}
