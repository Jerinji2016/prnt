import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pos_printer_manager/models/pos_printer.dart';
import 'package:pos_printer_manager/services/printer_manager.dart';
import 'package:provider/provider.dart';

import '../connection_adapters/bluetooth_adapter.dart';
import '../connection_adapters/impl.dart';
import '../connection_adapters/network_adapter.dart';
import '../connection_adapters/usb_adapter.dart';
import '../helpers/theme_provider.dart';
import '../logger/logger.dart';
import '../logger/screen.dart';
import 'login.dart';

enum PrinterConnectionType {
  bluetooth(
    title: "Bluetooth Printers",
    adapter: BluetoothAdapter(),
  ),
  network(
    title: "Network Printers",
    adapter: NetworkAdapter(),
  ),
  usb(
    title: "USB Printers",
    adapter: USBAdapter(),
  );

  final String title;
  final IPrinterConnectionAdapters adapter;

  const PrinterConnectionType({
    required this.title,
    required this.adapter,
  });
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  void _onSubscriptionTapped(BuildContext context) {
    debugPrint("Home._onSubscriptionTapped: ");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Printer Service",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoggerScreen()),
                ),
            icon: const Icon(Icons.description_outlined),
            tooltip: "Debug Logs",
          ),
          IconButton(
            onPressed: themeProvider.toggleTheme,
            icon: Icon(themeProvider.icon),
            tooltip: "Change Theme",
          ),
          const SizedBox(width: 16.0),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        onPressed: () => _onSubscriptionTapped(context),
        tooltip: "Subscribe to Print Notifications",
        child: const Icon(Icons.subscriptions_outlined),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            PrinterConnectionPanel(
              type: PrinterConnectionType.bluetooth,
            ),
            PrinterConnectionPanel(
              type: PrinterConnectionType.network,
            ),
            PrinterConnectionPanel(
              type: PrinterConnectionType.usb,
            ),
          ],
        ),
      ),
    );
  }
}

class PrinterConnectionPanel extends StatefulWidget {
  final PrinterConnectionType type;

  const PrinterConnectionPanel({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  State<PrinterConnectionPanel> createState() => _PrinterConnectionPanelState();
}

class _PrinterConnectionPanelState extends State<PrinterConnectionPanel> with PrinterConnectionMixin {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    registerAdapter(widget.type.adapter);

    SchedulerBinding.instance.addPostFrameCallback(
          (timeStamp) => _scanForDevices(),
    );
  }

  void _scanForDevices() async {
    setState(() => _isLoading = true);
    final printers = await scan();
    debugPrint("_PrinterConnectionPanelState._scanForDevices: ✅ Found ${printers.length} ${widget.type.title}");
    Logger.instance.debug("FOUND ${printers.length} ${widget.type.title}");
    setState(() => _isLoading = false);
  }

  void _onConnectTapped(POSPrinter printer) async {
    try {
      PrinterManager manager = await connect(printer);
      debugPrint("_PrinterConnectionPanelState._onConnectTapped: ✅ CONNECTION STATUS: ${manager.isConnected}");
      Logger.instance.debug("✅ CONNECTION STATUS: ${manager.isConnected}");
      setState(() {});
    } catch (e, st) {
      debugPrint("_PrinterConnectionPanelState._onConnectTapped: ❌ERROR: FAILED TO CONNECT");
      Logger.instance.error("❌ERROR: $e, $st");
    }
  }

  void _onPrintTapped(POSPrinter printer) async {
    Logger.instance.debug("CONNECTING TO: Printer[${printer.id}]"
        "\nname: ${printer.name}"
        "\ntype: ${printer.type}"
        "\naddress: ${printer.address}"
        "\nbluetooth type: ${printer.bluetoothType}"
        "\ndevice id: ${printer.deviceId}"
        "\nproduct id: ${printer.productId}"
        "\nvendor id: ${printer.vendorId}"
        "\nconnection type: ${printer.connectionType}"
        "\nconnected: ${printer.connected}");

    try {
      PrinterManager manager = await connect(printer);
      debugPrint("_PrinterConnectionPanelState._onConnectTapped: ✅ CONNECTION STATUS: ${manager.isConnected}");
      Logger.instance.debug("✅ CONNECTION STATUS: ${manager.isConnected}");
      setState(() {});
    } catch (e, st) {
      debugPrint("_PrinterConnectionPanelState._onConnectTapped: ❌ERROR: FAILED TO CONNECT");
      Logger.instance.error("❌ERROR: $e, $st");
    }

    await dispatchPrint();
    setState(() {});
    debugPrint("_PrinterConnectionPanelState._onPrintTapped: ✅ PRINT DISPATCHED");
    Logger.instance.debug("✅ PRINT DISPATCHED");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        elevation: 10.0,
        borderRadius: const BorderRadius.all(
          Radius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme
                          .of(context)
                          .disabledColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.type.title,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _scanForDevices,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
              ChangeNotifierProvider(
                create: (context) => viewModal,
                builder: (context, index) =>
                    Consumer<ConnectionViewModal>(
                      builder: (context, viewModal, child) {
                        if (_isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8.0),
                                  Text('Loading Printers...'),
                                ],
                              ),
                            ),
                          );
                        }

                        Iterable<POSPrinter> printers = viewModal.printers;
                        if (printers.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text('No ${widget.type.title} found!'),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: printers.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final printer = printers.elementAt(index);

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              printer.name ?? "Unknown Printer",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Icon(
                                              Icons.circle,
                                              size: 18.0,
                                              color: printer.connected ? Colors.green : Colors.red,
                                            ),
                                          ],
                                        ),
                                        Text('Address: ${printer.address}'),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _onPrintTapped(printer),
                                    child: const Text('Print'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
