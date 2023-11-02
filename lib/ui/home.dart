import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/utils.dart';
import '../modals/restaurant.dart';
import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
import '../service/foreground_service.dart';
import '../widgets/primary_button.dart';
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
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            PrinterServiceStatusPanel(),
            Expanded(
              child: SizedBox.shrink(),
            ),
            LoginDetails(),
          ],
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
