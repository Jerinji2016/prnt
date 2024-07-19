import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';
import '../../../widgets/primary_card.dart';

class ThemeModeCard extends StatefulWidget {
  const ThemeModeCard({super.key});

  @override
  State<ThemeModeCard> createState() => _ThemeModeCardState();
}

class _ThemeModeCardState extends State<ThemeModeCard> {
  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    String themeDescription;
    switch (themeProvider.mode) {
      case ThemeMode.system:
        themeDescription = "System";
        break;
      case ThemeMode.light:
        themeDescription = "Light";
        break;
      case ThemeMode.dark:
        themeDescription = "Dark";
        break;
    }

    return PrimaryCard(
      onTap: themeProvider.toggleTheme,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Theme",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  themeDescription,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(
              themeProvider.icon,
              color: Theme.of(context).disabledColor,
              size: 28.0,
            ),
          ),
        ],
      ),
    );
  }
}
