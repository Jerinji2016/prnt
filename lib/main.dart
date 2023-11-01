import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/globals.dart';
import 'helpers/theme_provider.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    const PrntApp(),
  );
}

class PrntApp extends StatelessWidget {
  const PrntApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.mode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0031E1),
              ),
            ),
            darkTheme: ThemeData.dark(
              useMaterial3: true,
            ),
            home: const Home(),
          );
        },
      ),
    );
  }
}
