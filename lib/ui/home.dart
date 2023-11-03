import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../helpers/types.dart';
import '../helpers/utils.dart';
import '../modals/restaurant.dart';
import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
import '../service/foreground_service.dart';
import '../widgets/primary_button.dart';
import '../widgets/printer_connection_panel.dart';
import 'message_log.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "PrintBot",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MessageLogScreen()),
            ),
            icon: const Icon(Icons.description_outlined),
            tooltip: "Message Logs",
          ),
          IconButton(
            onPressed: themeProvider.toggleTheme,
            icon: Icon(themeProvider.icon),
            tooltip: "Change Theme",
          ),
          const SizedBox(width: 16.0),
        ],
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrinterServiceStatusPanel(),
              SizedBox(height: 20.0),
              ViewPrinters(),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: LoginDetails(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrinterServiceStatusPanel extends StatefulWidget {
  const PrinterServiceStatusPanel({Key? key}) : super(key: key);

  @override
  State<PrinterServiceStatusPanel> createState() => _PrinterServiceStatusPanelState();
}

class _PrinterServiceStatusPanelState extends State<PrinterServiceStatusPanel> {
  ForegroundServiceStatus status = ForegroundServiceStatus.stopped;

  @override
  void initState() {
    super.initState();
    _loadServiceStatus();
  }

  void _loadServiceStatus() async {
    bool isServiceRunning = await isForegroundServiceRunning();
    setState(() {
      status = isServiceRunning ? ForegroundServiceStatus.running : ForegroundServiceStatus.stopped;
    });
  }

  void _onTap() async {
    setState(() => status = ForegroundServiceStatus.loading);
    runServerOnMainIsolate();
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      showToast(context, "Subscribed successfully", color: Colors.green);
    }
    setState(() => status = ForegroundServiceStatus.running);
    return;

    bool isServiceRunning = status == ForegroundServiceStatus.running;
    setState(() => status = ForegroundServiceStatus.loading);

    if (isServiceRunning) {
      bool response = await stopForegroundService();
      await Future.delayed(const Duration(seconds: 2));
      debugPrint("_PrinterServiceStatusPanelState._onTap: Stop Foreground Service status: ${response ? "✅" : "❌"}");
    } else {
      bool response = await startForegroundService();
      await Future.delayed(const Duration(seconds: 5));
      debugPrint("_PrinterServiceStatusPanelState._onTap: Start Foreground Service status: ${response ? "✅" : "❌"}");
    }

    _loadServiceStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
      ),
      elevation: 10.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  "Printer Service",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8.0),
                Icon(
                  status.icon,
                  color: status.iconColor,
                  size: 20.0,
                )
              ],
            ),
            Text("Status: ${status.name}"),
            const SizedBox(height: 10.0),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: status == ForegroundServiceStatus.loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : status == ForegroundServiceStatus.running
                      ? const SizedBox.shrink()
                      : PrimaryButton(
                          onTap: _onTap,
                          text: status == ForegroundServiceStatus.stopped ? "Start" : "Stop",
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginDetails extends StatelessWidget {
  const LoginDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DataProvider dataProvider = Provider.of<DataProvider>(context);
    Restaurant? restaurant = dataProvider.restaurant;

    return Column(
      children: [
        Text(
          restaurant?.name ?? "Unknown Restaurant",
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (restaurant != null && restaurant.description.isNotEmpty)
          Text(
            restaurant.description,
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
        SizedBox(
          width: MediaQuery.of(context).size.shortestSide * 0.5,
          child: PrimaryButton(
            text: "Logout",
            onTap: dataProvider.logout,
          ),
        ),
      ],
    );
  }
}

class ViewPrinters extends StatefulWidget {
  const ViewPrinters({Key? key}) : super(key: key);

  @override
  State<ViewPrinters> createState() => _ViewPrintersState();
}

class _ViewPrintersState extends State<ViewPrinters> {
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
    debugPrint("_ViewPrintersState._loadPrinters: ");
    setState(() => _isLoading = true);
    debugPrint("_ViewPrintersState._loadPrinters: $_isLoading");

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
    debugPrint("_ViewPrintersState._loadPrinters: $_isLoading");
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "List Printers",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadPrinters,
                )
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
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
                      PrinterConnectionType type = _printersMap.keys.elementAt(index);
                      POSPrinterIterable printers = _printersMap[type]!;

                      return Column(
                        children: printers.map((printer) {
                          return Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                              ),
                              Material(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                color: Theme.of(context).colorScheme.primaryContainer,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                  child: Text(
                                    type.title,
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
