import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/printer_connection_panel.dart';
import 'login.dart';
import 'message_log.dart';
import 'pub_sub.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _onSubscriptionTapped(BuildContext context) {
    debugPrint("Home._onSubscriptionTapped: ");
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (dataProvider.hasProfile) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PubSubScreen()),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
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
