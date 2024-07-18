import 'package:flutter/material.dart';

import '../../../widgets/primary_card.dart';

class ServiceModeCard extends StatefulWidget {
  const ServiceModeCard({super.key});

  @override
  State<ServiceModeCard> createState() => _ServiceModeCardState();
}

class _ServiceModeCardState extends State<ServiceModeCard> {
  bool _isBackground = true;

  void _onSwitchChanged(bool value) {
    setState(() {
      _isBackground = value;
    });
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.report_outlined,
                color: Colors.yellow.shade700,
              ),
              const SizedBox(width: 8.0),
              const Expanded(
                child: Text(
                  "You print services may not work if the app is in background for too long.",
                  style: TextStyle(fontSize: 14.0),
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
                      _isBackground ? "Services will run in background" : "Services will run in foreground",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isBackground,
                onChanged: _onSwitchChanged,
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
            child: _isBackground ? const SizedBox.shrink() : _buildForegroundWarningCard(),
          )
        ],
      ),
    );
  }
}
