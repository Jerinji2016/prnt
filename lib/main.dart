import 'package:flutter/material.dart';

import 'home.dart';

void main() {
  runApp(
    const PrntApp(),
  );
}

class PrntApp extends StatelessWidget {
  const PrntApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
