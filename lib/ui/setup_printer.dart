import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pos_printer_manager/enums/connection_type.dart';
import 'package:pos_printer_manager/models/pos_printer.dart';

import '../helpers/extensions.dart';
import '../helpers/types.dart';
import '../helpers/utils.dart';

class SetupPrintersScreen extends StatefulWidget {
  const SetupPrintersScreen({Key? key}) : super(key: key);

  @override
  State<SetupPrintersScreen> createState() => _SetupPrintersScreenState();
}

class _SetupPrintersScreenState extends State<SetupPrintersScreen> {
  final POSPrintersMap _printersMap = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) => _loadPrinters(),
    );
  }

  void _loadPrinters() async {
    // if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      POSPrintersMap printersMap = await getPrinters();
      debugPrint("_ViewPrintersState._loadPrinters: ✅ Fetched $printersMap printers");
      _printersMap
        ..clear()
        ..addAll(printersMap);
    } catch (e) {
      debugPrint("_ViewPrintersState._loadPrinters: ❌ERROR: $e");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setup Printers"),
        elevation: 2.0,
        actions: [
          IconButton(
            onPressed: _loadPrinters,
            icon: Icon(
              Icons.sync,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Builder(
          builder: (context) {
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

            return ListView.builder(
              itemCount: _printersMap.keys.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                ConnectionType type = _printersMap.keys.elementAt(index);
                POSPrinterIterable printers = _printersMap[type]!;

                return Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: printers.map((printer) {
                        return Row(
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
                            Material(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                              color: Theme.of(context).colorScheme.onInverseSurface,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                child: Text(
                                  type.formattedType,
                                  style: const TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class PrinterDetailsTile extends StatelessWidget {
  final POSPrinter printer;

  const PrinterDetailsTile({
    Key? key,
    required this.printer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
