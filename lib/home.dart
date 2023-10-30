import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pos_printer_manager/models/pos_printer.dart';
import 'package:pos_printer_manager/services/printer_manager.dart';
import 'package:prnt/logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:webcontent_converter/webcontent_converter.dart';

import 'connection_adapters/bluetooth_adapter.dart';
import 'connection_adapters/impl.dart';
import 'connection_adapters/network_adapter.dart';
import 'connection_adapters/usb_adapter.dart';
import 'helpers/demo.dart';
import 'helpers/service.dart';
import 'logger/screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0.0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoggerScreen()),
        ),
        tooltip: "Logs",
        child: const Icon(Icons.description_outlined),
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
            BillTest(),
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
  }

  void _onPrintTapped() async {
    await dispatchPrint();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
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
              builder: (context, index) => Consumer<ConnectionViewModal>(
                builder: (context, viewModal, child) {
                  debugPrint("_PrinterConnectionPanelState.build: ");

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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemBuilder: (context, index) {
                      final printer = printers.elementAt(index);

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Printer ${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('ID: ${printer.id}'),
                                  Text('NAME: ${printer.name}'),
                                  Text('ADDRESS: ${printer.address}'),
                                  Text('CONNECTED: ${printer.connected}'),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _onConnectTapped(printer),
                                  child: const Text('Connect'),
                                ),
                                ElevatedButton(
                                  onPressed: _onPrintTapped,
                                  child: const Text('Print'),
                                ),
                              ],
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
    );
  }
}

class BillTest extends StatefulWidget {
  const BillTest({Key? key}) : super(key: key);

  @override
  State<BillTest> createState() => _BillTestState();
}

class _BillTestState extends State<BillTest> {
  Image? image;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final content = Demo.getShortReceiptContent();
    final bytes = await WebcontentConverter.contentToImage(
      content: content,
      executablePath: WebViewHelper.executablePath(),
    );
    final service = ESCPrinterService(bytes);
    imageBytes = await service.getBytes() as Uint8List;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    CapabilityProfile.getAvailableProfiles().then((x) {
      x.forEach((element) {
        debugPrint("_BillTestState.build: $element");
      });
    });

    if (image == null) {
      return const Text("Nothing yet");
    }
    return SizedBox(
      height: 300,
      child: Image.memory(imageBytes!),
    );
  }
}
