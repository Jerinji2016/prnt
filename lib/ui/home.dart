import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/utils.dart';
import '../modals/restaurant.dart';
import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
import '../service/foreground_service.dart';
import '../widgets/primary_button.dart';
import 'login.dart';
import 'messages.dart';
import 'setup_printers/setup_printers.dart';

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
              MaterialPageRoute(builder: (context) => const MessagesScreen()),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PrinterServiceStatusPanel(),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                height: 2.0,
                color: Theme.of(context).highlightColor,
              ),
              _SettingsOptions(
                title: "Manage Printers",
                description: "Setup your printer devices",
                buttonText: "Setup",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SetupPrintersScreen()),
                ),
              ),
              const SizedBox(height: 20.0),
              _SettingsOptions(
                title: "Print Logs",
                description: "Report of print notifications",
                buttonText: "View",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MessagesScreen()),
                ),
              ),
              const Center(
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

  void _runOnUIIsolate() async {
    setState(() => status = ForegroundServiceStatus.loading);
    runServerOnMainIsolate();
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      showToast(context, "Subscribed successfully", color: Colors.green);
    }
    setState(() => status = ForegroundServiceStatus.running);
  }

  void _onTap() async {
    // return _runOnUIIsolate();

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
        child: Row(
          children: [
            Expanded(
              flex: 2,
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
                  Row(
                    children: [
                      Text(
                        "Status: ",
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      Text(
                        status.name,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: status == ForegroundServiceStatus.loading
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : PrimaryButton(
                  onTap: _onTap,
                  text: status == ForegroundServiceStatus.stopped ? "Start" : "Stop",
                ),
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

  void _onLogoutTapped(BuildContext context) async {
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

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
            onTap: () => _onLogoutTapped(context),
          ),
        ),
      ],
    );
  }
}

class _SettingsOptions extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onTap;

  const _SettingsOptions({
    Key? key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
  }) : super(key: key);

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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Theme.of(context).disabledColor,
                    ),
                  )
                ],
              ),
            ),
            PrimaryButton(
              text: buttonText,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
