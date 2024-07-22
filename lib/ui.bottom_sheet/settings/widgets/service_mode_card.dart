import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../enums/foreground_service_status.dart';
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
    int runningServicesCount = dataProvider.listeningTopics.values
        .where(
          (value) => value == ForegroundServiceStatus.running,
        )
        .length;
    bool hasServicesRunning = runningServicesCount > 0;

    return PrimaryCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Service Mode (${dataProvider.isBackgroundServiceMode ? "Background" : "Foreground"})",
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Services will run in ${dataProvider.isBackgroundServiceMode ? "background" : "foreground"}",
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: dataProvider.isBackgroundServiceMode,
                onChanged: (hasServicesRunning) ? null : (value) => _onSwitchChanged(context, value),
              ),
            ],
          ),
          if (hasServicesRunning)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "$runningServicesCount service(s) are still running in background. "
                "Please turn off them to enable this option",
                style: TextStyle(
                  fontSize: 12.0,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700.withOpacity(0.8),
                ),
              ),
            ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
            child: dataProvider.isBackgroundServiceMode ? const SizedBox.shrink() : _buildForegroundWarningCard(),
          ),
        ],
      ),
    );
  }
}
