import 'package:flutter/material.dart';

import 'logger.dart';

class LoggerScreen extends StatelessWidget {
  const LoggerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Iterable<String> logs = Logger.instance.logs;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Logger"),
        elevation: 2.0,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          String log = logs.elementAt(index);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[500]!),
              ),
            ),
            child: Text(log),
          );
        },
        itemCount: logs.length,
      ),
    );
  }
}
