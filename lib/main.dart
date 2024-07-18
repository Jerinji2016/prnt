import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db/db.dart';
import 'helpers/globals.dart';
import 'helpers/utils.dart';
import 'providers/data_provider.dart';
import 'providers/theme_provider.dart';
import 'service/headless_service.dart';
import 'ui/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sharedPreferences = await SharedPreferences.getInstance();
  await Future.wait([
    registerHeadlessEntry(),
    DB.initialize(),
  ]);
  getPrinters();

  runApp(
    const PrntApp(),
  );
}

class PrntApp extends StatelessWidget {
  const PrntApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => DataProvider(),
        ),
      ],
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
            darkTheme: ThemeData.dark(useMaterial3: true),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
