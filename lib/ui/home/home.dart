import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home.vm.dart';
import 'pages/dineazy_config.dart';
import 'pages/eazypms_config.dart';
import 'widgets/settings_options.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModal(),
      builder: (context, child) {
        HomeViewModal viewModal = Provider.of<HomeViewModal>(context, listen: false);

        return Scaffold(
          appBar: AppBar(
            elevation: 4.0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                onPressed: () => viewModal.onMessagesIconTapped(context),
                icon: const Icon(Icons.description_outlined),
                tooltip: "Message Logs",
              ),
              IconButton(
                onPressed: () => viewModal.onSettingsIconTapped(context),
                icon: const Icon(Icons.settings_outlined),
                tooltip: "Settings",
              ),
              const SizedBox(width: 16.0),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: SettingsOptions(
                  title: "Manage Printers",
                  description: "Setup your printer devices",
                  buttonText: "Setup",
                  onTap: () => viewModal.onSetupPrinterTapped(context),
                ),
              ),
              const Expanded(
                child: PropertyConfigDelegate(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PropertyConfigDelegate extends StatefulWidget {
  const PropertyConfigDelegate({super.key});

  @override
  State<PropertyConfigDelegate> createState() => _PropertyConfigDelegateState();
}

class _PropertyConfigDelegateState extends State<PropertyConfigDelegate> with TickerProviderStateMixin {
  late final TabController tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  Tab _buildTabHeaders(String text) {
    return Tab(
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabs: [
            _buildTabHeaders("Dineazy"),
            _buildTabHeaders("eazyPMS"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            viewportFraction: 0.99,
            children: [
              DineazyConfigPage(),
              EazyPMSConfigPage(),
            ],
          ),
        ),
      ],
    );
  }
}
