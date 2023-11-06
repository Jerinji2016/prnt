import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pos_printer_manager/enums/connection_type.dart';
import 'package:pos_printer_manager/models/pos_printer.dart';
import 'package:pos_printer_manager/services/printer_manager.dart';
import 'package:prnt/helpers/extensions.dart';
import 'package:provider/provider.dart';

import '../connection_adapters/impl.dart';
import '../helpers/types.dart';

class PrinterConnectionPanel extends StatefulWidget {
  final ConnectionType type;
  final OnPrinterSelected? onPrinterTapped;

  const PrinterConnectionPanel({
    Key? key,
    required this.type,
    this.onPrinterTapped,
  }) : super(key: key);

  @override
  State<PrinterConnectionPanel> createState() => _PrinterConnectionPanelState();
}

class _PrinterConnectionPanelState extends State<PrinterConnectionPanel> with PrinterConnectionMixin {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    registerAdapter(widget.type.getAdapter());

    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) => _scanForDevices(),
    );
  }

  void _scanForDevices() async {
    setState(() => _isLoading = true);
    final printers = await scan();
    debugPrint("_PrinterConnectionPanelState._scanForDevices: ✅ Found ${printers.length} ${widget.type.formattedType}");
    setState(() => _isLoading = false);
  }

  void _onPrintTapped(POSPrinter printer) async {
    debugPrint("CONNECTING TO: Printer[${printer.id}]"
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
      setState(() {});

      widget.onPrinterTapped?.call(widget.type, printer, manager);
    } catch (e) {
      debugPrint("_PrinterConnectionPanelState._onConnectTapped: ❌ERROR: FAILED TO CONNECT");
    }
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
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.type.formattedType,
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
                          child: Text('No ${widget.type.formattedType} found!'),
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
                              if (widget.onPrinterTapped != null)
                                ElevatedButton(
                                  onPressed: () => _onPrintTapped(printer),
                                  child: const Text('Select'),
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
