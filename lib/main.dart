import 'package:flutter/material.dart';
import 'package:prnt/providers/data_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/globals.dart';
import 'providers/theme_provider.dart';
import 'ui/home.dart';

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
