import 'package:flutter/material.dart';

import '../../helpers/environment.dart';
import 'widgets/service_mode_card.dart';
import 'widgets/theme_mode_card.dart';

class Settings extends StatelessWidget {
  static Future<void> show(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return const Settings._();
          },
        );
      },
    );
  }

  const Settings._();

  Widget _buildEnvironmentText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: RichText(
        text: TextSpan(
          text: "Env: ${Environment.label}",
          style: TextStyle(
            fontSize: 12.0,
            color: Theme.of(context).disabledColor,
          ),
          children: [
            const TextSpan(
              text: "\nPowered by",
              style: TextStyle(
                height: 2,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
              ),
            ),
            TextSpan(
              text: "\nITProfound Inc.",
              style: TextStyle(
                fontSize: 16.0,
                fontStyle: FontStyle.normal,
                color: Theme.of(context).textTheme.labelSmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const ServiceModeCard(),
          const SizedBox(height: 16.0),
          const ThemeModeCard(),
          const SizedBox(height: 24.0),
          _buildEnvironmentText(context),
        ],
      ),
    );
  }
}
