import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../enums/service_mode.dart';
import '../../../providers/data_provider.dart';
import '../../../widgets/primary_card.dart';

class ServiceModeCard extends StatefulWidget {
  const ServiceModeCard({super.key});

  @override
  State<ServiceModeCard> createState() => _ServiceModeCardState();
}

class _ServiceModeCardState extends State<ServiceModeCard> {
  void _onSwitchChanged(BuildContext context, bool value) {
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    ServiceMode mode = value ? ServiceMode.background : ServiceMode.foreground;
    dataProvider.saveServiceMode(mode);
  }

  Widget _buildForegroundWarningCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Material(
        color: Colors.yellow.shade200.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: Colors.yellow.shade700,
            width: 2.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                Icons.report_outlined,
                color: Colors.yellow.shade700,
              ),
              const SizedBox(width: 8.0),
              const Expanded(
                child: Text(
                  "Your print services may not work as expected when the app is in background for too long.",
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DataProvider dataProvider = Provider.of<DataProvider>(context);
    bool isBackground = dataProvider.serviceMode == ServiceMode.background;

    return PrimaryCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Service Mode",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      isBackground ? "Services will run in background" : "Services will run in foreground",
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isBackground,
                onChanged: (value) => _onSwitchChanged(context, value),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
            child: isBackground ? const SizedBox.shrink() : _buildForegroundWarningCard(),
          )
        ],
      ),
    );
  }
}
