import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pos_printer_manager/models/pos_printer.dart';
import 'package:prnt/ui/setup_printers/setup_printers.vm.dart';
import 'package:provider/provider.dart';

import '../../helpers/extensions.dart';
import '../../widgets/primary_button.dart';

class SetupPrintersScreen extends StatefulWidget {
  const SetupPrintersScreen({Key? key}) : super(key: key);

  @override
  State<SetupPrintersScreen> createState() => _SetupPrintersScreenState();
}

class _SetupPrintersScreenState extends State<SetupPrintersScreen> {
  final SetUpPrintersViewModal _viewModal = SetUpPrintersViewModal();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) => _viewModal.scanPrinters(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _viewModal,
      builder: (context, child) {
        final viewModal = Provider.of<SetUpPrintersViewModal>(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Setup Printers"),
            elevation: 2.0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(
              builder: (context) {
                // if (viewModal.isScannedDevicesLoading) {
                //   return const Center(
                //     child: Padding(
                //       padding: EdgeInsets.symmetric(vertical: 16.0),
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           CircularProgressIndicator(),
                //           SizedBox(height: 8.0),
                //           Text('Loading Printers...'),
                //         ],
                //       ),
                //     ),
                //   );
                // }

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Saved Devices",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: viewModal.getSavedPrinters,
                              icon: Icon(
                                Icons.sync,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    viewModal.isSavedDevicesLoading
                        ? const SliverToBoxAdapter(
                            child: Center(
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
                            ),
                          )
                        : viewModal.savedPrinters.isEmpty
                            ? const SliverToBoxAdapter(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24.0),
                                    child: Text("No saved printers"),
                                  ),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    POSPrinter printer = viewModal.savedPrinters.elementAt(index);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: PrinterDetailsTile(
                                        printer: printer,
                                        canSave: false,
                                      ),
                                    );
                                  },
                                  childCount: viewModal.savedPrinters.length,
                                ),
                              ),
                    SliverToBoxAdapter(
                      child: Container(
                        color: Theme.of(context).highlightColor,
                        height: 1.0,
                        margin: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.shortestSide * 0.2, vertical: 24.0),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Scanned Devices",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: viewModal.scanPrinters,
                              icon: Icon(
                                Icons.sync,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    viewModal.isScannedDevicesLoading
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8.0),
                                  Text('Loading Printers...'),
                                ],
                              ),
                            ),
                          )
                        : viewModal.scannedPrinters.isEmpty
                            ? const SliverToBoxAdapter(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24.0),
                                    child: Text("No new printers found"),
                                  ),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    POSPrinter printer = viewModal.scannedPrinters.elementAt(index);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: PrinterDetailsTile(
                                        printer: printer,
                                        canRemove: false,
                                      ),
                                    );
                                  },
                                  childCount: viewModal.scannedPrinters.length,
                                ),
                              ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class PrinterDetailsTile extends StatelessWidget {
  final POSPrinter printer;
  final bool canSave, canRemove, canTestPrint;

  const PrinterDetailsTile({
    Key? key,
    required this.printer,
    this.canSave = true,
    this.canRemove = true,
    this.canTestPrint = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SetUpPrintersViewModal viewModal = Provider.of<SetUpPrintersViewModal>(context);

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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
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
                      printer.connectionType?.formattedType ?? "Unknown",
                      style: const TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Wrap(
              direction: Axis.horizontal,
              spacing: 16.0,
              children: [
                if (canSave)
                  PrimaryButton(
                    text: "Save",
                    onTap: () => viewModal.savePrinter(printer),
                  ),
                if (canRemove)
                  PrimaryButton(
                    text: "Remove",
                    onTap: () => viewModal.removePrinter(printer),
                  ),
                if (canTestPrint)
                  PrimaryButton(
                    text: "Test Print",
                    onTap: () => viewModal.testPrint(printer),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
