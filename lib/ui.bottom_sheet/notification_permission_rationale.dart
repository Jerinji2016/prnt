import 'package:flutter/material.dart';

import '../widgets/primary_button.dart';

class NotificationPermissionRationale extends StatelessWidget {
  const NotificationPermissionRationale._();

  static Future<bool?> show(BuildContext context) => showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        builder: (context) => BottomSheet(
          onClosing: () {},
          builder: (context) {
            return const NotificationPermissionRationale._();
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Notification Permission",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          const Text(
            "This app requires notification permissions to start your printer service.\n\n"
            "Please tap on \"Allow\" if you wish to run your printer service in background.\n\n"
            "Alternatively, you can run this service in foreground by changing it in settings "
            "although this is not recommended.",
          ),
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PrimaryButton(
                text: "Deny",
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                color: Colors.red.shade700,
                onTap: () => Navigator.pop(context, false),
              ),
              PrimaryButton(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                text: "Allow",
                onTap: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
