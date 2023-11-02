import 'package:flutter/material.dart';
import 'package:prnt/modals/restaurant.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/primary_button.dart';
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
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        onPressed: () => _onSubscriptionTapped(context),
        tooltip: "Subscribe to Print Notifications",
        child: const Icon(Icons.subscriptions_outlined),
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

class PrinterServiceStatusPanel extends StatelessWidget {
  const PrinterServiceStatusPanel({Key? key}) : super(key: key);

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
            const Row(
              children: [
                Text(
                  "Printer Service",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.0),
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20.0,
                )
              ],
            ),
            const Text("Status: Running"),
            const SizedBox(height: 10.0),
            PrimaryButton(
              onTap: () {},
              text: "Stop",
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
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
