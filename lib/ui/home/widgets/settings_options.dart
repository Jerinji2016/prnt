import 'package:flutter/material.dart';

import '../../../widgets/primary_button.dart';

class SettingsOptions extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onTap;

  const SettingsOptions({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6.0,
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
                  ),
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
