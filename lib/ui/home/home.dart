import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../modals/restaurant.dart';
import '../../providers/data_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/primary_button.dart';
import '../login.dart';
import '../messages/messages.dart';
import '../setup_printers/setup_printers.dart';
import 'widgets/settings_options.dart';
import 'widgets/login_details.dart';
import 'widgets/printer_service_status_panel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              SettingsOptions(
                title: "Manage Printers",
                description: "Setup your printer devices",
                buttonText: "Setup",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SetupPrintersScreen()),
                ),
              ),
              const SizedBox(height: 20.0),
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
